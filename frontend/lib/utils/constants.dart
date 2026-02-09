class AppConstants {
  // ============================================
  // API CONFIGURATION
  // ============================================
  // 
  // IMPORTANT: Update this URL based on your deployment:
  // - Android Emulator: http://10.0.2.2:8000/api/v1
  // - Physical Device (same WiFi): Use your computer's local IP
  // - Production: https://your-api-domain.com/api/v1
  //
  // For Android emulators use 10.0.2.2 to reach the host machine localhost.
  // If using a physical device, replace with your PC's LAN IP (e.g. 192.168.x.x).
  // Finally deploy to Render and use the URL provided by Render.
  static const String baseUrl = "https://agriagent-api.onrender.com/api/v1";
  
  // ============================================
  // TIMEOUTS
  // ============================================
  static const int connectionTimeoutMs = 30000;
  static const int receiveTimeoutMs = 60000;
  
  // ============================================
  // FEATURE FLAGS
  // ============================================
  static const bool enableVoiceInput = false;  // Voice UI not complete yet
  static const bool enableDebugMode = true;    // Set to false in production
  
  // ============================================
  // UI CONSTANTS
  // ============================================
  static const int maxChatHistoryDisplay = 50;
  static const int maxQueryLength = 2000;
}
