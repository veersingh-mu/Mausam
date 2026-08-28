import os
import logging
from typing import Dict, Any, List, Optional
from backend.shared.models import SevereAlert

logger = logging.getLogger("mausam.fcm")

class FCMClient:
    """
    Firebase Cloud Messaging (FCM) push notification dispatcher for severe weather alerts.
    Acts as the fallback mechanism when mobile apps are backgrounded or closed.
    """
    def __init__(self, service_account_path: Optional[str] = None):
        self.service_account_path = service_account_path or os.getenv("FIREBASE_CREDENTIALS_PATH")
        self._initialized = False
        self._init_firebase()

    def _init_firebase(self):
        # In production with real credentials, initialize firebase_admin
        if self.service_account_path and os.path.exists(self.service_account_path):
            try:
                import firebase_admin
                from firebase_admin import credentials
                cred = credentials.Certificate(self.service_account_path)
                firebase_admin.initialize_app(cred)
                self._initialized = True
                logger.info("Firebase Admin SDK initialized successfully.")
            except Exception as e:
                logger.warning(f"Failed to initialize Firebase Admin SDK: {e}")
        else:
            logger.info("FCM Client initialized in mock/simulation mode (no service account).")

    async def send_severe_alert_push(self, alert: SevereAlert, topic: str = "severe_weather_india") -> Dict[str, Any]:
        """
        Dispatches high-priority push notification to topic or device tokens.
        """
        payload = {
            "notification": {
                "title": f"🚨 {alert.headline}",
                "body": alert.description,
            },
            "data": {
                "alert_id": alert.id,
                "category": alert.category,
                "severity": alert.severity.value,
                "click_action": "FLUTTER_NOTIFICATION_CLICK"
            },
            "topic": topic,
            "priority": "high"
        }

        if self._initialized:
            try:
                from firebase_admin import messaging
                message = messaging.Message(
                    notification=messaging.Notification(
                        title=f"🚨 {alert.headline}",
                        body=alert.description,
                    ),
                    data=payload["data"],
                    topic=topic,
                )
                response = messaging.send(message)
                logger.info(f"FCM message sent successfully: {response}")
                return {"status": "dispatched", "message_id": response}
            except Exception as e:
                logger.error(f"FCM dispatch error: {e}")
                return {"status": "error", "error": str(e)}

        # Simulation mode log
        logger.info(f"[FCM SIMULATION] Push sent to topic '{topic}': {alert.headline}")
        return {"status": "simulated", "topic": topic, "alert_id": alert.id}
