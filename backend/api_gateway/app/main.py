import sys
import os
from typing import Optional

current_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.abspath(os.path.join(current_dir, "../.."))
repo_root = os.path.abspath(os.path.join(current_dir, "../../.."))

for p in [repo_root, backend_dir]:
    if p not in sys.path:
        sys.path.insert(0, p)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse

from backend.api_gateway.app.routers import feed, personas, layout, alerts, auth

app = FastAPI(
    title="Mausam API Gateway (India Meteorological Department)",
    description="Unified API Gateway coordinating real-time personalized weather feed, persona microservices, Redis caching, and WebSocket alert streaming.",
    version="1.0.0"
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

def get_static_dashboard_html() -> Optional[str]:
    search_paths = [
        STATIC_INDEX_PATH,
        os.path.join(os.getcwd(), "backend", "api_gateway", "app", "static", "index.html"),
        os.path.join(repo_root, "backend", "api_gateway", "app", "static", "index.html"),
    ]
    for p in search_paths:
        if os.path.exists(p):
            try:
                with open(p, "r", encoding="utf-8") as f:
                    return f.read()
            except Exception as e:
                print(f"Static read error for {p}: {e}")
    return None

@app.get("/", response_class=HTMLResponse)
@app.get("/api", response_class=HTMLResponse, include_in_schema=False)
@app.get("/api/index.py", response_class=HTMLResponse, include_in_schema=False)
async def serve_root_dashboard():
    content = get_static_dashboard_html()
    if content:
        return HTMLResponse(content=content)
    return HTMLResponse(content="<h1>Mausam API Gateway Online</h1><p>Visit <a href='/docs'>/docs</a> for Swagger UI.</p>")

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "api-gateway",
        "department": "India Meteorological Department (IMD)",
        "version": "1.0.0"
    }


