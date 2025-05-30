enum MessageType { legitimate, spam, phishing }

class Message {
  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;
  final bool isVerified;

  const Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.isVerified = false,
  });

  Message copyWith({
    String? id,
    String? sender,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    bool? isRead,
    bool? isVerified,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
