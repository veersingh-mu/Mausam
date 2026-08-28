import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.join(current_dir, "backend")

for p in [current_dir, backend_dir]:
    if p not in sys.path:
        sys.path.insert(0, p)

from backend.api_gateway.app.main import app

# Export ASGI application for Vercel Serverless
app = app
