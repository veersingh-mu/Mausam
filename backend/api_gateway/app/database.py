import os
import json
import logging
from typing import List, Optional
from datetime import datetime
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import Column, String, Integer, Boolean, DateTime, JSON, ForeignKey, Float

logger = logging.getLogger("mausam.db")

from sqlalchemy.engine.url import make_url

is_serverless = bool(
    os.getenv("VERCEL") 
    or os.getenv("VERCEL_ENV")
    or os.getenv("AWS_LAMBDA_FUNCTION_NAME") 
    or os.getenv("AWS_EXECUTION_ENV")
    or os.getenv("LAMBDA_TASK_ROOT")
)

default_db = "sqlite+aiosqlite:////tmp/mausam_local.db" if is_serverless else "sqlite+aiosqlite:///./mausam_local.db"

raw_db_url = (os.getenv("DATABASE_URL") or "").strip()

# Check for empty, placeholder, or keyword strings
if not raw_db_url or raw_db_url.lower() in ("none", "undefined", "null", "your_weather_api_key_here") or "your_" in raw_db_url:
    DATABASE_URL = default_db
else:
    # Normalize Postgres prefixes
    if raw_db_url.startswith("postgres://"):
        raw_db_url = raw_db_url.replace("postgres://", "postgresql+asyncpg://", 1)
    elif raw_db_url.startswith("postgresql://") and "+asyncpg" not in raw_db_url:
        raw_db_url = raw_db_url.replace("postgresql://", "postgresql+asyncpg://", 1)

    # Validate that SQLAlchemy can parse it
    try:
        make_url(raw_db_url)
        DATABASE_URL = raw_db_url
    except Exception as e:
        logger.warning(f"Invalid DATABASE_URL ('{raw_db_url}'): {e}. Falling back to default: {default_db}")
        DATABASE_URL = default_db

# If in serverless and local sqlite path is given, redirect to writable /tmp
if is_serverless and "sqlite" in DATABASE_URL and not DATABASE_URL.startswith("sqlite+aiosqlite:////tmp/"):
    DATABASE_URL = "sqlite+aiosqlite:////tmp/mausam_local.db"

connect_args = {"check_same_thread": False} if "sqlite" in DATABASE_URL else {}

engine = create_async_engine(
    DATABASE_URL,
    echo=False,
    future=True,
    connect_args=connect_args
)

AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

Base = declarative_base()

class DBUser(Base):
    __tablename__ = "users"
    id = Column(String, primary_key=True, index=True)
    phone_number = Column(String, index=True, nullable=True)
    name = Column(String, default="Mausam Citizen")
    onboarding_completed = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class DBUserPersona(Base):
    __tablename__ = "user_personas"
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("users.id"), index=True, nullable=False)
    persona = Column(String, nullable=False)  # health, fitness, beach, travel, family, agriculture, commute, events
    is_primary = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

class DBUserLayout(Base):
    __tablename__ = "user_layouts"
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("users.id"), unique=True, index=True, nullable=False)
    card_order = Column(JSON, default=list)  # list of persona strings
    hidden_cards = Column(JSON, default=list)  # list of hidden persona strings
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class DBSavedLocation(Base):
    __tablename__ = "saved_locations"
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("users.id"), index=True, nullable=False)
    name = Column(String, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    label = Column(String, default="Home")
    is_default = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

_db_initialized = False

async def init_db():
    global _db_initialized
    if _db_initialized:
        return
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        _db_initialized = True
        logger.info("Database initialized successfully.")
    except Exception as e:
        logger.error(f"Database initialization error: {e}")

async def get_db():
    global _db_initialized
    if not _db_initialized:
        try:
            await init_db()
        except Exception:
            pass
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()

