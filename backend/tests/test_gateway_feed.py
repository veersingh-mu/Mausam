import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_gateway_health(async_client: AsyncClient):
    response = await async_client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "api-gateway"

@pytest.mark.asyncio
async def test_homepage_feed_default_personas(async_client: AsyncClient):
    """
    Tests /homepage-feed with a new user ID:
    Verifies default personas (Health, Commute, Fitness, Family) are fanned out and returned.
    """
    response = await async_client.get(
        "/api/v1/homepage-feed",
        params={
            "user_id": "test_citizen_001",
            "lat": 28.6139,
            "lon": 77.2090,
            "location_name": "New Delhi, Delhi"
        }
    )
    assert response.status_code == 200
    feed = response.json()
    assert feed["user_id"] == "test_citizen_001"
    assert feed["location"]["name"] == "New Delhi, Delhi"
    assert "current" in feed
    assert "cards" in feed
    assert len(feed["cards"]) >= 4

    card_personas = [c["persona"] for c in feed["cards"]]
    assert "health" in card_personas
    assert "commute" in card_personas

    # Verify Health Card Structure
    health_card = next(c for c in feed["cards"] if c["persona"] == "health")
    assert "aqi" in health_card["data"]
    assert "pm25" in health_card["data"]
    assert "pollen_count" in health_card["data"]

@pytest.mark.asyncio
async def test_marine_persona_coastal_feed(async_client: AsyncClient):
    """
    Tests selecting Beach/Marine persona and verifying tide & wave data payload.
    """
    # 1. Update personas to Beach and Fitness
    update_res = await async_client.post(
        "/api/v1/personas",
        json={
            "user_id": "surfer_mumbai_99",
            "personas": ["beach", "fitness"]
        }
    )
    assert update_res.status_code == 200

    # 2. Query homepage feed for Mumbai coast
    feed_res = await async_client.get(
        "/api/v1/homepage-feed",
        params={
            "user_id": "surfer_mumbai_99",
            "lat": 18.9220,
            "lon": 72.8347,
            "location_name": "Mumbai Marine Drive"
        }
    )
    assert feed_res.status_code == 200
    feed = feed_res.json()
    assert len(feed["cards"]) == 2

    marine_card = next(c for c in feed["cards"] if c["persona"] == "beach")
    assert "wave_height_m" in marine_card["data"]
    assert "swim_safety" in marine_card["data"]
    assert "tide_schedule" in marine_card["data"]

@pytest.mark.asyncio
async def test_agriculture_persona_soil_feed(async_client: AsyncClient):
    """
    Tests selecting Farmer/Agriculture persona and verifying soil moisture & frost risk.
    """
    await async_client.post(
        "/api/v1/personas",
        json={
            "user_id": "farmer_punjab_12",
            "personas": ["agriculture", "health"]
        }
    )

    feed_res = await async_client.get(
        "/api/v1/homepage-feed",
        params={
            "user_id": "farmer_punjab_12",
            "lat": 30.9010,
            "lon": 75.8573,
            "location_name": "Ludhiana, Punjab"
        }
    )
    assert feed_res.status_code == 200
    feed = feed_res.json()

    agri_card = next(c for c in feed["cards"] if c["persona"] == "agriculture")
    assert "soil_moisture_surface_pct" in agri_card["data"]
    assert "rainfall_prediction_72h_mm" in agri_card["data"]
    assert "crop_advisories" in agri_card["data"]
