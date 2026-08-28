import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.abspath(os.path.join(current_dir, ".."))
backend_dir = os.path.abspath(os.path.join(repo_root, "backend"))

for p in [repo_root, backend_dir, current_dir]:
    if p not in sys.path:
        sys.path.insert(0, p)

from backend.api_gateway.app.main import app
