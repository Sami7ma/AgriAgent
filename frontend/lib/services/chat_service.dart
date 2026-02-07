import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatService {
  static const String _sessionsKey = 'chat_sessions_list';
  static const String _sessionPrefix = 'chat_session_';

  /// Saves a chat session (list of messages)
  Future<void> saveSession(String sessionId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Save messages
    final List<String> encodedMessages = messages.map((msg) => jsonEncode(msg.toMap())).toList();
    await prefs.setStringList('$_sessionPrefix$sessionId', encodedMessages);

    // 2. Update session list metadata (if new)
    await _updateSessionList(sessionId, messages.isNotEmpty ? messages.last.text : "New Chat");
  }

  /// Loads messages for a specific session
  Future<List<ChatMessage>> loadSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedMessages = prefs.getStringList('$_sessionPrefix$sessionId');

    if (encodedMessages == null) return [];

    return encodedMessages.map((str) => ChatMessage.fromMap(jsonDecode(str))).toList();
  }

  /// Gets a list of all saved sessions (id, title, timestamp)
  Future<List<Map<String, String>>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionsJson = prefs.getString(_sessionsKey);
    
    if (sessionsJson == null) return [];
    
    try {
        final List<dynamic> list = jsonDecode(sessionsJson);
        return list.map((item) => Map<String, String>.from(item)).toList();
    } catch (e) {
        return [];
    }
  }

  /// Updates the list of sessions (Title = last message or first message)
  Future<void> _updateSessionList(String sessionId, String lastMessagePreview) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> sessions = await getSessions();
    
    // Check if session exists
    int index = sessions.indexWhere((s) => s['id'] == sessionId);
    
    final sessionData = {
        'id': sessionId,
        'title': lastMessagePreview.length > 30 ? '${lastMessagePreview.substring(0, 30)}...' : lastMessagePreview,
        'date': DateTime.now().toIso8601String(), // simplistic timestamp
    };

    if (index != -1) {
        sessions[index] = sessionData; // Update existing
    } else {
        sessions.insert(0, sessionData); // Add new to top
    }

    await prefs.setString(_sessionsKey, jsonEncode(sessions));
  }
  
  /// Deletes a session
  Future<void> deleteSession(String sessionId) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_sessionPrefix$sessionId');
      
      List<Map<String, String>> sessions = await getSessions();
      sessions.removeWhere((s) => s['id'] == sessionId);
      await prefs.setString(_sessionsKey, jsonEncode(sessions));
  }
}
