FROM python:3.11-slim
WORKDIR /app
COPY backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/shared /app/backend/shared
COPY backend/services/agri_service /app/backend/services/agri_service
ENV PYTHONPATH=/app
EXPOSE 8003
CMD ["uvicorn", "backend.services.agri_service.app.main:app", "--host", "0.0.0.0", "--port", "8003"]
