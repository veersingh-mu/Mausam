from typing import Dict, Any, List
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from backend.api_gateway.app.database import get_db, DBUser, DBUserLayout
from backend.shared.models import UserLayoutPreference

router = APIRouter(prefix="/api/v1/homepage-layout", tags=["Customize Homepage"])

class LayoutUpdateRequest(BaseModel):
    user_id: str
    card_order: List[str]  # e.g., ["health", "commute", "fitness", "agri"]
    hidden_cards: List[str] = []

@router.get("/{user_id}", response_model=UserLayoutPreference)
async def get_user_layout(user_id: str, db: AsyncSession = Depends(get_db)):
    """Retrieves custom card order and visibility settings for a user."""
    result = await db.execute(
        select(DBUserLayout).where(DBUserLayout.user_id == user_id)
    )
    layout = result.scalar_one_or_none()
    if not layout:
        return UserLayoutPreference(
            user_id=user_id,
            card_order=[],
            hidden_cards=[]
        )
    return UserLayoutPreference(
        user_id=layout.user_id,
        card_order=layout.card_order or [],
        hidden_cards=layout.hidden_cards or [],
        updated_at=layout.updated_at
    )

@router.put("", response_model=Dict[str, Any])
async def update_user_layout(
    payload: LayoutUpdateRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Persists reordered cards and show/hide visibility preferences.
    """
    # Ensure user exists
    user_res = await db.execute(select(DBUser).where(DBUser.id == payload.user_id))
    user = user_res.scalar_one_or_none()
    if not user:
        user = DBUser(id=payload.user_id)
        db.add(user)
        await db.flush()

    layout_res = await db.execute(
        select(DBUserLayout).where(DBUserLayout.user_id == payload.user_id)
    )
    layout = layout_res.scalar_one_or_none()

    if not layout:
        layout = DBUserLayout(
            user_id=payload.user_id,
            card_order=payload.card_order,
            hidden_cards=payload.hidden_cards
        )
        db.add(layout)
    else:
        layout.card_order = payload.card_order
        layout.hidden_cards = payload.hidden_cards

    await db.commit()
    return {
        "status": "success",
        "user_id": payload.user_id,
        "card_order": payload.card_order,
        "hidden_cards": payload.hidden_cards
    }
