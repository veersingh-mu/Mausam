import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.abspath(os.path.join(current_dir, "../.."))
repo_root = os.path.abspath(os.path.join(current_dir, "../../.."))

for p in [repo_root, backend_dir, current_dir]:
    if p not in sys.path:
        sys.path.insert(0, p)

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse

from backend.api_gateway.app.database import init_db
from backend.api_gateway.app.routers import feed, personas, layout, alerts, auth

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Initialize Database tables
    await init_db()
    yield
    # Shutdown

app = FastAPI(
    title="Mausam API Gateway (India Meteorological Department)",
    description="Unified API Gateway coordinating real-time personalized weather feed, persona microservices, Redis caching, and WebSocket alert streaming.",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware for mobile/web app access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount sub-routers
app.include_router(auth.router)
app.include_router(feed.router)
app.include_router(personas.router)
app.include_router(layout.router)
app.include_router(alerts.router)

STATIC_INDEX_PATH = os.path.join(os.path.dirname(__file__), "static", "index.html")

@app.get("/", response_class=FileResponse)
async def serve_root_dashboard():
    if os.path.exists(STATIC_INDEX_PATH):
        return FileResponse(STATIC_INDEX_PATH)
    return {"message": "Mausam API Gateway Online. Visit /docs for Swagger UI."}

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "api-gateway",
        "department": "India Meteorological Department (IMD)",
        "version": "1.0.0"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

