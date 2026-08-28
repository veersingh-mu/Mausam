import os
import random
import logging
from typing import Optional, List
from datetime import datetime, timedelta
from backend.shared.adapters.base import BaseAlertsAdapter
from backend.shared.models import SevereAlert, AlertSeverity

logger = logging.getLogger("mausam.alerts")

class IMDAlertsAdapter(BaseAlertsAdapter):
    """
    Adapter for IMD National Weather Forecasting Centre (NWFC)
    Severe Weather Warning Bulletins (Color Coded: Red/Orange/Yellow/Green).
    """
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv("IMD_ALERTS_API_KEY")

    async def fetch_active_alerts(self, lat: float, lon: float) -> List[SevereAlert]:
        alerts: List[SevereAlert] = []

        # Simulate alert generation based on region
        now = datetime.utcnow()
        expires = now + timedelta(hours=18)

        # Example: Tropical cyclone or coastal squall alert in coastal regions
        if lon < 73.5 or lon > 80.0:
            alerts.append(SevereAlert(
                id="IMD-WARN-2026-0828-M1",
                headline="Orange Alert: High Swell & Coastal Gale Warning",
                description="Squally winds speed reaching 45-55 kmph gusting to 65 kmph likely along and off coastal zones. Fishermen advised not to venture into deep sea.",
                severity=AlertSeverity.WARNING,
                category="Marine Alert",
                issued_at=now,
                expires_at=expires,
                affected_areas=["Coastal Belt", "Harbor Terminals", "Offshore Islands"],
                instructions="Keep small boats securely moored. Avoid venturing into open sea.",
                source="India Meteorological Department (IMD) - Cyclone Warning Division"
            ))

        # Example: Dense Fog / Thunderstorm in northern plains
        elif 26.0 <= lat <= 31.0:
            alerts.append(SevereAlert(
                id="IMD-WARN-2026-0828-N2",
                headline="Yellow Watch: Moderate to Dense Fog Early Morning",
                description="Dense fog layer isolated in pocket areas reducing visibility below 200m during 04:00 AM to 08:30 AM.",
                severity=AlertSeverity.INFO,
                category="Fog Advisory",
                issued_at=now,
                expires_at=expires,
                affected_areas=["National Highway Corridors", "Airport Perimeter"],
                instructions="Use low-beam fog lights and maintain safe vehicular distance.",
                source="IMD Regional Meteorological Centre, New Delhi"
            ))

        return alerts
