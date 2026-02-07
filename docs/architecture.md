# AgriAgent Architecture

## Logic Flow
Farmer -> Flutter App -> FastAPI -> Antigravity Agent -> Gemini 3 Flash -> Tools

## Components

### 1. Flutter App (Frontend)
- **Role**: Capture input, display output.
- **Key Libraries**: 
    - `camera` (Input)
    - `fl_chart` (Market Analytics)
    - `geolocator` (Location Context)
    - `http` (Weather API)

### 2. FastAPI (Backend)
- **Role**: Orchestration, Auth, API Gateway.
- **Key Modules**: `fastapi`, `uvicorn`.
- **Connectivity**: Configured for `0.0.0.0` access (Local Network).

### 3. Antigravity Agent (Reasoning)
- **Role**: Decision making.
- **Loop**: Observe -> Reason -> Act -> Repeat.
- **Context**: Now receives `lat`, `lon`, and `chat_history`.

### 4. Gemini 3 Flash (Model)
- **Role**: Visual analysis, Speech-to-Text, Common sense reasoning.

### 5. External Services (Real Data)
- **Weather**: Open-Meteo API (Latitude/Longitude based).
- **Market**: Mock Data (Maize) -> Planned: Real Local Prices.
- **Geocoding**: OpenStreetMap (Nominatim) for Reverse Geocoding.

## Data Flow
1. **Diagnosis**: Video -> Backend -> Gemini Vision -> Analysis JSON -> Frontend Card.
2. **Advice**: Voice -> Backend -> STT -> Agent -> Tools -> TTS -> Frontend Audio.
3. **Daily Insights**: Location (GPS) -> Backend -> OpenMeteo/Market -> FarmCard -> Frontend.
