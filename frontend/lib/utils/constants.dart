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
  // Current: Local Network IP (for physical device testing)
  static const String baseUrl = "http://172.20.10.8:8000/api/v1";
  
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
