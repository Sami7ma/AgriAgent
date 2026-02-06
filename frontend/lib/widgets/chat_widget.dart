import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    // Add initial message if context exists
    if (widget.initialDiagnosis != null) {
      _messages.add(ChatMessage(
        role: "system",
        text:
            "Asking about: ${widget.initialDiagnosis!.crop} - ${widget.initialDiagnosis!.issue}",
      ));
    }
    _messages.add(ChatMessage(
        role: "bot", text: "Hello! Ask me anything about your crop."));
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(role: "user", text: text));
      _isSending = true;
      _controller.clear();
    });

    try {
      // Construct context string
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
        const SizedBox(height: 10),
        Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 10),
        const Text("AgriAgent Chat",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
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
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isUser ? Colors.green.shade600 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isSending)
          const Padding(
              padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Ask a question...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
              )
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }
}
