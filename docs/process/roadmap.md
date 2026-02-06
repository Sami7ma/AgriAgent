# AgriAgent Production Roadmap

This document outlines the step-by-step plan to upgrade AgriAgent from a prototype to a production-ready application.

## Phase 1: Architecture Refactoring (The Foundation)
**Goal:** Break the monolithic `main.dart` into a clean, maintainable structure.

### 1.1 Folder Structure Setup
- [ ] Create directory hierarchy:
    - `lib/models/` (Data structures)
    - `lib/services/` (API and Logic)
    - `lib/screens/` (Full page methods)
    - `lib/widgets/` (Reusable UI components)
    - `lib/utils/` (Helpers like constants)

### 1.2 Logic Extraction (The "Brains")
- [ ] **Models**: Move `FarmCard`, `DiagnosisResponse` (currently implied types) into explicit Dart classes in `lib/models/`.
- [ ] **API Service**: Create `ApiService` in `lib/services/api_service.dart` to handle all Dio calls (`_fetchCard`, `_uploadAndAnalyze`, Chat).
- [ ] **Location Service**: Extract `Geolocator` logic into `lib/services/location_service.dart`.

### 1.3 UI Extraction (The "Looks")
- [ ] **Widgets**: Extract `ChatWidget`, `FarmCard`, `ImageSection` into their own files in `lib/widgets/`.
- [ ] **Screens**: Move `DiagnosisScreen` to `lib/screens/home_screen.dart`.
- [ ] **Entry Point**: Clean `main.dart` to only contain `MaterialApp`, Theme config, and Routes.

### 1.4 Verification & Git
- [ ] Run app to ensure nothing broke during the move.
- [ ] `git commit` and `git push`.

---

## Phase 2: Real Data Integration (The Value)
**Goal:** Replace random/mock data with live real-world data.

### 2.1 Backend Weather & Market
- [ ] **Weather**: Sign up for OpenWeatherMap (Free Tier). Update `backend/app/antigravity/tools.py` to fetch real weather for the resolved location.
- [ ] **Market Prices**: Find a data source (or create a better mock with CSV/database) for market prices.

### 2.2 Knowledge Base (RAG)
- [ ] Enhance conversational agent to search through a local PDF/Text manual of agricultural best practices instead of generic LLM knowledge.

---

## Phase 3: Robustness & Testing (The Shield)
**Goal:** Ensure reliability and prevent regressions.

### 3.1 State Management
- [ ] Implement `Provider` or `Riverpod` to handle state (instead of `setState` everywhere). This makes the app more stable during rotation or tab switching.

### 3.2 Testing
- [ ] **Unit Tests**: Test the JSON parsing and Service logic.
- [ ] **Widget Tests**: Verify that the "Daily Application" card renders correctly with data.

---

## Phase 4: Production Polish
- [ ] **Error Handling**: Better "Offline" screens.
- [ ] **App Icon & Splash**: Finalize branding (Icon done).
- [ ] **Release Build**: Generate signed APK/AppBundle.
