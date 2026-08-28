import pytest
import asyncio
from backend.shared.cache import cache_manager, CacheManager

@pytest.mark.asyncio
async def test_cache_geo_keying():
    # Verify ~1km grid rounding
    key1 = CacheManager.make_geo_key("aqi", 28.6139, 77.2090, precision=2)
    key2 = CacheManager.make_geo_key("aqi", 28.6142, 77.2088, precision=2)
    assert key1 == "aqi:28.61:77.21"
    assert key2 == "aqi:28.61:77.21"
    assert key1 == key2

@pytest.mark.asyncio
async def test_cache_set_get_and_expiration():
    key = "test:weather:sample"
    data = {"temperature_c": 31.5, "condition": "Sunny"}

    # Set with 2 seconds TTL
    await cache_manager.set_json(key, data, ttl_seconds=2)

    # Immediate get
    cached = await cache_manager.get_json(key)
    assert cached is not None
    assert cached["temperature_c"] == 31.5

    # Wait for expiration
    await asyncio.sleep(2.1)
    expired = await cache_manager.get_json(key)
    assert expired is None
