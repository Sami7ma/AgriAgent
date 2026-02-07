import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

/// Service for managing chat session persistence
/// Uses SharedPreferences for local device storage
class ChatService {
  static const String _sessionsKey = 'chat_sessions_list';
  static const String _sessionPrefix = 'chat_session_';
  static const int _maxSessions = 100; // Prevent unbounded growth

  /// Saves a chat session (list of messages)
  /// Messages are stored persistently until explicitly deleted
  Future<void> saveSession(String sessionId, List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Save messages as JSON list
      final List<String> encodedMessages = messages.map((msg) => jsonEncode(msg.toMap())).toList();
      await prefs.setStringList('$_sessionPrefix$sessionId', encodedMessages);

      // 2. Update session metadata list
      await _updateSessionList(sessionId, messages.isNotEmpty ? messages.last.text : "New Chat");
      
    } catch (e) {
      // Log error but don't crash - chat still works, just not persisted
      print('ChatService: Error saving session: $e');
    }
  }

  /// Loads messages for a specific session
  /// Returns empty list if session doesn't exist
  Future<List<ChatMessage>> loadSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? encodedMessages = prefs.getStringList('$_sessionPrefix$sessionId');

      if (encodedMessages == null || encodedMessages.isEmpty) {
        return [];
      }

      return encodedMessages.map((str) {
        try {
          return ChatMessage.fromMap(jsonDecode(str));
        } catch (e) {
          // Skip malformed messages
          return ChatMessage(role: 'system', text: '[Message could not be loaded]');
        }
      }).toList();
      
    } catch (e) {
      print('ChatService: Error loading session: $e');
      return [];
    }
  }

  /// Gets a list of all saved sessions (id, title, timestamp)
  /// Sessions are sorted by most recent first
  Future<List<Map<String, String>>> getSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sessionsJson = prefs.getString(_sessionsKey);
      
      if (sessionsJson == null || sessionsJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> list = jsonDecode(sessionsJson);
      return list.map((item) => Map<String, String>.from(item)).toList();
      
    } catch (e) {
      print('ChatService: Error getting sessions: $e');
      return [];
    }
  }

  /// Updates the list of sessions with proper error handling
  Future<void> _updateSessionList(String sessionId, String lastMessagePreview) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, String>> sessions = await getSessions();
      
      // Check if session exists
      int index = sessions.indexWhere((s) => s['id'] == sessionId);
      
      // Truncate preview for display
      String title = lastMessagePreview;
      if (title.length > 40) {
        title = '${title.substring(0, 40)}...';
      }
      // Remove newlines for cleaner display
      title = title.replaceAll('\n', ' ').trim();
      
      final sessionData = {
        'id': sessionId,
        'title': title,
        'date': DateTime.now().toIso8601String(),
      };

      if (index != -1) {
        sessions[index] = sessionData;
      } else {
        sessions.insert(0, sessionData);
      }
      
      // Limit total sessions to prevent storage bloat
      if (sessions.length > _maxSessions) {
        // Remove oldest sessions
        final toRemove = sessions.sublist(_maxSessions);
        sessions = sessions.sublist(0, _maxSessions);
        
        // Clean up old session data
        for (var old in toRemove) {
          await prefs.remove('$_sessionPrefix${old['id']}');
        }
      }

      await prefs.setString(_sessionsKey, jsonEncode(sessions));
      
    } catch (e) {
      print('ChatService: Error updating session list: $e');
    }
  }
  
  /// Deletes a session and its messages
  Future<void> deleteSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove the actual messages
      await prefs.remove('$_sessionPrefix$sessionId');
      
      // Remove from session list
      List<Map<String, String>> sessions = await getSessions();
      sessions.removeWhere((s) => s['id'] == sessionId);
      await prefs.setString(_sessionsKey, jsonEncode(sessions));
      
    } catch (e) {
      print('ChatService: Error deleting session: $e');
    }
  }
  
  /// Clears all chat history (use with caution)
  Future<void> clearAllSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await getSessions();
      
      // Remove all session data
      for (var session in sessions) {
        await prefs.remove('$_sessionPrefix${session['id']}');
      }
      
      // Clear the session list
      await prefs.remove(_sessionsKey);
      
    } catch (e) {
      print('ChatService: Error clearing sessions: $e');
    }
  }
  
  /// Check if a session exists
  Future<bool> sessionExists(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('$_sessionPrefix$sessionId');
    } catch (e) {
      return false;
    }
  }
}
