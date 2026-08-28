import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../..")))

from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from backend.services.agri_service.app.adapters.imd_agri_adapter import IMDAgriAdapter
from backend.shared.cache import cache_manager, CacheManager
from backend.shared.models import AgriCardData

app = FastAPI(title="Mausam Agriculture & Agromet Microservice", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

adapter = IMDAgriAdapter()

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "agri-service"}

@app.get("/api/v1/agri", response_model=AgriCardData)
async def get_agri_metrics(
    lat: float = Query(26.8467, description="Latitude"),
    lon: float = Query(80.9462, description="Longitude"),
    bypass_cache: bool = Query(False)
):
    cache_key = CacheManager.make_geo_key("agri", lat, lon)

    if not bypass_cache:
        cached = await cache_manager.get_json(cache_key)
        if cached:
            return AgriCardData(**cached)

    try:
        data = await adapter.fetch_agri_data(lat, lon)
        # Cache for 10 minutes (600s)
        await cache_manager.set_json(cache_key, data.model_dump(), ttl_seconds=600)
        return data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch Agriculture data: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8003)
