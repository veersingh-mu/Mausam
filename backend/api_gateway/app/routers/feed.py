from typing import Optional, List
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from backend.api_gateway.app.database import get_db, DBUser, DBUserPersona, DBUserLayout
from backend.api_gateway.app.fanout import fanout_coordinator
from backend.shared.models import HomepageFeedResponse, PersonaType

router = APIRouter(prefix="/api/v1", tags=["Homepage Feed"])

@router.get("/homepage-feed", response_model=HomepageFeedResponse)
async def get_homepage_feed(
    user_id: str = Query(..., description="Unique User ID"),
    lat: float = Query(28.6139, description="Current Latitude"),
    lon: float = Query(77.2090, description="Current Longitude"),
    location_name: str = Query("New Delhi, India", description="Human readable location"),
    db: AsyncSession = Depends(get_db)
):
    # [DIAGNOSTIC 4] Log incoming location parameters
    print(f"[DIAGNOSTIC 4] Backend /homepage-feed received: user_id={user_id}, lat={lat}, lon={lon}, location_name='{location_name}'", flush=True)

    # 1. Fetch user's saved personas from DB
    result = await db.execute(
        select(DBUserPersona).where(DBUserPersona.user_id == user_id)
    )
    db_personas = result.scalars().all()

    if db_personas:
        personas = [PersonaType(p.persona) for p in db_personas]
    else:
        # Default personas for first-time / guest users: Health, Commute, Fitness, Family
        personas = [
            PersonaType.HEALTH,
            PersonaType.COMMUTE,
            PersonaType.FITNESS,
            PersonaType.FAMILY
        ]

    # 2. Fetch custom layout if configured
    layout_result = await db.execute(
        select(DBUserLayout).where(DBUserLayout.user_id == user_id)
    )
    user_layout = layout_result.scalar_one_or_none()

    card_order = user_layout.card_order if user_layout else None
    hidden_cards = user_layout.hidden_cards if user_layout else []

    # 3. Asynchronously fanout to microservices
    feed = await fanout_coordinator.get_homepage_feed(
        user_id=user_id,
        lat=lat,
        lon=lon,
        location_name=location_name,
        personas=personas,
        layout_order=card_order,
        hidden_cards=hidden_cards
    )

    return feed
