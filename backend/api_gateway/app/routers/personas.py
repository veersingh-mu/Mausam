from typing import List, Dict, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, Body
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import delete

from backend.api_gateway.app.database import get_db, DBUser, DBUserPersona, DBUserLayout, DBSavedLocation
from backend.shared.models import (
    PersonaType,
    OnboardingRequest,
    OnboardingResponse,
    UserLocationDto,
    UserPersonasResponse,
    UpdatePersonasRequest
)

router = APIRouter(prefix="/api/v1", tags=["Personas & Onboarding"])

class PersonaMetaDto(BaseModel):
    id: str
    label: str
    icon_name: str
    short_description: str
    accent_color: str
    sample_metrics: List[str]
    tags: List[str]

PERSONA_CATALOG: List[PersonaMetaDto] = [
    PersonaMetaDto(
        id="health",
        label="Health-Conscious",
        icon_name="favorite",
        short_description="AQI, pollen, UV & humidity alerts",
        accent_color="#BA1A1A",
        sample_metrics=["AQI 142 (Moderate)", "Pollen: Low", "UV Index: 7.2"],
        tags=["AQI", "PM2.5", "Pollen", "Respiratory"]
    ),
    PersonaMetaDto(
        id="fitness",
        label="Fitness Enthusiast",
        icon_name="directions_run",
        short_description="Best running hours, wind & heat alerts",
        accent_color="#2E7D32",
        sample_metrics=["Golden Hour: 05:30 AM", "Wind: 14 km/h", "Readiness: 92/100"],
        tags=["Running", "Heat Index", "Cycling", "Sunrise/Sunset"]
    ),
    PersonaMetaDto(
        id="beach",
        label="Beachgoer / Surfer",
        icon_name="waves",
        short_description="Tide times, wave height, sea temp",
        accent_color="#00639A",
        sample_metrics=["High Tide: 04:45 PM", "Wave: 1.2m", "Swim: Safe (Green)"],
        tags=["Tides", "INCOIS", "Swell", "Marine"]
    ),
    PersonaMetaDto(
        id="travel",
        label="Traveler",
        icon_name="flight",
        short_description="Destination weather & packing tips",
        accent_color="#6750A4",
        sample_metrics=["Goa: 29°C Sunny", "Shimla: 14°C", "Flight Risk: Low"],
        tags=["Multi-city", "Packing Tips", "Severe Bulletins"]
    ),
    PersonaMetaDto(
        id="family",
        label="Parent / Family",
        icon_name="family_restroom",
        short_description="School commute & rain alerts",
        accent_color="#FF8F00",
        sample_metrics=["School Commute: Clear", "Rain Window: 3:30 PM", "Attire: Light Cotton"],
        tags=["School Route", "Rain Radar", "Clothing Advisory"]
    ),
    PersonaMetaDto(
        id="agriculture",
        label="Farmer / Gardener",
        icon_name="agriculture",
        short_description="Soil moisture, rainfall, frost alerts",
        accent_color="#33691E",
        sample_metrics=["Soil Moisture: 48%", "72h Rain: 12mm", "Frost Risk: Nil"],
        tags=["Agromet", "Soil Sensor", "Crop Advisories"]
    ),
    PersonaMetaDto(
        id="commute",
        label="Daily Commuter",
        icon_name="commute",
        short_description="Traffic, visibility, fog/storm alerts",
        accent_color="#004D40",
        sample_metrics=["Visibility: 650m", "Delay: +8 min", "Status: Fog Buffer"],
        tags=["Traffic", "Highway Fog", "Route Visibility"]
    ),
    PersonaMetaDto(
        id="events",
        label="Event Planner",
        icon_name="event",
        short_description="Extended forecast & comfort index",
        accent_color="#6A1B9A",
        sample_metrics=["Comfort Index: 88/100", "Rain Prob: 15%", "Wind: Breezy"],
        tags=["Comfort Index", "Hourly Timeline", "Extended Forecast"]
    )
]

PERSONA_ID_MAP = {
    "traveler": PersonaType.TRAVEL,
    "travel": PersonaType.TRAVEL,
    "parent": PersonaType.FAMILY,
    "family": PersonaType.FAMILY,
    "farmer": PersonaType.AGRICULTURE,
    "agriculture": PersonaType.AGRICULTURE,
    "commuter": PersonaType.COMMUTE,
    "commute": PersonaType.COMMUTE,
    "event_planner": PersonaType.EVENTS,
    "events": PersonaType.EVENTS,
    "health": PersonaType.HEALTH,
    "fitness": PersonaType.FITNESS,
    "beach": PersonaType.BEACH,
}

@router.get("/personas", response_model=List[PersonaMetaDto])
async def list_available_personas():
    """Returns all 8 supported personas with descriptions, icons, and metadata."""
    return PERSONA_CATALOG

@router.get("/users/{user_id}/personas", response_model=UserPersonasResponse)
async def get_user_personas_v2(user_id: str, db: AsyncSession = Depends(get_db)):
    """Retrieves selected personas for a user from PostgreSQL."""
    result = await db.execute(
        select(DBUserPersona).where(DBUserPersona.user_id == user_id)
    )
    db_personas = result.scalars().all()
    if not db_personas:
        default_personas = [PersonaType.HEALTH, PersonaType.COMMUTE, PersonaType.FITNESS, PersonaType.FAMILY]
        return UserPersonasResponse(user_id=user_id, selected_personas=default_personas)
    
    parsed = []
    for p in db_personas:
        mapped = PERSONA_ID_MAP.get(p.persona.lower(), PersonaType.HEALTH)
        if mapped not in parsed:
            parsed.append(mapped)
    return UserPersonasResponse(user_id=user_id, selected_personas=parsed)

@router.get("/personas/{user_id}", response_model=List[PersonaType])
async def get_user_personas_legacy(user_id: str, db: AsyncSession = Depends(get_db)):
    """Legacy endpoint returning list of personas for backward compatibility."""
    resp = await get_user_personas_v2(user_id, db)
    return resp.selected_personas

@router.put("/users/{user_id}/personas", response_model=UserPersonasResponse)
async def update_user_personas_put(
    user_id: str,
    payload: UpdatePersonasRequest,
    db: AsyncSession = Depends(get_db)
):
    """Updates a user's persona selection in real-time."""
    if not payload.selected_personas:
        raise HTTPException(
            status_code=400,
            detail="At least 1 persona must be selected to personalize your weather feed."
        )

    # Ensure user exists
    user_res = await db.execute(select(DBUser).where(DBUser.id == user_id))
    user = user_res.scalar_one_or_none()
    if not user:
        user = DBUser(id=user_id)
        db.add(user)
        await db.flush()

    # Clear and replace personas
    await db.execute(delete(DBUserPersona).where(DBUserPersona.user_id == user_id))
    for idx, p in enumerate(payload.selected_personas):
        db.add(DBUserPersona(
            user_id=user_id,
            persona=p.value,
            is_primary=(idx == 0)
        ))

    await db.commit()

    return UserPersonasResponse(
        user_id=user_id,
        selected_personas=payload.selected_personas
    )

@router.post("/personas", response_model=Dict[str, Any])
async def update_user_personas_post(
    payload: Dict[str, Any] = Body(...),
    db: AsyncSession = Depends(get_db)
):
    """Legacy POST handler supporting flexible JSON payloads."""
    target_user_id = payload.get("user_id", "citizen_delhi_01")
    raw_personas = payload.get("personas", payload.get("selected_personas", []))

    personas_list = []
    for p in raw_personas:
        p_str = p.value if hasattr(p, "value") else str(p).lower()
        if p_str in PERSONA_ID_MAP:
            mapped = PERSONA_ID_MAP[p_str]
            if mapped not in personas_list:
                personas_list.append(mapped)

    if not personas_list:
        raise HTTPException(
            status_code=400,
            detail="At least 1 persona must be selected."
        )

    # Ensure user exists
    user_res = await db.execute(select(DBUser).where(DBUser.id == target_user_id))
    user = user_res.scalar_one_or_none()
    if not user:
        user = DBUser(id=target_user_id)
        db.add(user)
        await db.flush()

    await db.execute(delete(DBUserPersona).where(DBUserPersona.user_id == target_user_id))
    for idx, p in enumerate(personas_list):
        db.add(DBUserPersona(
            user_id=target_user_id,
            persona=p.value,
            is_primary=(idx == 0)
        ))

    await db.commit()
    return {
        "status": "success",
        "user_id": target_user_id,
        "selected_personas": [p.value for p in personas_list]
    }

@router.post("/onboarding/complete", response_model=OnboardingResponse)
async def complete_onboarding(
    payload: OnboardingRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Finalizes the 4-step onboarding flow:
    1. Persists user profile with onboarding_completed = True
    2. Saves all selected personas
    3. Saves primary GPS location and auxiliary saved locations
    4. Initializes custom card order layout
    """
    if not payload.selected_personas:
        raise HTTPException(
            status_code=400,
            detail="Onboarding requires selecting at least 1 weather persona."
        )

    # 1. Upsert User
    user_res = await db.execute(select(DBUser).where(DBUser.id == payload.user_id))
    user = user_res.scalar_one_or_none()
    if not user:
        user = DBUser(id=payload.user_id, onboarding_completed=True)
        db.add(user)
    else:
        user.onboarding_completed = True
    await db.flush()

    # 2. Persist Personas
    await db.execute(delete(DBUserPersona).where(DBUserPersona.user_id == payload.user_id))
    for idx, p in enumerate(payload.selected_personas):
        db.add(DBUserPersona(
            user_id=payload.user_id,
            persona=p.value,
            is_primary=(idx == 0)
        ))

    # 3. Persist Primary and Saved Locations
    await db.execute(delete(DBSavedLocation).where(DBSavedLocation.user_id == payload.user_id))
    
    prim = payload.primary_location
    db.add(DBSavedLocation(
        user_id=payload.user_id,
        name=prim.name,
        latitude=prim.latitude,
        longitude=prim.longitude,
        label=prim.label or "Primary",
        is_default=True
    ))

    for loc in payload.saved_locations:
        if loc.name != prim.name:
            db.add(DBSavedLocation(
                user_id=payload.user_id,
                name=loc.name,
                latitude=loc.latitude,
                longitude=loc.longitude,
                label=loc.label or "Saved Destination",
                is_default=False
            ))

    # 4. Initialize User Layout
    layout_res = await db.execute(select(DBUserLayout).where(DBUserLayout.user_id == payload.user_id))
    layout = layout_res.scalar_one_or_none()
    if not layout:
        db.add(DBUserLayout(
            user_id=payload.user_id,
            card_order=[p.value for p in payload.selected_personas],
            hidden_cards=[]
        ))
    else:
        layout.card_order = [p.value for p in payload.selected_personas]

    await db.commit()

    return OnboardingResponse(
        status="success",
        user_id=payload.user_id,
        selected_personas=payload.selected_personas,
        primary_location=payload.primary_location,
        message="Onboarding completed successfully. Weather feed is ready."
    )

@router.get("/users/{user_id}/locations", response_model=List[UserLocationDto])
async def get_user_saved_locations(user_id: str, db: AsyncSession = Depends(get_db)):
    """Retrieves all saved locations for a citizen."""
    result = await db.execute(
        select(DBSavedLocation).where(DBSavedLocation.user_id == user_id)
    )
    locations = result.scalars().all()
    if not locations:
        return [
            UserLocationDto(name="New Delhi, India", latitude=28.6139, longitude=77.2090, is_primary=True, label="Home")
        ]
    return [
        UserLocationDto(
            name=loc.name,
            latitude=loc.latitude,
            longitude=loc.longitude,
            is_primary=loc.is_default,
            label=loc.label or "Saved"
        ) for loc in locations
    ]

@router.post("/users/{user_id}/locations", response_model=UserLocationDto)
async def add_user_saved_location(
    user_id: str,
    location: UserLocationDto,
    db: AsyncSession = Depends(get_db)
):
    """Adds a new destination location for travel tracking."""
    db_loc = DBSavedLocation(
        user_id=user_id,
        name=location.name,
        latitude=location.latitude,
        longitude=location.longitude,
        label=location.label or "Destination",
        is_default=location.is_primary
    )
    db.add(db_loc)
    await db.commit()
    return location
