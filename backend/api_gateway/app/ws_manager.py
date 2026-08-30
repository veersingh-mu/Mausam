import json
import logging
from typing import List, Dict, Any
from fastapi import WebSocket

logger = logging.getLogger("mausam.ws")

class WebSocketAlertManager:
    """
    Manages active client WebSocket connections for real-time severe weather alert streaming.
    """
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        logger.info(f"WebSocket client connected. Total clients: {len(self.active_connections)}")

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
            logger.info(f"WebSocket client disconnected. Total clients: {len(self.active_connections)}")

    async def broadcast_alert(self, alert_payload: Dict[str, Any]):
        """
        Broadcasts an alert event JSON to all connected Flutter clients in sub-second time.
        """
        if not self.active_connections:
            return

        dead_connections = []
        message = json.dumps({
            "type": "SEVERE_WEATHER_ALERT",
            "data": alert_payload
        })

        for connection in self.active_connections:
            try:
                await connection.send_text(message)
            except Exception as e:
                logger.warning(f"Error sending WebSocket message: {e}")
                dead_connections.append(connection)

        for dead in dead_connections:
            self.disconnect(dead)

ws_alert_manager = WebSocketAlertManager()
