from abc import ABC, abstractmethod
from typing import Dict, Any, List, Optional
from datetime import datetime
from backend.shared.models import (
    HealthCardData,
    FitnessCardData,
    MarineCardData,
    TravelCardData,
    FamilyCardData,
    AgriCardData,
    CommuteCardData,
    EventsCardData,
    SevereAlert,
    AlertSeverity
)

class BaseAQIAdapter(ABC):
    @abstractmethod
    async def fetch_aqi(self, lat: float, lon: float) -> HealthCardData:
        pass

class BaseMarineAdapter(ABC):
    @abstractmethod
    async def fetch_marine_data(self, lat: float, lon: float) -> MarineCardData:
        pass

class BaseAgriAdapter(ABC):
    @abstractmethod
    async def fetch_agri_data(self, lat: float, lon: float) -> AgriCardData:
        pass

class BaseTrafficAdapter(ABC):
    @abstractmethod
    async def fetch_traffic_data(self, lat: float, lon: float, routes: Optional[List[Dict[str, str]]] = None) -> CommuteCardData:
        pass

class BaseAlertsAdapter(ABC):
    @abstractmethod
    async def fetch_active_alerts(self, lat: float, lon: float) -> List[SevereAlert]:
        pass

class BaseWeatherCoreAdapter(ABC):
    @abstractmethod
    async def fetch_fitness_data(self, lat: float, lon: float) -> FitnessCardData:
        pass

    @abstractmethod
    async def fetch_travel_data(self, lat: float, lon: float, destinations: Optional[List[str]] = None) -> TravelCardData:
        pass

    @abstractmethod
    async def fetch_family_data(self, lat: float, lon: float) -> FamilyCardData:
        pass

    @abstractmethod
    async def fetch_events_data(self, lat: float, lon: float) -> EventsCardData:
        pass
