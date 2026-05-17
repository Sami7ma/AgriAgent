# STILLTODO: AgriAgent Future Roadmap - Phases 2, 3, and 4

**Document Created:** May 17, 2026  
**Status:** Post Phase 1 - Production Ready  
**Planning Horizon:** 6-8 weeks  
**Last Updated:** May 17, 2026

---

## Overview

This document outlines all remaining work for AgriAgent after Phase 1 completion. It includes detailed specifications, implementation steps, and dependencies for Phases 2, 3, and 4.

**Status Summary:**
- ✅ Phase 1: Complete (Security & UI Fixes)
- 🟡 Phase 2: Ready to start (Week of May 20-26)
- 🟡 Phase 3: Planned (Week of May 27-June 2)
- 🔴 Phase 4: Ongoing enhancement

---

## 📊 All Remaining Issues from Audit

### From AUDIT_FINDINGS.md - Issues Not Yet Fixed

#### Security Issues (4 remaining)
| # | Issue | Phase | Priority | Est. Time |
|---|-------|-------|----------|-----------|
| 7 | Rate Limiting Per Endpoint | 2 | HIGH | 45 min |
| 8 | HTTPS Certificate Pinning | 2 | HIGH | 60 min |
| 9 | API Key Exposure Risk (Frontend) | 3 | MEDIUM | 30 min |
| 10 | Insufficient Security Logging | 3 | MEDIUM | 40 min |

#### Missing Features (10 remaining)
| # | Feature | Phase | Priority | Est. Time |
|---|---------|-------|----------|-----------|
| 1 | Voice Output (Text-to-Speech) | 2 | HIGH | 90 min |
| 2 | Voice Input UI Complete | 2 | HIGH | 75 min |
| 3 | Cloud Chat Sync | 3 | HIGH | 120 min |
| 4 | Real Market API Integration | 3 | HIGH | 90 min |
| 5 | Market Price Endpoint (backend) | 3 | MEDIUM | 60 min |
| 6 | Chat History Export (CSV/PDF) | 3 | MEDIUM | 90 min |
| 7 | Language Support Backend | 3 | MEDIUM | 75 min |
| 8 | Crop Health Score Persistence | 3 | MEDIUM | 60 min |
| 9 | Personalized Recommendations | 4 | MEDIUM | 90 min |
| 10 | iOS Support | 4 | MEDIUM | 120 min |

#### UI/UX Issues (6 remaining)
| # | Issue | Phase | Priority | Est. Time |
|---|-------|-------|----------|-----------|
| 1 | Accessibility (Screen Readers) | 2 | HIGH | 60 min |
| 2 | Empty State with Quick Actions | 2 | HIGH | 40 min |
| 3 | Mobile Responsiveness | 2 | MEDIUM | 45 min |
| 4 | Skeleton Loading States | 3 | MEDIUM | 50 min |
| 5 | Confirmation Dialogs | 3 | MEDIUM | 30 min |
| 6 | Better Error Recovery | 3 | LOW | 40 min |

---

## 🟡 PHASE 2: High-Priority Features (Week 2)

**Timeline:** Week of May 20-26, 2026  
**Estimated Duration:** 5-7 days  
**Priority Level:** HIGH - Core functionality improvements  
**Blocked By:** Nothing - Can start immediately  

### Phase 2 Goals
- ✅ Complete voice feature implementation
- ✅ Add accessibility support
- ✅ Improve error handling
- ✅ Enhance security (cert pinning)
- ✅ Better mobile UX

---

## 📋 Phase 2 Detailed Tasks

### Task 2.1: Complete Voice Input UI ⏳

**Objective:** Enable voice-to-text input for hands-free farming

**Current State:**
- Backend: ✅ Ready (VoiceService exists)
- Frontend: ❌ Disabled (enableVoiceInput = false)
- UI Widget: ❌ Missing

**Implementation Steps:**

1. **Enable Voice Feature Flag**
   - File: `frontend/lib/utils/constants.dart`
   - Change: `enableVoiceInput = false` → `true`
   - Time: 2 min

2. **Add Microphone Button to UI**
   - File: `frontend/lib/screens/chat_screen.dart`
   - Location: Next to text input field
   - Icon: Icons.mic (or Icons.mic_none)
   - Behavior: Show recording indicator when pressed
   - Time: 20 min
   - Code snippet:
   ```dart
   FloatingActionButton(
       onPressed: _recordVoiceMessage,
       tooltip: 'Record voice message',
       child: Icon(Icons.mic),
   )
   ```

3. **Implement Voice Recording**
   - File: `frontend/lib/services/voice_service.dart`
   - Package: `speech_to_text` (add to pubspec.yaml)
   - Features:
     - Start/stop recording
     - Show waveform during recording
     - Display transcribed text
     - Handle permissions
   - Time: 45 min

4. **Add Voice Recording Permission**
   - File: `android/app/src/main/AndroidManifest.xml`
   - Permission: RECORD_AUDIO
   - File: `ios/Runner/Info.plist`
   - Key: NSMicrophoneUsageDescription
   - Time: 10 min

5. **Create Voice Message Widget**
   - File: `frontend/lib/widgets/voice_message_widget.dart` (NEW)
   - Shows recording indicator
   - Displays waveform
   - Shows transcript as it's being recognized
   - Time: 30 min

6. **Test Voice Recording End-to-End**
   - Record message → Send to backend
   - Verify transcription accuracy
   - Test permission handling
   - Time: 30 min

**Dependencies:**
- `speech_to_text: ^6.1.1`
- `permission_handler: ^12.0.1` (already have)

**Acceptance Criteria:**
- [ ] Microphone button visible in chat
- [ ] Recording indicator shows
- [ ] Text transcribed in real-time
- [ ] Message sent after recording
- [ ] Permissions handled gracefully

**Estimated Effort:** 75 minutes  
**Priority:** HIGH

---

### Task 2.2: Implement Voice Output (Text-to-Speech) ⏳

**Objective:** Bot responses played as audio for hands-free interaction

**Current State:**
- Backend: ❌ Missing (audio_url field exists but unused)
- Frontend: ❌ Missing (no playback widget)

**Implementation Steps:**

1. **Create Text-to-Speech Service**
   - File: `backend/app/services/tts.py` (NEW)
   - Package: `google-cloud-texttospeech` (add to requirements.txt)
   - Features:
     - Convert response text to audio
     - Support multiple languages
     - Cache audio files
     - Return audio URL or file path
   - Time: 45 min
   - Code template:
   ```python
   from google.cloud import texttospeech
   
   class TextToSpeechService:
       async def synthesize_speech(self, text: str, language: str = "en-US") -> str:
           # Convert text to speech using Google API
           # Store in cloud storage or temp file
           # Return URL or file path
           pass
   ```

2. **Integrate TTS into Agent Response**
   - File: `backend/app/antigravity/core.py`
   - When generating response, also generate audio
   - Attach audio_url to response
   - Time: 25 min
   - Logic:
     ```python
     response_text = generate_response(query)
     audio_url = await tts_service.synthesize_speech(response_text)
     return {
         "response_text": response_text,
         "audio_url": audio_url,
         "suggested_actions": actions
     }
     ```

3. **Add Audio Playback Widget**
   - File: `frontend/lib/widgets/audio_player_widget.dart` (NEW)
   - Package: `audioplayers: ^3.0.0`
   - Features:
     - Play/pause button
     - Duration slider
     - Loading indicator
     - Speed controls (optional)
   - Time: 35 min

4. **Integrate Audio Playback in Chat**
   - File: `frontend/lib/screens/chat_screen.dart`
   - Show audio player below bot messages
   - Auto-play option (setting)
   - Time: 25 min

5. **Add Audio Settings**
   - File: `frontend/lib/screens/settings_screen.dart` or new section
   - Options:
     - Auto-play audio: ON/OFF
     - Voice speed: 0.5x - 2.0x
     - Language selection
   - Time: 30 min

6. **Configure Google Cloud TTS**
   - Set up Google Cloud project
   - Enable Text-to-Speech API
   - Create service account
   - Add credentials to backend
   - Time: 20 min

**Dependencies:**
- Backend: `google-cloud-texttospeech>=2.12.0`
- Frontend: `audioplayers: ^3.0.0`
- Cloud: Google Cloud account with TTS enabled

**Acceptance Criteria:**
- [ ] Audio generated for all bot responses
- [ ] Play button appears below messages
- [ ] Audio plays correctly
- [ ] Speed control works
- [ ] Auto-play setting works
- [ ] Multiple language support

**Estimated Effort:** 90 minutes  
**Priority:** HIGH

---

### Task 2.3: Add HTTPS Certificate Pinning ⏳

**Objective:** Prevent Man-in-the-Middle (MITM) attacks on API calls

**Current State:**
- ❌ No certificate pinning in Dio client

**Implementation Steps:**

1. **Generate Certificate Pin**
   - Get API server certificate
   - Extract public key hash
   - Time: 10 min
   - Command:
   ```bash
   openssl s_client -connect api.yourdomain.com:443 -showcerts
   # Extract cert, get SHA256 hash of public key
   ```

2. **Configure Dio with Certificate Pinning**
   - File: `frontend/lib/services/api_service.dart`
   - Time: 30 min
   - Code:
   ```dart
   import 'dart:io';
   import 'package:dio/io.dart';
   
   final securityContext = SecurityContext.defaultContext;
   
   _dio.httpClientAdapter = IOHttpClientAdapter(
       createHttpClient: () => HttpClient(context: securityContext)
   );
   
   // Configure pinning
   securityContext.setTrustedCertificates('path/to/cert.pem');
   ```

3. **Add Certificate to Flutter Project**
   - Store certificate in `assets/certificates/`
   - Update pubspec.yaml to include asset
   - Time: 10 min

4. **Test Certificate Pinning**
   - Test with valid certificate
   - Test with invalid/expired certificate (should fail)
   - Test on real device
   - Time: 30 min

**Dependencies:**
- `dio/io.dart` (included in Dio)

**Acceptance Criteria:**
- [ ] Certificate pinning implemented
- [ ] Valid certificates accepted
- [ ] Invalid certificates rejected
- [ ] Works on real device
- [ ] No performance impact

**Estimated Effort:** 60 minutes  
**Priority:** HIGH

---

### Task 2.4: Add Accessibility Support (Screen Readers) ⏳

**Objective:** Support users with visual impairments using screen readers

**Current State:**
- ❌ No Semantics widgets
- ❌ No accessibility labels

**Implementation Steps:**

1. **Add Semantics to Icons**
   - Files: All screens with icons
   - Time: 30 min
   - Template:
   ```dart
   Semantics(
       label: "Microphone button for recording",
       button: true,
       enabled: true,
       onTap: _recordVoice,
       child: Icon(Icons.mic)
   )
   ```

2. **Add Labels to Buttons**
   - Files: All interactive widgets
   - Wrap Buttons with Semantics
   - Time: 20 min

3. **Make Text Scalable**
   - Check all TextStyles use dynamic sizing
   - Use MediaQuery.textScaleFactorOf(context)
   - Time: 25 min

4. **Add High Contrast Mode**
   - File: `frontend/lib/utils/theme.dart` (or constants.dart)
   - Option: Detect system high contrast setting
   - Time: 20 min

5. **Test with Screen Reader**
   - Android: Use TalkBack
   - iOS: Use VoiceOver
   - Verify all buttons/content readable
   - Time: 35 min

**Acceptance Criteria:**
- [ ] All buttons have semantic labels
- [ ] Screen reader can navigate app
- [ ] Text scales properly
- [ ] High contrast option works
- [ ] All features accessible

**Estimated Effort:** 60 minutes  
**Priority:** HIGH

---

### Task 2.5: Empty Chat State with Quick Actions ⏳

**Objective:** Guide users on app launch with example queries

**Current State:**
- ❌ Just shows greeting message
- ❌ No examples or guidance

**Implementation Steps:**

1. **Create Quick Actions Widget**
   - File: `frontend/lib/widgets/quick_actions_widget.dart` (NEW)
   - Time: 20 min
   - Shows 6 example queries as button chips

2. **Add Empty State UI**
   - File: `frontend/lib/screens/chat_screen.dart`
   - Show when message list empty
   - Display:
     - Welcome message
     - Quick action buttons
     - Help text
   - Time: 25 min

3. **Define Example Queries**
   - Crop disease examples: "What's wrong with my maize leaves?"
   - Market queries: "What's the price of coffee today?"
   - Weather queries: "Is rain expected this week?"
   - Tips: "How do I improve soil health?"
   - Time: 10 min

4. **Implement Button Tap Handlers**
   - When user taps example, add to input
   - Auto-send option (setting)
   - Time: 15 min

5. **Add Onboarding Tips**
   - Show tips on first launch
   - Use SharedPreferences to track first launch
   - Time: 20 min

**Acceptance Criteria:**
- [ ] Empty state shows on new chat
- [ ] Quick actions visible and clickable
- [ ] Tapping example fills input
- [ ] Onboarding shows first time
- [ ] Can dismiss tips

**Estimated Effort:** 40 minutes  
**Priority:** HIGH

---

### Task 2.6: Per-Endpoint Rate Limiting ⏳

**Objective:** Protect expensive endpoints from abuse

**Current State:**
- ⚠️ Global rate limiting only (backend/main.py)
- ❌ No per-endpoint limits

**Implementation Steps:**

1. **Define Endpoint Rate Limits**
   - Expensive endpoints (analysis, voice):10 req/min
   - Standard endpoints (query): 100 req/min
   - Public endpoints (health): 1000 req/min
   - Time: 10 min

2. **Create Rate Limiting Middleware**
   - File: `backend/app/middleware/rate_limit.py` (NEW)
   - Track per API key, not just IP
   - Use Redis for distributed systems
   - Time: 40 min
   - Code template:
   ```python
   async def rate_limit_per_endpoint(request: Request, api_key: str):
       endpoint = request.url.path
       limit = ENDPOINT_LIMITS.get(endpoint, 100)
       current_count = await get_request_count(api_key, endpoint)
       
       if current_count >= limit:
           raise HTTPException(status_code=429, detail="Rate limit exceeded")
       
       await increment_request_count(api_key, endpoint)
   ```

3. **Apply Rate Limiting Decorators**
   - File: `backend/app/api.py`
   - Decorate expensive endpoints
   - Time: 20 min

4. **Add Rate Limit Headers**
   - Return X-RateLimit-* headers
   - Show remaining requests to client
   - Time: 15 min

5. **Test Rate Limiting**
   - Exceed limit, verify 429 response
   - Verify headers present
   - Time: 20 min

**Dependencies:**
- `redis>=4.0.0` (for production)
- In-memory for development

**Acceptance Criteria:**
- [ ] Expensive endpoints limited
- [ ] Per-endpoint limits enforced
- [ ] Rate limit headers present
- [ ] 429 responses correct
- [ ] Works with multiple API keys

**Estimated Effort:** 45 minutes  
**Priority:** HIGH

---

### Task 2.7: Mobile Responsiveness Improvements ⏳

**Objective:** Optimize UI for tablets and larger screens

**Current State:**
- ⚠️ Works on phones, needs tablet optimization

**Implementation Steps:**

1. **Analyze Current Layout**
   - Test on tablet (landscape/portrait)
   - Identify issues
   - Time: 15 min

2. **Use ResponsiveLayout Widget**
   - File: `frontend/lib/widgets/responsive_layout.dart` (NEW)
   - Show different layouts for mobile/tablet
   - Time: 25 min
   - Template:
   ```dart
   ResponsiveLayout(
       mobile: MobileChatScreen(),
       tablet: TabletChatScreen(),
   )
   ```

3. **Create Tablet Chat Layout**
   - File: `frontend/lib/screens/tablet_chat_screen.dart` (NEW)
   - Split screen: messages + quick actions
   - Larger message bubbles
   - Side panel for crop info
   - Time: 40 min

4. **Optimize Message Bubbles**
   - Adjust width based on screen size
   - Max width on tablets: 60% of screen
   - Time: 20 min

5. **Test on Multiple Devices**
   - Phone: 6" screen
   - Tablet: 10" screen
   - Landscape mode
   - Time: 30 min

**Acceptance Criteria:**
- [ ] Works on tablets
- [ ] Landscape mode responsive
- [ ] Content readable on all sizes
- [ ] No horizontal scrolling
- [ ] Touch targets adequate

**Estimated Effort:** 45 minutes  
**Priority:** MEDIUM

---

## Phase 2 Summary

| Task | Time | Priority | Status |
|------|------|----------|--------|
| Voice Input UI | 75 min | HIGH | 🟡 Ready |
| Voice Output (TTS) | 90 min | HIGH | 🟡 Ready |
| Certificate Pinning | 60 min | HIGH | 🟡 Ready |
| Accessibility | 60 min | HIGH | 🟡 Ready |
| Quick Actions | 40 min | HIGH | 🟡 Ready |
| Rate Limiting | 45 min | HIGH | 🟡 Ready |
| Responsive UI | 45 min | MEDIUM | 🟡 Ready |

**Phase 2 Total Effort:** ~415 minutes (~7 hours)  
**Recommended Timeline:** 1 week (May 20-26)

---

## 🔴 PHASE 3: Medium-Priority Features (Week 3-4)

**Timeline:** Week of May 27-June 2, 2026 + Following week  
**Estimated Duration:** 10-14 days  
**Priority Level:** MEDIUM - Feature completeness  

### Phase 3 Goals
- ✅ Cloud data persistence
- ✅ Real API integrations
- ✅ Export functionality
- ✅ Multi-language support
- ✅ Enhanced UI polish

---

## 📋 Phase 3 Detailed Tasks

### Task 3.1: Cloud Chat Sync with Database ⏳

**Objective:** Persist chat history to cloud, enable sync across devices

**Blocked By:** Nothing - can start now but requires database setup

**Implementation Steps:**

1. **Database Setup**
   - On Render: Add PostgreSQL database
   - Migrations: Create tables
   - Time: 30 min
   - Tables needed:
     ```sql
     CREATE TABLE users (
         id UUID PRIMARY KEY,
         api_key TEXT UNIQUE,
         created_at TIMESTAMP
     );
     
     CREATE TABLE chat_sessions (
         id UUID PRIMARY KEY,
         user_id UUID REFERENCES users,
         title TEXT,
         created_at TIMESTAMP,
         updated_at TIMESTAMP
     );
     
     CREATE TABLE chat_messages (
         id UUID PRIMARY KEY,
         session_id UUID REFERENCES chat_sessions,
         role TEXT (user/bot),
         content TEXT,
         timestamp TIMESTAMP
     );
     ```

2. **Create ORM Models**
   - File: `backend/app/models.py` (NEW or extend)
   - Use SQLAlchemy
   - Time: 30 min

3. **Add Sync Endpoints**
   - File: `backend/app/api.py`
   - Endpoints:
     - `POST /chat/sessions` - Create session
     - `GET /chat/sessions` - List sessions
     - `POST /chat/messages` - Send message
     - `GET /chat/messages/{session_id}` - Fetch history
     - `DELETE /chat/sessions/{session_id}` - Delete session
   - Time: 60 min
   - Require API key on all endpoints

4. **Update Frontend Chat Service**
   - File: `frontend/lib/services/chat_service.dart`
   - Instead of local storage, use API
   - Keep local cache for offline support
   - Time: 45 min
   - Logic:
     ```dart
     // Save locally immediately
     await localStorage.save(message);
     
     // Sync to server
     try {
         await apiService.syncMessage(message);
     } catch (e) {
         // Retry later if fails
     }
     ```

5. **Implement Conflict Resolution**
   - If message sent offline, then device goes online
   - Use timestamps to resolve conflicts
   - Time: 30 min

6. **Add Sync Status Indicator**
   - File: `frontend/lib/widgets/sync_status_widget.dart` (NEW)
   - Show: Syncing, Synced, Error
   - Time: 20 min

7. **Test Cloud Sync**
   - Send message, verify in database
   - Load on another device, verify history
   - Test offline then online
   - Time: 40 min

**Dependencies:**
- Backend: `sqlalchemy>=2.0.0`, `alembic>=1.10.0`, PostgreSQL
- Frontend: `http>=1.2.0` (already have)

**Acceptance Criteria:**
- [ ] Chat sessions saved to database
- [ ] Messages synced to cloud
- [ ] History retrieves from cloud
- [ ] Offline support with local cache
- [ ] Sync status shown to user
- [ ] Conflict resolution works

**Estimated Effort:** 120 minutes  
**Priority:** HIGH

---

### Task 3.2: Real Market API Integration ⏳

**Objective:** Use real commodity prices instead of mock data

**Current State:**
- ⚠️ Market endpoint exists but uses mock data
- ⚠️ Backend service configured but not fully integrated

**Implementation Steps:**

1. **Choose Real API**
   - Options:
     - Commodities API (commodities-api.com)
     - USDA API (free, US-focused)
     - World Bank API (global data)
   - Recommendation: Commodities API (most reliable)
   - Time: 10 min

2. **Get API Credentials**
   - Sign up for Commodities API
   - Get API key
   - Add to Render environment: `COMMODITIES_API_KEY`
   - Time: 10 min

3. **Implement Real Price Fetching**
   - File: `backend/app/services/market.py`
   - Replace mock data with real API calls
   - Implement caching (1 hour TTL)
   - Handle API failures gracefully
   - Time: 40 min
   - Code template:
   ```python
   async def get_real_price(self, crop: str) -> float:
       # Check cache first
       cached = await cache.get(f"price_{crop}")
       if cached:
           return cached
       
       # Fetch from API
       response = await httpx.get(
           f"https://api.commodities-api.com/v1/latest",
           params={"api_key": COMMODITIES_API_KEY, "symbols": crop}
       )
       
       # Cache result
       await cache.set(f"price_{crop}", result, ttl=3600)
       return result
   ```

4. **Add Regional Price Adjustments**
   - File: `backend/app/services/market.py`
   - Apply local multipliers for currency
   - Example: USD price * 150 = KES price
   - Time: 20 min

5. **Implement Fallback to Mock Data**
   - If real API fails, use mock
   - Log failures for monitoring
   - Time: 15 min

6. **Add Price Trending**
   - File: `backend/app/api.py`
   - Return today, yesterday, week ago prices
   - Show trend: up/down/stable
   - Time: 25 min

7. **Update Frontend to Use Trending**
   - File: `frontend/lib/widgets/market_chart.dart`
   - Display price chart with history
   - Time: 30 min

8. **Test Market Integration**
   - Fetch prices for different crops/regions
   - Verify cache working
   - Test fallback when API down
   - Time: 20 min

**Dependencies:**
- Backend: `httpx>=0.24.0` (HTTP client with async support)
- Frontend: `fl_chart: ^0.66.0` (already have)

**Acceptance Criteria:**
- [ ] Real prices fetched from API
- [ ] Prices cached for performance
- [ ] Fallback to mock if API down
- [ ] Regional pricing works
- [ ] Charts display trends
- [ ] Updates periodically

**Estimated Effort:** 90 minutes  
**Priority:** HIGH

---

### Task 3.3: Chat History Export (CSV/PDF) ⏳

**Objective:** Allow users to export chat history

**Current State:**
- ❌ Not implemented

**Implementation Steps:**

1. **Create Export Service**
   - File: `backend/app/services/export.py` (NEW)
   - Formats: CSV, PDF
   - Time: 40 min

2. **Add Backend Endpoint**
   - File: `backend/app/api.py`
   - Endpoint: `GET /chat/sessions/{id}/export?format=csv|pdf`
   - Returns file download
   - Time: 25 min

3. **CSV Export**
   - Format: timestamp, role (user/bot), message
   - Save to cloud storage or temp file
   - Time: 20 min

4. **PDF Export**
   - Use `reportlab` package
   - Include:
     - Session title
     - Chat history with timestamps
     - Session metadata
   - Time: 30 min

5. **Add Frontend UI**
   - File: `frontend/lib/screens/chat_screen.dart`
   - Add "Export" button in session menu
   - Show format options: CSV or PDF
   - Time: 25 min

6. **Implement Download**
   - File: `frontend/lib/services/file_service.dart` (NEW or extend)
   - Download file from backend
   - Save to device storage (Android: Downloads)
   - Notify user when complete
   - Time: 25 min

7. **Test Export**
   - Export as CSV, verify format
   - Export as PDF, open and verify
   - Test on both Android and iOS
   - Time: 30 min

**Dependencies:**
- Backend: `reportlab>=3.6.0`, `python-dateutil`
- Frontend: `file_saver` or platform channels

**Acceptance Criteria:**
- [ ] CSV export works correctly
- [ ] PDF export formatted nicely
- [ ] File downloads on device
- [ ] Works on Android and iOS
- [ ] Shows success notification

**Estimated Effort:** 90 minutes  
**Priority:** MEDIUM

---

### Task 3.4: Language Support Backend ⏳

**Objective:** Support multilingual responses

**Current State:**
- ⚠️ Language field exists in schema but unused

**Implementation Steps:**

1. **Define Supported Languages**
   - English (en), Swahili (sw), Amharic (am), Yoruba (yo)
   - Store in constants
   - Time: 10 min

2. **Extend Request Schema**
   - File: `backend/app/schemas.py`
   - Add language parameter to requests
   - Time: 10 min

3. **Implement Translation**
   - Option 1: Google Translate API
   - Option 2: LLM-based translation
   - Time: 35 min
   - Use Gemini for translation:
     ```python
     async def translate_response(text: str, target_lang: str) -> str:
         prompt = f"Translate to {target_lang}: {text}"
         translated = await gemini.generate_content(prompt)
         return translated
     ```

4. **Add Translation Cache**
   - Cache translations to avoid re-translating
   - Time: 20 min

5. **Update Frontend Language Selector**
   - File: `frontend/lib/screens/settings_screen.dart`
   - Add language picker
   - Save preference
   - Time: 25 min

6. **Pass Language in API Calls**
   - File: `frontend/lib/services/api_service.dart`
   - Include language in request headers
   - Time: 15 min

7. **Test Translations**
   - Send query in each language
   - Verify response language
   - Check translation quality
   - Time: 30 min

**Acceptance Criteria:**
- [ ] Multiple languages supported
- [ ] Responses in selected language
- [ ] Language preference persisted
- [ ] Translation quality acceptable
- [ ] Performance acceptable

**Estimated Effort:** 75 minutes  
**Priority:** MEDIUM

---

### Task 3.5: Crop Health Score Persistence ⏳

**Objective:** Track historical crop health trends

**Current State:**
- 🔴 Currently random placeholder

**Implementation Steps:**

1. **Design Health Database**
   - File: `backend/app/models.py`
   - New table: crop_health_records
   - Fields: user_id, crop_type, health_score, date, notes
   - Time: 15 min

2. **Create Health Tracking Service**
   - File: `backend/app/services/health_tracking.py` (NEW)
   - Log health scores
   - Calculate trends
   - Time: 30 min

3. **Implement Score Calculation**
   - Based on:
     - Recent diagnosis (if disease detected)
     - Weather conditions
     - User input
   - Range: 0-100
   - Time: 30 min

4. **Add Trend Analysis**
   - Calculate 7-day, 30-day trends
   - Show charts in daily card
   - Time: 25 min

5. **Create Health Chart Widget**
   - File: `frontend/lib/widgets/health_trend_chart.dart` (NEW)
   - Show 30-day health history
   - Use fl_chart
   - Time: 30 min

6. **Integrate into Daily Card**
   - File: `frontend/lib/widgets/farm_card_widget.dart`
   - Show current health + trend
   - Time: 20 min

7. **Test Health Tracking**
   - Simulate week of health data
   - Verify chart displays correctly
   - Test trend calculations
   - Time: 25 min

**Dependencies:**
- Backend: Already have models/database
- Frontend: `fl_chart: ^0.66.0` (already have)

**Acceptance Criteria:**
- [ ] Health scores persisted
- [ ] Historical data tracked
- [ ] Trends calculated correctly
- [ ] Charts display properly
- [ ] Integrated in daily card

**Estimated Effort:** 90 minutes  
**Priority:** MEDIUM

---

## Phase 3 Summary

| Task | Time | Priority | Status |
|------|------|----------|--------|
| Cloud Chat Sync | 120 min | HIGH | 🟡 Ready |
| Real Market API | 90 min | HIGH | 🟡 Ready |
| Chat Export | 90 min | MEDIUM | 🟡 Ready |
| Language Support | 75 min | MEDIUM | 🟡 Ready |
| Health Tracking | 90 min | MEDIUM | 🟡 Ready |

**Phase 3 Total Effort:** ~465 minutes (~7.75 hours)  
**Recommended Timeline:** 10-14 days (May 27-June 9)

---

## 🔴 PHASE 4: Polish & Enhancement (Ongoing)

**Timeline:** June onwards  
**Priority Level:** LOW-MEDIUM - Optional enhancements  

### Phase 4 Goals
- ✅ iOS support
- ✅ Advanced analytics
- ✅ Performance optimization
- ✅ Monitoring & alerting

---

## 📋 Phase 4 Tasks Overview

| Task | Effort | Priority | Type |
|------|--------|----------|------|
| iOS Support | 120 min | HIGH | Platform |
| Analytics Integration | 75 min | MEDIUM | Feature |
| Performance Optimization | 90 min | MEDIUM | Enhancement |
| Advanced Monitoring | 60 min | MEDIUM | DevOps |
| Skeleton Loading Screens | 50 min | LOW | UX |
| Confirmation Dialogs | 30 min | LOW | UX |
| Error Recovery UI | 40 min | LOW | UX |
| Personalized Recommendations | 90 min | MEDIUM | Feature |
| Crop Insurance Integration | 120 min | LOW | Feature |
| Farmer Community Features | 150 min | LOW | Feature |

---

## 📈 Overall Roadmap Timeline

```
May 2026
─────────────────────────────────────────
May 10-17   │ ✅ Phase 1 COMPLETE
May 17      │ Deployed to production
May 20-26   │ 🟡 Phase 2 IN PROGRESS
May 27-Jun2 │ 🟡 Phase 3 PLANNED
Jun 3+      │ 🔴 Phase 4 ONGOING
```

---

## 📊 Metrics & Progress Tracking

### Feature Completion Target

**By end of Phase 2 (May 26):**
- ✅ Voice input/output complete
- ✅ Accessibility standards met
- ✅ Security hardened
- ✅ UI responsive on all devices
- Target: 75% feature complete

**By end of Phase 3 (Jun 2):**
- ✅ Cloud sync working
- ✅ Real data sources integrated
- ✅ Multi-language support
- ✅ Export functionality
- Target: 85% feature complete

**Phase 4 onwards:**
- ✅ iOS support
- ✅ Advanced features
- ✅ Community features
- Target: 95%+ feature complete

---

## 🎯 Success Criteria

### Phase 2 Success
- [ ] All voice features working
- [ ] Certificate pinning implemented
- [ ] Accessibility WCAG 2.1 Level AA compliant
- [ ] Security score 96+/100
- [ ] 0 critical bugs in production

### Phase 3 Success
- [ ] Cloud sync operational
- [ ] Real market prices live
- [ ] Export feature used by 50%+ users
- [ ] Multi-language support for 4+ languages
- [ ] Performance improvements 20%+ faster

### Phase 4 Success
- [ ] iOS app on App Store
- [ ] Analytics dashboard active
- [ ] 95%+ uptime SLA
- [ ] User retention 70%+
- [ ] MAU (Monthly Active Users) 1000+

---

## 💡 Dependencies & Prerequisites

### Before Phase 2
- ✅ Phase 1 complete and deployed
- ✅ All critical bugs fixed
- ✅ Production environment stable

### Before Phase 3
- ✅ Phase 2 complete
- ✅ No critical issues from Phase 2
- ⚠️ PostgreSQL database available
- ⚠️ Commodities API account active
- ⚠️ Google Cloud TTS enabled

### Before Phase 4
- ✅ Phase 3 complete
- ⚠️ iOS developer account
- ⚠️ Apple certificates configured
- ⚠️ Analytics platform account

---

## 📞 Questions & Clarifications

**For Voice Features (Phase 2.1-2.2):**
- Should voice recording save locally first then upload?
- Any language constraints for speech recognition?
- Preferred TTS quality/speed tradeoff?

**For Cloud Sync (Phase 3.1):**
- User authentication method? (API key sufficient or OAuth?)
- Should messages auto-sync or user-initiated?
- Storage limit per user?

**For Market API (Phase 3.2):**
- Should it update real-time or hourly?
- Which regions to prioritize?
- Include forecasts/projections?

**For Phase 4 Timeline:**
- iOS support critical for launch or optional?
- Analytics platform preference?
- Community features timing?

---

## 📝 Document Maintenance

This document should be updated:
- **Weekly:** After each Phase completion
- **Monthly:** Progress metrics update
- **As needed:** Major scope changes
- **Quarterly:** Overall roadmap review

Last updated: May 17, 2026  
Next update: After Phase 2 completion (May 27, 2026)

---

**Prepared for:** Future reference and team coordination  
**Created by:** GitHub Copilot CLI  
**Repository:** Sami7ma/AgriAgent  
**Status:** READY FOR EXECUTION

### Phase 3 (May 27-June 2): Medium Priority
- Cloud chat sync
- Real market API
- Chat export (CSV/PDF)
- Language support
- Health tracking

### Phase 4: Ongoing Enhancement
- iOS support
- Analytics
- Performance optimization
- Advanced features

See full file in repository for detailed task breakdowns with implementation steps.
