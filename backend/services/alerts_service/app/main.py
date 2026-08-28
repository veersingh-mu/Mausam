import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.abspath(os.path.join(current_dir, "../../../.."))
repo_root = os.path.abspath(os.path.join(current_dir, "../../../../.."))

for p in [repo_root, backend_dir, current_dir]:
    if p not in sys.path:
        sys.path.insert(0, p)

from typing import List
from fastapi import FastAPI, Query, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from backend.services.alerts_service.app.adapters.imd_alerts_adapter import IMDAlertsAdapter
from backend.services.alerts_service.app.fcm_client import FCMClient
from backend.shared.cache import cache_manager, CacheManager
from backend.shared.models import SevereAlert

app = FastAPI(title="Mausam Severe Alerts Microservice", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

adapter = IMDAlertsAdapter()
fcm_client = FCMClient()

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "alerts-service"}

@app.get("/api/v1/alerts", response_model=List[SevereAlert])
async def get_active_alerts(
    lat: float = Query(28.6139, description="Latitude"),
    lon: float = Query(77.2090, description="Longitude"),
    bypass_cache: bool = Query(False)
):
    cache_key = CacheManager.make_geo_key("alerts", lat, lon)

    if not bypass_cache:
        cached = await cache_manager.get_json(cache_key)
        if cached is not None:
            return [SevereAlert(**a) for a in cached]

    try:
        alerts = await adapter.fetch_active_alerts(lat, lon)
        data_to_store = [a.model_dump() for a in alerts]
        # Alerts cached for 3 minutes (180s) to guarantee fast updates
        await cache_manager.set_json(cache_key, data_to_store, ttl_seconds=180)
        return alerts
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch Alerts: {str(e)}")

@app.post("/api/v1/alerts/broadcast")
async def broadcast_alert(alert: SevereAlert, background_tasks: BackgroundTasks):
    """
    Endpoint for meteorologists/operators to trigger an instant warning broadcast
    via WebSocket channel + FCM push fallback.
    """
    # Trigger background FCM dispatch
    background_tasks.add_task(fcm_client.send_severe_alert_push, alert)

    # Invalidate alert caches across regions
    await cache_manager.delete("alerts:broadcast")

    return {
        "status": "broadcast_initiated",
        "alert_id": alert.id,
        "headline": alert.headline,
        "severity": alert.severity.value
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8005)
