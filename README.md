# 🌾 AgriAgent: Your Google-Powered Farm Manager

**AgriAgent** is a sophisticated, agentic agricultural assistant designed to empower farmers with the best of Google's AI. Powered by **Gemini 3 Flash**, it bridges the gap between complex data and boots-on-the-ground farming. Whether you're diagnosing a crop disease via video or checking the latest market prices via voice, AgriAgent is your digital partner in the field.

---

## 🚀 Key Features

### 🧠 Agentic Intelligence
* **Multimodal Diagnostics:** Upload videos or photos of your crops. Gemini 3 Flash analyzes leaf patterns and soil conditions to identify pests or diseases instantly.
* **Voice Intelligence:** Hands-free interaction using multilingual voice support—perfect for when your hands are busy in the soil.
* **Daily Farm Card:** A personalized "mission control" dashboard featuring hyper-local weather alerts, market trends, and prioritized farming tasks.

### 🛠️ Precision Tools
* **Market Pulse:** Check real-time crop pricing in your specific region to optimize your sales and increase profit margins.
* **Weather-Driven Advice:** Get more than just a forecast. Receive actionable insights like *"Heavy rain expected in 4 hours; delay your fertilization window."*
* **Knowledge Base:** Comprehensive guidance on irrigation, soil health, and sustainable management practices.

---

## 🏗️ Technical Architecture

| Component | Technology |
| :--- | :--- |
| **AI Engine** | **Google Gemini 3 Flash** (Multimodal Reasoning) |
| **Frontend** | **Flutter** (High-performance Mobile UI) |
| **Backend** | **FastAPI** (Python-based asynchronous API) |
| **Agent Framework** | **Antigravity** (Custom logic with Token-based reasoning) |

---

## 💻 Installation & Setup

### 📱 Android (Ready to Use)
1.  **Download:** [**AgriAgent v1.1.1 APK**](https://github.com/Sami7ma/AgriAgent/releases/download/v1.1.1/app-release.apk)
2.  **Permissions:** Enable **Unknown Sources** in `Settings > Security`.
3.  **Launch:** Open the app and provide location access for accurate weather and market data.

### 🛠️ Developer Setup
**Backend:**
```bash
cd backend
pip install -r requirements.txt
export GEMINI_API_KEY="your_google_api_key"
uvicorn main:app --reload

**Frontend:**
```bash
cd frontend
flutter pub get
flutter run

### 📝 Requirements

- **OS:** Android 7.0 (Nougat) or higher  
- **Connectivity:** Active internet connection for real-time tool use  
- **API Key:** A valid **GEMINI_API_KEY** for AI features  

---

### 📈 Changelog (v1.1.1)

- **Sync Optimization:** Fixed chat and image generation synchronization  
- **Reliability:** Improved tool-calling accuracy for weather and market data  

### 🤝 Support

- **Issues:** GitHub Issue Tracker
- **Email:** support@sami7ma.com


**AgriAgent** © 2026 Sami7ma. All rights reserved.

