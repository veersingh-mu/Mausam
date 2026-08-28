import os
import asyncio
import logging
from typing import List, Dict, Any, Optional
from datetime import datetime

import httpx

from backend.shared.models import (
    PersonaType,
    WeatherLocation,
    CurrentConditions,
    SevereAlert,
    WidgetCard,
    HomepageFeedResponse,
    HealthCardData,
    FitnessCardData,
    MarineCardData,
    TravelCardData,
    FamilyCardData,
    AgriCardData,
    CommuteCardData,
    EventsCardData,
    AlertSeverity
)
from backend.shared.adapters.weather_core_adapter import IMDWeatherCoreAdapter
from backend.services.aqi_service.app.adapters.cpcb_adapter import CPCBAQIAdapter
from backend.services.marine_service.app.adapters.incois_adapter import INCOISMarineAdapter
from backend.services.agri_service.app.adapters.imd_agri_adapter import IMDAgriAdapter
from backend.services.traffic_service.app.adapters.maps_traffic_adapter import MapsTrafficAdapter
from backend.services.alerts_service.app.adapters.imd_alerts_adapter import IMDAlertsAdapter
from backend.shared.cache import cache_manager, CacheManager

logger = logging.getLogger("mausam.fanout")

# Service URLs (for Docker / Microservice HTTP mode)
AQI_SERVICE_URL = os.getenv("AQI_SERVICE_URL", "http://localhost:8001")
MARINE_SERVICE_URL = os.getenv("MARINE_SERVICE_URL", "http://localhost:8002")
AGRI_SERVICE_URL = os.getenv("AGRI_SERVICE_URL", "http://localhost:8003")
TRAFFIC_SERVICE_URL = os.getenv("TRAFFIC_SERVICE_URL", "http://localhost:8004")
ALERTS_SERVICE_URL = os.getenv("ALERTS_SERVICE_URL", "http://localhost:8005")

# Fallback direct adapters for unified / in-process execution & tests
core_adapter = IMDWeatherCoreAdapter()
direct_aqi_adapter = CPCBAQIAdapter()
direct_marine_adapter = INCOISMarineAdapter()
direct_agri_adapter = IMDAgriAdapter()
direct_traffic_adapter = MapsTrafficAdapter()
direct_alerts_adapter = IMDAlertsAdapter()

class FanoutCoordinator:
    """
    Coordinates parallel asynchronous fanout to microservices and adapters,
    merges card payloads, respects user custom layout order and hidden preferences.
    """

    async def _fetch_aqi_card(self, lat: float, lon: float) -> Optional[HealthCardData]:
        cache_key = CacheManager.make_geo_key("aqi", lat, lon)
        cached = await cache_manager.get_json(cache_key)
        if cached:
            return HealthCardData(**cached)

        # Try HTTP microservice first if reachable, else direct adapter
        try:
            async with httpx.AsyncClient(timeout=2.0) as client:
                resp = await client.get(f"{AQI_SERVICE_URL}/api/v1/aqi", params={"lat": lat, "lon": lon})
                if resp.status_code == 200:
                    data = HealthCardData(**resp.json())
                    await cache_manager.set_json(cache_key, data.model_dump(), ttl_seconds=600)
                    return data
        except Exception:
            pass

        data = await direct_aqi_adapter.fetch_aqi(lat, lon)
        await cache_manager.set_json(cache_key, data.model_dump(), ttl_seconds=600)
        return data

    async def _fetch_marine_card(self, lat: float, lon: float) -> Optional[MarineCardData]:
        cache_key = CacheManager.make_geo_key("marine", lat, lon)
        cached = await cache_manager.get_json(cache_key)
        if cached:
            return MarineCardData(**cached)

        try:
            async with httpx.AsyncClient(timeout=2.0) as client:
                resp = await client.get(f"{MARINE_SERVICE_URL}/api/v1/marine", params={"lat": lat, "lon": lon})
                if resp.status_code == 200:
                    data = MarineCardData(**resp.json())
                    await cache_manager.set_json(cache_key, data.model_dump(), ttl_seconds=600)
                    return data
        except Exception:
            pass

        data = await direct_marine_adapter.fetch_marine_data(lat, lon)
        await cache_manager.set_json(cache_key, data.model_dump(), ttl_seconds=600)
        return data

    async def _fetch_agri_card(self, lat: float, lon: float) -> Optional[AgriCardData]:
        cache_key = CacheManager.make_geo_key("agri", lat, lon)
        cached = await cache_manager.get_json(cache_key)
        if cached:
            return AgriCardData(**cached)

        try:
            async with httpx.AsyncClient(timeout=2.0) as client:
                resp = await client.get(f"{AGRI_SERVICE_URL}/api/v1/agri", params={"lat": lat, "lon": lon})
                if resp.status_code == 200:
                    data = AgriCardData(**resp.json())
                    await cache_manager.set_json(cache_key, data.model_dump(), ttl_seconds=600)
                    return data
        except Exception:
            pass

        data = await direct_agri_adapter.fetch_agri_data(lat, lon)
        await cache_manager.set_json(cache_key, data.model_dump(), ttl_seconds=600)
        return data

    async def _fetch_traffic_card(self, lat: float, lon: float) -> Optional[CommuteCardData]:
        cache_key = CacheManager.make_geo_key("traffic", lat, lon)
        cached = await cache_manager.get_json(cache_key)
        if cached:
            return CommuteCardData(**cached)

        try:
            async with httpx.AsyncClient(timeout=2.0) as client:
                resp = await client.get(f"{TRAFFIC_SERVICE_URL}/api/v1/traffic", params={"lat": lat, "lon": lon})
                if resp.status_code == 200:
                    data = CommuteCardData(**resp.json())
                    await cache_manager.set_json(cache_key, data.model_dump(), ttl_seconds=300)
                    return data
        except Exception:
            pass

        data = await direct_traffic_adapter.fetch_traffic_data(lat, lon)
        await cache_manager.set_json(cache_key, data.model_dump(), ttl_seconds=300)
        return data

    async def _fetch_alerts(self, lat: float, lon: float) -> List[SevereAlert]:
        cache_key = CacheManager.make_geo_key("alerts", lat, lon)
        cached = await cache_manager.get_json(cache_key)
        if cached is not None:
            return [SevereAlert(**a) for a in cached]

        try:
            async with httpx.AsyncClient(timeout=2.0) as client:
                resp = await client.get(f"{ALERTS_SERVICE_URL}/api/v1/alerts", params={"lat": lat, "lon": lon})
                if resp.status_code == 200:
                    alerts = [SevereAlert(**a) for a in resp.json()]
                    await cache_manager.set_json(cache_key, [a.model_dump() for a in alerts], ttl_seconds=180)
                    return alerts
        except Exception:
            pass

        alerts = await direct_alerts_adapter.fetch_active_alerts(lat, lon)
        await cache_manager.set_json(cache_key, [a.model_dump() for a in alerts], ttl_seconds=180)
        return alerts

    async def get_homepage_feed(
        self,
        user_id: str,
        lat: float,
        lon: float,
        location_name: str,
        personas: List[PersonaType],
        layout_order: Optional[List[str]] = None,
        hidden_cards: Optional[List[str]] = None
    ) -> HomepageFeedResponse:
        """
        Executes parallel fanout for selected personas, formats cards, applies layout.
        """
        hidden = set(hidden_cards or [])
        tasks = {}

        # Schedule tasks only for active, unhidden personas
        for p in personas:
            if p.value in hidden:
                continue
            if p == PersonaType.HEALTH:
                tasks[p] = self._fetch_aqi_card(lat, lon)
            elif p == PersonaType.FITNESS:
                tasks[p] = core_adapter.fetch_fitness_data(lat, lon)
            elif p == PersonaType.BEACH:
                tasks[p] = self._fetch_marine_card(lat, lon)
            elif p == PersonaType.TRAVEL:
                tasks[p] = core_adapter.fetch_travel_data(lat, lon)
            elif p == PersonaType.FAMILY:
                tasks[p] = core_adapter.fetch_family_data(lat, lon)
            elif p == PersonaType.AGRICULTURE:
                tasks[p] = self._fetch_agri_card(lat, lon)
            elif p == PersonaType.COMMUTE:
                tasks[p] = self._fetch_traffic_card(lat, lon)
            elif p == PersonaType.EVENTS:
                tasks[p] = core_adapter.fetch_events_data(lat, lon)

        # Also fetch severe alerts & current conditions concurrently
        alerts_task = self._fetch_alerts(lat, lon)

        # Run all concurrently
        all_futures = list(tasks.values())
        results_list = await asyncio.gather(*all_futures, alerts_task, return_exceptions=True)

        persona_keys = list(tasks.keys())
        persona_results = results_list[:len(persona_keys)]
        alerts_result = results_list[-1]

        alerts = alerts_result if isinstance(alerts_result, list) else []

        # Build raw card objects
        cards_dict: Dict[str, WidgetCard] = {}
        for p, res in zip(persona_keys, persona_results):
            if isinstance(res, Exception) or res is None:
                logger.error(f"Error fetching data for persona {p}: {res}")
                continue

            card_data = res.model_dump() if hasattr(res, "model_dump") else res
            
            title_map = {
                PersonaType.HEALTH: "Health & Air Quality",
                PersonaType.FITNESS: "Fitness & Outdoor Running",
                PersonaType.BEACH: "Marine & Coastal Activity",
                PersonaType.TRAVEL: "Travel & Trip Planner",
                PersonaType.FAMILY: "Family & School Commute",
                PersonaType.AGRICULTURE: "Agromet & Soil Health",
                PersonaType.COMMUTE: "Daily Commute & Traffic",
                PersonaType.EVENTS: "Outdoor Events & Comfort"
            }

            subtitle_map = {
                PersonaType.HEALTH: "CPCB Air Quality Index & UV Monitoring",
                PersonaType.FITNESS: "Golden workout hours and heat indices",
                PersonaType.BEACH: "INCOIS Ocean State & Tides",
                PersonaType.TRAVEL: "Saved destination weather and packing tips",
                PersonaType.FAMILY: "Morning school bus conditions & rain outlook",
                PersonaType.AGRICULTURE: "IMD GKMS soil moisture & crop advisories",
                PersonaType.COMMUTE: "Live route travel times & highway fog",
                PersonaType.EVENTS: "Hourly rain probability & comfort index"
            }

            card = WidgetCard(
                id=f"card_{p.value}",
                persona=p,
                title=title_map.get(p, p.value.title()),
                subtitle=subtitle_map.get(p),
                order=0,
                is_visible=True,
                last_updated=datetime.utcnow(),
                data=card_data
            )
            cards_dict[p.value] = card

        # Order cards according to user layout preference
        ordered_cards: List[WidgetCard] = []
        if layout_order:
            for pid in layout_order:
                clean_pid = pid.replace("card_", "")
                if clean_pid in cards_dict:
                    ordered_cards.append(cards_dict.pop(clean_pid))

        # Append remaining cards in persona order
        for p in personas:
            if p.value in cards_dict:
                ordered_cards.append(cards_dict.pop(p.value))

        for card in list(cards_dict.values()):
            ordered_cards.append(card)

        # Set final order indices
        for idx, c in enumerate(ordered_cards):
            c.order = idx

        # Current flagship weather conditions from live adapter
        current_conditions = await core_adapter.fetch_current_conditions(lat, lon)

        return HomepageFeedResponse(
            user_id=user_id,
            location=WeatherLocation(
                name=location_name,
                latitude=lat,
                longitude=lon
            ),
            current=current_conditions,
            alerts=alerts,
            cards=ordered_cards,
            selected_personas=personas,
            timestamp=datetime.utcnow()
        )

fanout_coordinator = FanoutCoordinator()
