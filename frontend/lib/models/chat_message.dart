class ChatMessage {
  final String role; // 'user', 'bot', 'system', 'error'
  final String text;

  ChatMessage({required this.role, required this.text});

  Map<String, String> toMap() {
    return {
      'role': role,
      'text': text,
    };
  }

  factory ChatMessage.fromMap(Map<String, String> map) {
    return ChatMessage(
      role: map['role'] ?? 'bot',
      text: map['text'] ?? '',
    );
  }
}
