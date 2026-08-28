FROM python:3.11-slim
WORKDIR /app
COPY backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/shared /app/backend/shared
COPY backend/services/alerts_service /app/backend/services/alerts_service
ENV PYTHONPATH=/app
EXPOSE 8005
CMD ["uvicorn", "backend.services.alerts_service.app.main:app", "--host", "0.0.0.0", "--port", "8005"]
