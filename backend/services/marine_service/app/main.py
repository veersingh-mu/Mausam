import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../..")))

from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from backend.services.marine_service.app.adapters.incois_adapter import INCOISMarineAdapter
from backend.shared.cache import cache_manager, CacheManager
from backend.shared.models import MarineCardData

app = FastAPI(title="Mausam Marine & Coastal Microservice", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

adapter = INCOISMarineAdapter()

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "marine-service"}

@app.get("/api/v1/marine", response_model=MarineCardData)
async def get_marine_metrics(
    lat: float = Query(18.9220, description="Latitude"),
    lon: float = Query(72.8347, description="Longitude"),
    bypass_cache: bool = Query(False)
):
    cache_key = CacheManager.make_geo_key("marine", lat, lon)

    if not bypass_cache:
        cached = await cache_manager.get_json(cache_key)
        if cached:
            return MarineCardData(**cached)

    try:
        data = await adapter.fetch_marine_data(lat, lon)
        # Cache for 10 minutes (600s)
        await cache_manager.set_json(cache_key, data.model_dump(), ttl_seconds=600)
        return data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch Marine data: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
