import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.abspath(os.path.join(current_dir, "../../../.."))
repo_root = os.path.abspath(os.path.join(current_dir, "../../../../.."))

for p in [repo_root, backend_dir, current_dir]:
    if p not in sys.path:
        sys.path.insert(0, p)

from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from backend.services.traffic_service.app.adapters.maps_traffic_adapter import MapsTrafficAdapter
from backend.shared.cache import cache_manager, CacheManager
from backend.shared.models import CommuteCardData

app = FastAPI(title="Mausam Commute & Traffic Microservice", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

adapter = MapsTrafficAdapter()

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "traffic-service"}

@app.get("/api/v1/traffic", response_model=CommuteCardData)
async def get_traffic_metrics(
    lat: float = Query(28.5355, description="Latitude"),
    lon: float = Query(77.3910, description="Longitude"),
    bypass_cache: bool = Query(False)
):
    cache_key = CacheManager.make_geo_key("traffic", lat, lon)

    if not bypass_cache:
        cached = await cache_manager.get_json(cache_key)
        if cached:
            return CommuteCardData(**cached)

    try:
        data = await adapter.fetch_traffic_data(lat, lon)
        # Cache for 5 minutes (300s) for live traffic
        await cache_manager.set_json(cache_key, data.model_dump(), ttl_seconds=300)
        return data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch Traffic data: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8004)
