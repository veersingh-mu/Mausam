# 🌦️ Mausam (मौसम) - Hyper-local Persona-Driven Weather Intelligence Platform

[![CI/CD](https://github.com/veersingh-mu/Mausam/actions/workflows/ci.yml/badge.svg)](https://github.com/veersingh-mu/Mausam/actions)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110.0-009688.svg?logo=fastapi)](https://fastapi.tiangolo.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter)](https://flutter.dev)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg?logo=docker)](https://www.docker.com)
[![Vercel](https://img.shields.io/badge/Vercel-Serverless-000000.svg?logo=vercel)](https://vercel.com)

**Mausam** is an intelligent, hyper-local weather platform tailored for India. Built on top of official meteorological data from the **India Meteorological Department (IMD)**, **CPCB (Air Quality)**, and **INCOIS (Ocean & Marine)**, Mausam dynamically synthesizes actionable, persona-driven feeds for athletes, commuters, farmers, coastal fishers, travelers, families, and event planners.

---

## 🌟 Key Features

* **🎭 8 Contextual Personas**:
  * 🏃 **Fitness / Runners**: Golden workout hours, heat index, and readiness scores.
  * 🏥 **Health & Air Quality**: Real-time AQI, PM2.5, PM10, and tailored respiratory warnings.
  * 🚗 **Daily Commuters**: Rainfall, fog visibility, route disruption, and monsoon waterlogging alerts.
  * 🌾 **Agriculture & Agromet**: Soil moisture, evapotranspiration, optimal sowing/harvesting windows, and pest risk.
  * 🌊 **Coastal & Marine**: Tide schedules, wave heights, swell direction, and safe fishing zones.
  * ✈️ **Travelers & Tourism**: Multi-day trip forecast, packing checklists, and flight weather hazards.
  * 👨‍👩‍👧 **Family & Weekend**: UV safe playtime, park suitability, and weekend rain radars.
  * 🎪 **Outdoor Event Planners**: Hourly precipitation probability and gust wind thresholds.
* **📱 Ultra-Responsive Mobile Homepage Card**:
  * Fluid CSS `clamp()` & Flutter `LayoutBuilder` scaling (320px small mobile to 1024px+ tablets).
  * Auto-truncating city headers with safe-area spacing and 44px accessible touch targets.
  * Day/night intelligent dual-tone weather condition illustrations.
* **🔍 Instant City Search**:
  * 36+ major Indian cities pre-indexed with relevance scoring and live weather querying.
* **⚡ Concurrent Fanout API Gateway**:
  * Microservice architecture with Redis/memory caching, asynchronous fanout aggregation, and SQLite/PostgreSQL persistence.

---

## 🏗️ Architecture Overview

```
                          ┌───────────────────────────┐
                          │   Flutter App / Web UI    │
                          └─────────────┬─────────────┘
                                        │ HTTP / WS
                                        ▼
                          ┌───────────────────────────┐
                          │   FastAPI API Gateway     │
                          │   (/api/v1/homepage-feed) │
                          └─────────────┬─────────────┘
                                        │ Async Fanout
            ┌──────────────┬────────────┼────────────┬──────────────┐
            ▼              ▼            ▼            ▼              ▼
     ┌─────────────┐ ┌───────────┐ ┌─────────┐ ┌───────────┐ ┌─────────────┐
     │ AQI Service │ │AgriService│ │ Marine  │ │ Traffic   │ │Alerts Engine│
     │  (CPCB API) │ │(IMD Agri) │ │ (INCOIS)│ │(Maps/IMD) │ │ (FCM / WS)  │
     └─────────────┘ └───────────┘ └─────────┘ └───────────┘ └─────────────┘
            │              │            │            │              │
            └──────────────┴────────────┼────────────┴──────────────┘
                                        ▼
                          ┌───────────────────────────┐
                          │   Redis Cache / DB Layer  │
                          └───────────────────────────┘
```

---

## 🚀 Quickstart

### 1. Run with Docker Compose (Recommended for Local Full-Stack)

```bash
# Clone the repository
git clone https://github.com/veersingh-mu/Mausam.git
cd Mausam

# Copy environment variables
cp .env.example .env

# Start all microservices, Redis, and PostgreSQL
docker-compose up --build
```
* **API Gateway & Web Dashboard**: `http://localhost:8000`
* **Swagger API Docs**: `http://localhost:8000/docs`

---

### 2. Run Local Python FastAPI Gateway

```bash
# Install dependencies
pip install -r requirements.txt

# Run the API Gateway
uvicorn backend.api_gateway.app.main:app --reload --port 8000
```

---

### 3. Run Flutter Native App

```bash
cd frontend
flutter pub get
flutter run
```

---

### 4. Deploy to Vercel (Serverless)

Mausam is pre-configured with `pyproject.toml`, `vercel.json`, and `api/index.py` for one-click Vercel deployments:
1. Import repository on [Vercel](https://vercel.com/new).
2. Configure environment variables (`WEATHER_API_KEY`, `IMD_CORE_API_KEY`).
3. Deploy! Vercel will automatically build and route requests to the FastAPI Gateway.

---

## 📊 API Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/` | Serves the interactive Mausam Web Dashboard |
| `GET` | `/api/v1/homepage-feed` | Fetches personalized composite weather cards |
| `PUT` | `/api/v1/users/{id}/personas` | Updates user selected persona preferences |
| `PUT` | `/api/v1/users/{id}/layout` | Reorders or toggles card visibility |
| `GET` | `/api/v1/alerts/active` | Retrieves active severe meteorological alerts |
| `WS` | `/ws/alerts` | Real-time WebSocket stream for severe weather warnings |

---

## 📱 Stitch Design System Assets

| # | Screen Name | HTML Template |
|---|---|---|
| 01 | **Mausam - Commute Details** | [`screens/01_mausam_commute_details/`](file:///screens/01_mausam_commute_details/index.html) |
| 02 | **Mausam - Fitness Details** | [`screens/02_mausam_fitness_details/`](file:///screens/02_mausam_fitness_details/index.html) |
| 03 | **Mausam - Travel Details** | [`screens/03_mausam_travel_details/`](file:///screens/03_mausam_travel_details/index.html) |
| 04 | **Mausam - Health Details** | [`screens/04_mausam_health_details/`](file:///screens/04_mausam_health_details/index.html) |
| 05 | **Mausam - Family Details** | [`screens/05_mausam_family_details/`](file:///screens/05_mausam_family_details/index.html) |
| 06 | **Mausam Home - Marine Active** | [`screens/06_mausam_home_marine_active/`](file:///screens/06_mausam_home_marine_active/index.html) |
| 07 | **Mausam - Event Planner Details** | [`screens/07_mausam_event_planner_details/`](file:///screens/07_mausam_event_planner_details/index.html) |
| 08 | **Mausam - Customize Homepage** | [`screens/08_mausam_customize_homepage/`](file:///screens/08_mausam_customize_homepage/index.html) |
| 09 | **Mausam Home - Default** | [`screens/09_mausam_home_default/`](file:///screens/09_mausam_home_default/index.html) |
| 10 | **Mausam - Marine Details - Tide Priority** | [`screens/10_mausam_marine_details_tide_priority/`](file:///screens/10_mausam_marine_details_tide_priority/index.html) |
| 11 | **Design System Tokens** | [`design_system/DESIGN.md`](file:///design_system/DESIGN.md) |
