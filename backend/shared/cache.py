import os
import json
import logging
import asyncio
from typing import Any, Optional, Callable
from functools import wraps

logger = logging.getLogger("mausam.cache")

# Try importing redis.asyncio, fallback to in-memory cache if unavailable
try:
    import redis.asyncio as aioredis
    REDIS_AVAILABLE = True
except ImportError:
    aioredis = None
    REDIS_AVAILABLE = False

class MemoryCache:
    """In-memory fallback cache with TTL support."""
    def __init__(self):
        self._store = {}
        self._ttls = {}

    async def get(self, key: str) -> Optional[str]:
        loop = asyncio.get_running_loop()
        now = loop.time()
        if key in self._store:
            exp = self._ttls.get(key, 0)
            if exp == 0 or exp > now:
                return self._store[key]
            else:
                del self._store[key]
                if key in self._ttls:
                    del self._ttls[key]
        return None

    async def set(self, key: str, value: str, ex: Optional[int] = None) -> bool:
        loop = asyncio.get_running_loop()
        self._store[key] = value
        if ex:
            self._ttls[key] = loop.time() + ex
        else:
            self._ttls[key] = 0
        return True

    async def delete(self, key: str) -> int:
        if key in self._store:
            del self._store[key]
            self._ttls.pop(key, None)
            return 1
        return 0

    async def flush(self):
        self._store.clear()
        self._ttls.clear()


class CacheManager:
    """Redis Cache Manager with automatic in-memory fallback and TTL management."""
    def __init__(self, redis_url: Optional[str] = None):
        self.redis_url = redis_url or os.getenv("REDIS_URL", "redis://localhost:6379/0")
        self._redis_client = None
        self._memory_cache = MemoryCache()
        self._using_fallback = False

    async def get_client(self):
        if self._using_fallback:
            return self._memory_cache

        if self._redis_client is None and REDIS_AVAILABLE:
            try:
                client = aioredis.from_url(
                    self.redis_url,
                    decode_responses=True,
                    socket_connect_timeout=2.0
                )
                await client.ping()
                self._redis_client = client
                logger.info(f"Connected to Redis at {self.redis_url}")
                return self._redis_client
            except Exception as e:
                logger.warning(f"Failed to connect to Redis ({e}), falling back to in-memory cache.")
                self._using_fallback = True
                return self._memory_cache
        elif not REDIS_AVAILABLE:
            self._using_fallback = True
            return self._memory_cache

        return self._redis_client

    @staticmethod
    def make_geo_key(prefix: str, lat: float, lon: float, precision: int = 2) -> str:
        """
        Creates a geographic cache key with ~1km grid resolution (precision 2 decimals).
        Example: aqi:28.61:77.21
        """
        rounded_lat = round(lat, precision)
        rounded_lon = round(lon, precision)
        return f"{prefix}:{rounded_lat}:{rounded_lon}"

    async def get_json(self, key: str) -> Optional[Any]:
        try:
            client = await self.get_client()
            raw = await client.get(key)
            if raw:
                return json.loads(raw)
        except Exception as e:
            logger.error(f"Cache get error for key '{key}': {e}")
        return None

    async def set_json(self, key: str, value: Any, ttl_seconds: int = 300) -> bool:
        """Cache data with default 5 min (300s) to 10 min (600s) TTL."""
        try:
            client = await self.get_client()
            raw = json.dumps(value, default=str)
            await client.set(key, raw, ex=ttl_seconds)
            return True
        except Exception as e:
            logger.error(f"Cache set error for key '{key}': {e}")
            return False

    async def delete(self, key: str) -> bool:
        try:
            client = await self.get_client()
            await client.delete(key)
            return True
        except Exception as e:
            logger.error(f"Cache delete error for key '{key}': {e}")
            return False

# Global instance for easy import
cache_manager = CacheManager()

def cached_service_call(prefix: str, ttl_seconds: int = 300):
    """
    Decorator for caching service functions that take (lat: float, lon: float, ...).
    Checks Redis first; on miss, invokes adapter and caches result.
    """
    def decorator(func: Callable):
        @wraps(func)
        async def wrapper(lat: float, lon: float, *args, **kwargs):
            key = CacheManager.make_geo_key(prefix, lat, lon)
            cached_data = await cache_manager.get_json(key)
            if cached_data is not None:
                return cached_data

            result = await func(lat, lon, *args, **kwargs)
            if result is not None:
                # Convert pydantic models or dicts
                data_to_store = result.model_dump() if hasattr(result, "model_dump") else result
                await cache_manager.set_json(key, data_to_store, ttl_seconds=ttl_seconds)
            return result
        return wrapper
    return decorator
