import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_list_and_update_personas(async_client: AsyncClient):
    # 1. List all 8 personas
    list_res = await async_client.get("/api/v1/personas")
    assert list_res.status_code == 200
    all_personas = list_res.json()
    assert len(all_personas) == 8
    ids = [p["id"] for p in all_personas]
    assert "health" in ids
    assert "fitness" in ids
    assert "beach" in ids
    assert "travel" in ids
    assert "family" in ids
    assert "agriculture" in ids
    assert "commute" in ids
    assert "events" in ids

    # 2. Update user's personas
    update_res = await async_client.put(
        "/api/v1/users/test_user_personas_01/personas",
        json={
            "selected_personas": ["events", "travel", "fitness"]
        }
    )
    assert update_res.status_code == 200
    assert update_res.json()["selected_personas"] == ["events", "travel", "fitness"]

    # 3. Retrieve user's personas
    get_res = await async_client.get("/api/v1/users/test_user_personas_01/personas")
    assert get_res.status_code == 200
    user_p = get_res.json()["selected_personas"]
    assert user_p == ["events", "travel", "fitness"]

@pytest.mark.asyncio
async def test_onboarding_wizard_complete_flow(async_client: AsyncClient):
    user_id = "citizen_onboard_new_99"
    payload = {
        "user_id": user_id,
        "selected_personas": ["health", "beach", "agriculture"],
        "primary_location": {
            "name": "Kochi Marine Hub, Kerala",
            "latitude": 9.9312,
            "longitude": 76.2673,
            "is_primary": True,
            "label": "Home Coastal"
        },
        "saved_locations": [
            {
                "name": "Munnar Tea Hills",
                "latitude": 10.0889,
                "longitude": 77.0595,
                "is_primary": False,
                "label": "Agri Estate"
            }
        ]
    }

    # 1. Submit onboarding payload
    res = await async_client.post("/api/v1/onboarding/complete", json=payload)
    assert res.status_code == 200
    body = res.json()
    assert body["status"] == "success"
    assert body["user_id"] == user_id
    assert body["selected_personas"] == ["health", "beach", "agriculture"]

    # 2. Verify personas persisted in DB
    p_res = await async_client.get(f"/api/v1/users/{user_id}/personas")
    assert p_res.status_code == 200
    assert p_res.json()["selected_personas"] == ["health", "beach", "agriculture"]

    # 3. Verify saved locations persisted in DB
    loc_res = await async_client.get(f"/api/v1/users/{user_id}/locations")
    assert loc_res.status_code == 200
    locs = loc_res.json()
    assert len(locs) == 2
    assert any(l["name"] == "Kochi Marine Hub, Kerala" and l["is_primary"] is True for l in locs)

    # 4. Verify homepage feed serves configured personas
    feed_res = await async_client.get(
        "/api/v1/homepage-feed",
        params={
            "user_id": user_id,
            "lat": 9.9312,
            "lon": 76.2673,
            "location_name": "Kochi"
        }
    )
    assert feed_res.status_code == 200
    feed = feed_res.json()
    returned_card_personas = [c["persona"] for c in feed["cards"]]
    assert "beach" in returned_card_personas
    assert "agriculture" in returned_card_personas

@pytest.mark.asyncio
async def test_onboarding_wizard_validation_error(async_client: AsyncClient):
    # Empty persona selection must fail with 400 Bad Request
    invalid_payload = {
        "user_id": "invalid_user_empty",
        "selected_personas": [],
        "primary_location": {
            "name": "Delhi",
            "latitude": 28.61,
            "longitude": 77.20,
            "is_primary": True
        }
    }
    res = await async_client.post("/api/v1/onboarding/complete", json=invalid_payload)
    assert res.status_code == 400

@pytest.mark.asyncio
async def test_in_app_persona_toggle_empty_guard(async_client: AsyncClient):
    # Deselecting all personas in PUT /api/v1/users/{id}/personas must fail
    res = await async_client.put(
        "/api/v1/users/guard_user/personas",
        json={"selected_personas": []}
    )
    assert res.status_code == 400

@pytest.mark.asyncio
async def test_custom_layout_reorder_and_hide(async_client: AsyncClient):
    user_id = "custom_layout_user_07"

    # 1. Set personas: health, fitness, commute, events
    await async_client.put(
        f"/api/v1/users/{user_id}/personas",
        json={
            "selected_personas": ["health", "fitness", "commute", "events"]
        }
    )

    # 2. Update layout: reorder to [events, commute, health] and hide fitness
    layout_update = await async_client.put(
        "/api/v1/homepage-layout",
        json={
            "user_id": user_id,
            "card_order": ["events", "commute", "health"],
            "hidden_cards": ["fitness"]
        }
    )
    assert layout_update.status_code == 200

    # 3. Verify feed respects card order and hiding
    feed_res = await async_client.get(
        "/api/v1/homepage-feed",
        params={
            "user_id": user_id,
            "lat": 28.6139,
            "lon": 77.2090,
            "location_name": "New Delhi"
        }
    )
    assert feed_res.status_code == 200
    feed = feed_res.json()
    returned_card_personas = [c["persona"] for c in feed["cards"]]

    assert "fitness" not in returned_card_personas
    assert returned_card_personas[0] == "events"
    assert returned_card_personas[1] == "commute"
    assert returned_card_personas[2] == "health"
