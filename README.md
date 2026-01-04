# AgriAgent: The African Farm Manager

## Overview
AgriAgent is an agentic multimodal agricultural support system powered by **Gemini 3 Flash**. It provides smallholder farmers with:
1.  **Crop Diagnostics**: Video-based disease detection.
2.  **Voice Intelligence**: Multilingual voice advice using Antigravity Agent.
3.  **Daily Farm Card**: Automated daily insights on weather, market, and actions.

## Architecture
- **Frontend**: Flutter (Mobile)
- **Backend**: FastAPI (Python)
- **AI Core**: Google Gemini 1.5 Flash (via `google-generativeai`)
- **Agent Framework**: Antigravity (Custom logic with Token-based reasoning)

## Setup

### Prerequisites
- Python 3.10+
- Flutter SDK
- Google Gemini API Key

### Backend
```bash
cd backend
pip install -r requirements.txt
export GEMINI_API_KEY="your_key_here"
uvicorn main:app --reload
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## Features Implemented
- [x] Video Crop Diagnosis
- [x] Voice Query Interaction
- [x] Agentic Tool Use (Weather, Market)
- [x] Daily Farm Card Artifact
