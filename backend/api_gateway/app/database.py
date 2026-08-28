import os
import json
import logging
from typing import List, Optional
from datetime import datetime
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import Column, String, Integer, Boolean, DateTime, JSON, ForeignKey, Float

logger = logging.getLogger("mausam.db")

is_vercel = os.getenv("VERCEL") == "1" or os.getenv("AWS_LAMBDA_FUNCTION_NAME") is not None
default_db = "sqlite+aiosqlite:////tmp/mausam_local.db" if is_vercel else "sqlite+aiosqlite:///./mausam_local.db"

DATABASE_URL = os.getenv("DATABASE_URL", default_db)

# If in serverless and local sqlite path is given, redirect to writable /tmp
if is_vercel and "sqlite" in DATABASE_URL and not DATABASE_URL.startswith("sqlite+aiosqlite:////tmp/"):
    DATABASE_URL = "sqlite+aiosqlite:////tmp/mausam_local.db"

# If using PostgreSQL in docker/production, postgresql+asyncpg://...
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql+asyncpg://", 1)
elif DATABASE_URL.startswith("postgresql://") and "+asyncpg" not in DATABASE_URL:
    DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://", 1)

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

async def init_db():
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        logger.info("Database initialized successfully.")
    except Exception as e:
        logger.error(f"Database initialization error: {e}")

async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
