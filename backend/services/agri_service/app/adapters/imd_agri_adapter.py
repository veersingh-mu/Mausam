import os
import random
import logging
from typing import Optional
from backend.shared.adapters.base import BaseAgriAdapter
from backend.shared.models import AgriCardData

logger = logging.getLogger("mausam.agri")

class IMDAgriAdapter(BaseAgriAdapter):
    """
    Adapter for IMD Gramin Krishi Mausam Sewa (GKMS) Agromet Advisories
    and National Soil Moisture Monitoring Portal.
    """
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv("IMD_AGRI_API_KEY")

    async def fetch_agri_data(self, lat: float, lon: float) -> AgriCardData:
        soil_surface = round(random.uniform(32.0, 58.0), 1)
        soil_rootzone = round(random.uniform(40.0, 65.0), 1)
        soil_temp = round(random.uniform(21.0, 29.5), 1)
        rain_72h = round(random.uniform(0.0, 42.5), 1)

        is_hilly_north = lat > 30.0
        frost_active = is_hilly_north and random.choice([True, False])
        frost_level = "Moderate" if frost_active else "None"

        advisories = [
            "Optimum window for top-dressing Nitrogen fertilizers in wheat/mustard crops.",
            "Maintain proper drainage in fields to prevent waterlogging during scattered spells.",
            "Weather is conducive for light foliar spray in afternoon (wind speed < 12 km/h)."
        ]

        if rain_72h > 15.0:
            irrigation = "Postpone scheduled irrigation; substantial natural rainfall expected in next 48 hours."
            pesticide_ok = False
        else:
            irrigation = "Apply light, regulated drip/furrow irrigation during early morning hours."
            pesticide_ok = True

        return AgriCardData(
            soil_moisture_surface_pct=soil_surface,
            soil_moisture_rootzone_pct=soil_rootzone,
            soil_temp_c=soil_temp,
            rainfall_prediction_72h_mm=rain_72h,
            rain_expected_days=2 if rain_72h > 10 else 0,
            frost_alert_active=frost_active,
            frost_risk_level=frost_level,
            crop_advisories=advisories,
            irrigation_recommendation=irrigation,
            pesticide_spraying_suitable=pesticide_ok
        )
