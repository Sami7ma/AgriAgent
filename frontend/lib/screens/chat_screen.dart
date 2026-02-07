import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import '../models/diagnosis.dart';
import '../models/chat_message.dart';
import '../models/farm_card.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final Diagnosis? initialDiagnosis;
  final FarmCard? locationContext;
  final double? latitude;
  final double? longitude;

  const ChatScreen({
    super.key, 
    this.initialDiagnosis, 
    this.locationContext,
    this.latitude,
    this.longitude
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ... (existing state)
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  
  List<ChatMessage> _messages = [];
  bool _isSending = false;

  // ... (initNewChat same)

  // Messaging with History Passing
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(role: "user", text: text));
      _isSending = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      String contextStr = "";
      if (_messages.isNotEmpty && _messages[0].role == "system") {
        contextStr += "${_messages[0].text}\n";
      }

      // SEND HISTORY AND LOCATION (Now with Lat/Lon)
      String responseText = await _apiService.sendChatQuery(
          text, 
          contextStr, 
          history: _messages, 
          location: widget.locationContext,
          lat: widget.latitude,
          lon: widget.longitude
      );

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(role: "bot", text: responseText));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(role: "error", text: "Connection error. Please try again."));
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }
  
  void _scrollToBottom() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
              _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
             Icon(Icons.eco, color: Color(0xFF2E7D32)),
             SizedBox(width: 8),
             Text("AgriAgent Chat", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      // NO DRAWER HERE
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg); // Keeping existing bubble logic
              },
            ),
          ),
          if (_isSending)
             const LinearProgressIndicator(color: Color(0xFF2E7D32), backgroundColor: Color(0xFFE8F5E9)),
          _buildInputArea(), // Keeping existing input logic
        ],
      ),
    );
  }
  
  // ... Keep _buildMessageBubble and _buildInputArea as they were (omitted for brevity in replacement if possible, but replace_file_content needs chunks. 
  // I will replace the Whole Class to be safe and clean, ensuring I don't lose the UI methods.
  
  Widget _buildMessageBubble(ChatMessage msg) {
    // ... (Same as before)
    if (msg.role == "system") {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
          child: Text(msg.text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      );
    }
    
    final isUser = msg.role == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.only(
             topLeft: const Radius.circular(20),
             topRight: const Radius.circular(20),
             bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
             bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
          ],
          border: isUser ? null : Border.all(color: Colors.grey.shade100),
        ),
        child: isUser 
          ? Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 16))
          : MarkdownBody(
             data: msg.text,
             styleSheet: MarkdownStyleSheet(
               p: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.4),
               strong: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
             ),
          ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Ask AgriAgent...",
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            onPressed: _sendMessage,
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 2,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
