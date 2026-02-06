import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/diagnosis.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatWidget extends StatefulWidget {
  final Diagnosis? initialDiagnosis;

  const ChatWidget({super.key, this.initialDiagnosis});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  final ApiService _apiService = ApiService();
  final String _storageKey = "agri_agent_chat_history";

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? history = prefs.getStringList(_storageKey);
    
    if (history != null && history.isNotEmpty) {
      setState(() {
         _messages.addAll(history.map((e) {
             final split = e.split(":::");
             return ChatMessage(role: split[0], text: split.length > 1 ? split[1] : "");
         }).toList());
      });
    }

    // Add current context if needed
    if (widget.initialDiagnosis != null) {
      setState(() {
        _messages.add(ChatMessage(
          role: "system",
          text: "New Context: ${widget.initialDiagnosis!.crop} - ${widget.initialDiagnosis!.issue}",
        ));
      });
    }
    
    if (_messages.isEmpty) {
        setState(() {
            _messages.add(ChatMessage(role: "bot", text: "Hello! Ask me anything about your crop."));
        });
    }
  }

  Future<void> _saveHistory() async {
      final prefs = await SharedPreferences.getInstance();
      final List<String> history = _messages.map((m) => "${m.role}:::${m.text}").toList();
      await prefs.setStringList(_storageKey, history);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(role: "bot", text: "History cleared. Start a new chat!"));
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(role: "user", text: text));
      _isSending = true;
      _controller.clear();
    });
    _saveHistory();

    try {
      String contextStr = "";
      if (widget.initialDiagnosis != null) {
        contextStr =
            "Diagnosis: ${widget.initialDiagnosis!.crop} with ${widget.initialDiagnosis!.issue}. Severity: ${widget.initialDiagnosis!.severity}.";
      }

      String responseText =
          await _apiService.sendChatQuery(text, contextStr);

      setState(() {
        _messages.add(ChatMessage(role: "bot", text: responseText));
      });
      _saveHistory();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            role: "error", text: "Failed to get response. Please try again."));
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Header with Menu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("AgriAgent Chat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'clear') _clearHistory();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                         Icon(Icons.delete_outline, size: 20, color: Colors.red),
                         SizedBox(width: 8),
                         Text("Clear History"),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg.role == "user";
              final isSystem = msg.role == "system";

              if (isSystem) {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(msg.text,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12)),
                ));
              }

              return Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser 
                      ? const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF2E7D32)]) 
                      : const LinearGradient(colors: [Color(0xFFF1F8E9), Color(0xFFDCEDC8)]),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                      bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))]
                  ),
                  child: isUser 
                    ? Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 15))
                    : MarkdownBody(
                        data: msg.text,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(color: Colors.black87, fontSize: 15),
                          strong: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                        ),
                      ),
                ),
              );
            },
          ),
        ),
        if (_isSending)
          const Padding(
              padding: EdgeInsets.all(8), child: LinearProgressIndicator(color: Color(0xFF2E7D32), backgroundColor: Color(0xFFC8E6C9))),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Ask a question...",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFF2E7D32),
                child: IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }
}
