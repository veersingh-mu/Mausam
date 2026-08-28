from typing import List, Dict, Any
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query, BackgroundTasks
from datetime import datetime, timedelta

from backend.api_gateway.app.websockets import ws_alert_manager
from backend.services.alerts_service.app.adapters.imd_alerts_adapter import IMDAlertsAdapter
from backend.services.alerts_service.app.fcm_client import FCMClient
from backend.shared.models import SevereAlert, AlertSeverity

router = APIRouter(prefix="/api/v1/alerts", tags=["Severe Alerts & Real-time"])

adapter = IMDAlertsAdapter()
fcm_client = FCMClient()

@router.get("", response_model=List[SevereAlert])
async def get_alerts(
    lat: float = Query(28.6139, description="Latitude"),
    lon: float = Query(77.2090, description="Longitude")
):
    """Fetches active IMD severe alerts for current coordinates."""
    return await adapter.fetch_active_alerts(lat, lon)

@router.websocket("/ws")
async def websocket_alerts_endpoint(websocket: WebSocket):
    """
    Real-time WebSocket endpoint for instant sub-second severe alert delivery.
    Maintains persistent duplex connection with Flutter client.
    """
    await ws_alert_manager.connect(websocket)
    try:
        while True:
            # Keepalive / Client ping-pong
            data = await websocket.receive_text()
            # Send ack
            await websocket.send_json({"type": "HEARTBEAT_ACK", "timestamp": datetime.utcnow().isoformat()})
    except WebSocketDisconnect:
        ws_alert_manager.disconnect(websocket)
    except Exception:
        ws_alert_manager.disconnect(websocket)

@router.post("/simulate", response_model=Dict[str, Any])
async def simulate_severe_alert(
    headline: str = Query("Red Alert: Extremely Heavy Downpour & Urban Waterlogging Likely", description="Alert headline"),
    severity: str = Query("severe", description="Severity: info, warning, severe, extreme"),
    category: str = Query("Flash Flood / Rain", description="Alert category"),
    background_tasks: BackgroundTasks = None
):
    """
    Simulates a live severe weather warning:
    1. Broadcasts to all active WebSocket clients.
    2. Dispatches FCM fallback push notification.
    """
    alert = SevereAlert(
        id=f"IMD-LIVE-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}",
        headline=headline,
        description=f"Meteorological Doppler radar indicates severe convection band moving across city. Expect 60-80mm rain per hour.",
        severity=AlertSeverity(severity.lower()),
        category=category,
        issued_at=datetime.utcnow(),
        expires_at=datetime.utcnow() + timedelta(hours=6),
        affected_areas=["City Center", "Low-Lying Underpasses", "Metro Corridors"],
        instructions="Avoid unnecessary outdoor travel. Stay away from open electrical lines and waterlogged subways.",
        source="IMD National Cyclone & Thunderstorm Warning Centre"
    )

    alert_dict = alert.model_dump(mode="json")

    # 1. Live WebSocket push
    await ws_alert_manager.broadcast_alert(alert_dict)

    # 2. FCM Fallback
    fcm_res = await fcm_client.send_severe_alert_push(alert)

    return {
        "status": "alert_dispatched",
        "alert": alert_dict,
        "websocket_broadcast_count": len(ws_alert_manager.active_connections),
        "fcm_status": fcm_res
    }
