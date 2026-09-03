import sys
import os
import traceback

current_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.abspath(os.path.join(current_dir, ".."))
backend_dir = os.path.abspath(os.path.join(repo_root, "backend"))

for p in [repo_root, backend_dir]:
    if p not in sys.path:
        sys.path.insert(0, p)

try:
    from backend.api_gateway.app.main import app as base_app
except Exception as e:
    import traceback
    traceback.print_exc()
    from fastapi import FastAPI
    from fastapi.responses import HTMLResponse, JSONResponse

    base_app = FastAPI(title="Mausam API Gateway (Startup Fallback)")
    error_detail = traceback.format_exc()

    @base_app.get("/")
    async def fallback_root():
        return HTMLResponse(
            f"<h1>Mausam API Gateway Initialization Warning</h1>"
            f"<p>The application encountered an issue during module loading:</p>"
            f"<pre style='background:#f4f4f4;padding:12px;border-radius:6px;overflow-x:auto;'>{error_detail}</pre>"
        )

    @base_app.get("/health")
    async def fallback_health():
        return JSONResponse(
            status_code=500,
            content={"status": "initialization_error", "error": str(e), "traceback": error_detail}
        )

class VercelPathCorrectionMiddleware:
    """
    Vercel ASGI path helper: Ensures bare /api or /api/index.py requests gracefully serve root dashboard,
    while passing through all real endpoints (/health, /docs, /api/v1/...) unchanged.
    """
    def __init__(self, asgi_app):
        self.asgi_app = asgi_app

    async def __call__(self, scope, receive, send):
        if scope.get("type") in ("http", "websocket"):
            path = scope.get("path", "")
            if path in ("/api/index.py", "/api/index", "/api"):
                scope["path"] = "/"
                scope["raw_path"] = b"/"
            elif path.startswith("/api/index.py/"):
                clean_path = path[len("/api/index.py"):]
                scope["path"] = clean_path
                scope["raw_path"] = clean_path.encode("latin1")

        await self.asgi_app(scope, receive, send)

# Export for ASGI serverless runtime
app = VercelPathCorrectionMiddleware(base_app)
