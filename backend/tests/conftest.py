import sys
import os
import pytest
import pytest_asyncio

# Ensure project root is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../..")))

from httpx import AsyncClient, ASGITransport
from backend.api_gateway.app.main import app
from backend.api_gateway.app.database import init_db, engine, Base
from backend.shared.cache import cache_manager

@pytest_asyncio.fixture(scope="session", autouse=True)
async def setup_test_db():
    await init_db()
    yield
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest_asyncio.fixture
async def async_client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        yield client

@pytest_asyncio.fixture(autouse=True)
async def clear_cache():
    client = await cache_manager.get_client()
    if hasattr(client, "flush"):
        await client.flush()
    yield
