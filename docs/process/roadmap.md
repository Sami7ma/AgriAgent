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

---

## Release & Distribution (detailed steps)

### 1) Local APK build (quick MVP)

1. Ensure Flutter is installed and `flutter doctor` is clean.
2. From project root run:

```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

3. Result: `frontend/build/app/outputs/flutter-apk/app-release.apk` — shareable.

Notes: Use `--target-platform android-arm64` to optimize for modern devices.

### 2) Automated CI build + GitHub Release (recommended)

We add a GitHub Actions workflow `.github/workflows/android_build_release.yml` that:

- Runs on pushes to `main` and on tag creation.
- Sets up Flutter (matching channel & version), checks out the repo, runs `flutter pub get` and `flutter build apk --release`.
- Uses `actions/create-release` and `actions/upload-release-asset` to create or update a GitHub Release and upload the generated APK.

To enable automatic release-on-tag:

1. Push these changes to `main`.
2. Tag a release locally and push the tag:

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

3. The workflow will run, build the APK, and attach it to a GitHub Release named `v1.0.0`.

### 3) Signing the APK

- For production, create a Keystore and add signing configs to `android/key.properties` and `android/app/build.gradle`.
- Keep the keystore and passwords out of git; use GitHub Secrets for CI signing.

### 4) Post-release checklist

- Test the APK on several devices (arm64 emulator, x86 emulator, physical device).
- Verify network calls (backend reachable via correct IP/10.0.2.2), ensure any environment variables or API keys are set in backend `./backend/.env`.
- Update `docs/architecture.md` release notes with the release tag and changelog.
