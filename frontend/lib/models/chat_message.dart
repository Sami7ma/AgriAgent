class ChatMessage {
  final String role; // 'user', 'bot', 'system', 'error'
  final String text;

  ChatMessage({required this.role, required this.text});

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'text': text,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      role: map['role'] as String? ?? 'bot',
      text: map['text'] as String? ?? '',
    );
  }
}
