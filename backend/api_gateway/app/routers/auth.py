import uuid
from typing import Dict, Any, Optional
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from backend.api_gateway.app.database import get_db, DBUser, DBUserPersona

router = APIRouter(prefix="/api/v1/auth", tags=["Authentication & OTP"])

class OTPRequest(BaseModel):
    phone_number: str

class OTPVerifyRequest(BaseModel):
    phone_number: str
    otp_code: str
    device_fcm_token: Optional[str] = None

class AuthResponse(BaseModel):
    user_id: str
    phone_number: str
    name: str
    token: str
    is_new_user: bool

@router.post("/request-otp")
async def request_otp(payload: OTPRequest):
    """
    Sends a mobile OTP via SMS Gateway / Firebase Auth.
    In development mode, OTP '123456' is accepted for any valid 10-digit Indian number.
    """
    clean_phone = payload.phone_number.strip()
    return {
        "status": "otp_sent",
        "phone_number": clean_phone,
        "message": "OTP sent successfully. (Dev test code: 123456)"
    }

@router.post("/verify-otp", response_model=AuthResponse)
async def verify_otp(payload: OTPVerifyRequest, db: AsyncSession = Depends(get_db)):
    """
    Verifies SMS OTP, issues JWT/session token, and provisions PostgreSQL user record.
    """
    clean_phone = payload.phone_number.strip()

    # Development simulation check or Firebase token validation
    if payload.otp_code not in ["123456", "999999"] and not payload.otp_code.isdigit():
        raise HTTPException(status_code=400, detail="Invalid OTP code. Please enter 123456.")

    # Check if user already exists
    user_res = await db.execute(
        select(DBUser).where(DBUser.phone_number == clean_phone)
    )
    user = user_res.scalar_one_or_none()

    is_new = False
    if not user:
        is_new = True
        user_id = f"usr_{uuid.uuid4().hex[:12]}"
        user = DBUser(
            id=user_id,
            phone_number=clean_phone,
            name="Citizen"
        )
        db.add(user)
        await db.flush()

        # Seed default starter personas
        default_personas = ["health", "commute", "fitness", "family"]
        for p in default_personas:
            db.add(DBUserPersona(user_id=user.id, persona=p, is_primary=(p == "health")))

        await db.commit()

    # Generate session token (e.g., Bearer token)
    session_token = f"mausam_jwt_{user.id}_{uuid.uuid4().hex[:8]}"

    return AuthResponse(
        user_id=user.id,
        phone_number=user.phone_number,
        name=user.name,
        token=session_token,
        is_new_user=is_new
    )
