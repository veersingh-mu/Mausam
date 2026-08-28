FROM python:3.11-slim

WORKDIR /app

COPY backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/shared /app/backend/shared
COPY backend/api_gateway /app/backend/api_gateway
COPY backend/services /app/backend/services

ENV PYTHONPATH=/app

EXPOSE 8000

CMD ["uvicorn", "backend.api_gateway.app.main:app", "--host", "0.0.0.0", "--port", "8000"]
