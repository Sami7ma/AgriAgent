# AgriAgent Architecture

## Logic Flow
Farmer -> Flutter App -> FastAPI -> Antigravity Agent -> Gemini 3 Flash -> Tools

## Components

### 1. Flutter App (Frontend)
- **Role**: Capture input, display output.
- **Key Libraries**: `camera`, `flutter_sound`, `provider`.

### 2. FastAPI (Backend)
- **Role**: Orchestration, Auth, API Gateway.
- **Key Modules**: `fastapi`, `uvicorn`.

### 3. Antigravity Agent (Reasoning)
- **Role**: Decision making.
- **Loop**: Observe -> Reason -> Act -> Repeat.

### 4. Gemini 3 Flash (Model)
- **Role**: Visual analysis, Speech-to-Text, Common sense reasoning.

## Data Flow
1. **Diagnosis**: Video -> Backend -> Gemini Vision -> Analysis JSON -> Frontend Card.
2. **Advice**: Voice -> Backend -> STT -> Agent -> Tools -> TTS -> Frontend Audio.
