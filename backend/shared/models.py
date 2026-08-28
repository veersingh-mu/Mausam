from enum import Enum
from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field
from datetime import datetime

class PersonaType(str, Enum):
    HEALTH = "health"
    FITNESS = "fitness"
    BEACH = "beach"
    TRAVEL = "travel"
    FAMILY = "family"
    AGRICULTURE = "agriculture"
    COMMUTE = "commute"
    EVENTS = "events"

class WeatherLocation(BaseModel):
    name: str = "New Delhi, India"
    latitude: float = 28.6139
    longitude: float = 77.2090
    state: Optional[str] = "Delhi"
    country: str = "India"
    elevation_m: Optional[float] = 216.0

class AlertSeverity(str, Enum):
    INFO = "info"
    WARNING = "warning"
    SEVERE = "severe"
    EXTREME = "extreme"

class SevereAlert(BaseModel):
    id: str
    headline: str
    description: str
    severity: AlertSeverity
    category: str  # e.g., "Cyclone", "Heavy Rain", "Heatwave", "Dense Fog"
    issued_at: datetime = Field(default_factory=datetime.utcnow)
    expires_at: Optional[datetime] = None
    affected_areas: List[str] = Field(default_factory=list)
    instructions: Optional[str] = None
    source: str = "India Meteorological Department (IMD)"

# --- Persona Specific Card Data Payloads ---

class HealthCardData(BaseModel):
    aqi: int
    aqi_category: str  # Good, Moderate, Poor, Very Poor, Severe
    pm25: float
    pm10: float
    pollen_count: str  # Low, Moderate, High, Extreme
    pollen_types: List[str] = Field(default_factory=list)
    uv_index: float
    uv_category: str  # Low, Moderate, High, Very High
    humidity_pct: int
    health_advice: str
    sensitive_group_warning: bool

class FitnessCardData(BaseModel):
    sunrise: str
    sunset: str
    golden_running_hours: List[str]
    current_temp_c: float
    feels_like_c: float
    wind_speed_kmh: float
    wind_direction: str
    heat_stress_index: str  # Low, Moderate, High, Extreme
    heat_alert_active: bool
    outdoor_workout_score: int  # 1 to 100
    recommendation: str

class MarineCardData(BaseModel):
    next_high_tide: str
    next_low_tide: str
    tide_height_m: float
    tide_schedule: List[Dict[str, Any]]
    wave_height_m: float
    swell_period_sec: float
    sea_surface_temp_c: float
    swim_safety: str  # Safe, Caution, Dangerous
    flag_color: str  # Green, Yellow, Red, Double Red
    incois_bulletin: Optional[str] = None

class DestinationWeather(BaseModel):
    city: str
    temp_c: float
    condition: str
    rain_probability_pct: int
    severe_warning: Optional[str] = None

class TravelCardData(BaseModel):
    saved_destinations: List[DestinationWeather]
    flight_disruption_risk: str  # Low, Medium, High
    severe_travel_alerts: List[str]
    packing_tips: List[str]

class FamilyCardData(BaseModel):
    school_commute_status: str  # Clear, Heavy Rain, Fog Delay, Extreme Heat
    morning_temp_c: float
    afternoon_temp_c: float
    rain_window_start: Optional[str] = None
    rain_window_end: Optional[str] = None
    active_family_alerts: List[str]
    clothing_advisory: str
    outdoor_play_safe: bool

class AgriCardData(BaseModel):
    soil_moisture_surface_pct: float
    soil_moisture_rootzone_pct: float
    soil_temp_c: float
    rainfall_prediction_72h_mm: float
    rain_expected_days: int
    frost_alert_active: bool
    frost_risk_level: str  # None, Low, Moderate, Severe
    crop_advisories: List[str]
    irrigation_recommendation: str
    pesticide_spraying_suitable: bool

class CommuterRoute(BaseModel):
    route_name: str
    origin: str
    destination: str
    travel_time_mins: int
    delay_mins: int
    road_visibility_m: int
    hazard_alert: Optional[str] = None

class CommuteCardData(BaseModel):
    routes: List[CommuterRoute]
    dominant_visibility_m: int
    visibility_status: str  # Good, Moderate Fog, Dense Fog, Very Dense Fog
    active_storm_fog_alerts: List[str]
    recommended_departure_delta_mins: int

class HourlyRainForecast(BaseModel):
    time: str
    rain_probability_pct: int
    intensity_mm: float

class EventsCardData(BaseModel):
    event_comfort_index: int  # 1 to 100
    comfort_category: str  # Ideal, Pleasant, Humid, Uncomfortable, Risky
    rain_probability_pct: int
    peak_rain_time: Optional[str] = None
    hourly_forecast: List[HourlyRainForecast]
    wind_stability: str  # Calm, Breezy, Gusty
    extended_forecast_days: List[Dict[str, Any]]

# --- Generic Widget Card Container ---

class WidgetCard(BaseModel):
    id: str
    persona: PersonaType
    title: str
    subtitle: Optional[str] = None
    order: int
    is_visible: bool = True
    last_updated: datetime = Field(default_factory=datetime.utcnow)
    data: Dict[str, Any]

class CurrentConditions(BaseModel):
    temperature_c: float
    feels_like_c: float
    condition: str
    icon: str
    temp_min_c: float
    temp_max_c: float
    humidity_pct: int
    wind_kph: float
    pressure_mb: float
    uv_index: float
    air_quality_summary: str

class HomepageFeedResponse(BaseModel):
    user_id: str
    location: WeatherLocation
    current: CurrentConditions
    alerts: List[SevereAlert] = Field(default_factory=list)
    cards: List[WidgetCard] = Field(default_factory=list)
    selected_personas: List[PersonaType]
    timestamp: datetime = Field(default_factory=datetime.utcnow)

class UserLayoutPreference(BaseModel):
    user_id: str
    card_order: List[str]  # Ordered list of card IDs / persona types
    hidden_cards: List[str] = Field(default_factory=list)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

# --- Persona Onboarding & Selection Models ---

class PersonaDefinition(BaseModel):
    id: PersonaType
    label: str
    icon_name: str
    short_description: str
    accent_color: str
    tags: List[str] = Field(default_factory=list)

class UserLocationDto(BaseModel):
    name: str
    latitude: float
    longitude: float
    is_primary: bool = False
    label: Optional[str] = "Home"

class OnboardingRequest(BaseModel):
    user_id: str
    selected_personas: List[PersonaType]
    primary_location: UserLocationDto
    saved_locations: List[UserLocationDto] = Field(default_factory=list)

class OnboardingResponse(BaseModel):
    status: str = "success"
    user_id: str
    selected_personas: List[PersonaType]
    primary_location: UserLocationDto
    message: str = "Onboarding completed successfully"

class UserPersonasResponse(BaseModel):
    user_id: str
    selected_personas: List[PersonaType]
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class UpdatePersonasRequest(BaseModel):
    selected_personas: List[PersonaType]

