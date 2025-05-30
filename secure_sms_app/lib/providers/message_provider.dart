import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageProvider extends ChangeNotifier {
  final List<Message> _messages = [
    Message(
      id: '1',
      sender: 'M-Pesa',
      content: 'Umepokea Tsh 50,000 kutoka kwa JOHN DOE. Salio lako ni Tsh 75,000.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: MessageType.legitimate,
      isVerified: true,
    ),
    Message(
      id: '2',
      sender: '+255123456789',
      content: 'CONGRATULATIONS! You have won 1,000,000 TSH! Click here to claim: bit.ly/fake-link',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: MessageType.phishing,
    ),
    Message(
      id: '3',
      sender: 'Unknown',
      content: 'URGENT: Your account will be suspended. Send your PIN to verify.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: MessageType.spam,
    ),
    Message(
      id: '4',
      sender: 'Tigo Pesa',
      content: 'Umetuma Tsh 25,000 kwa MARY SMITH. Gharama ya huduma ni Tsh 500.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: MessageType.legitimate,
      isVerified: true,
    ),
  ];

  List<Message> get allMessages => _messages;

  List<Message> get inboxMessages => 
      _messages.where((m) => m.type == MessageType.legitimate).toList();

  List<Message> get spamMessages => 
      _messages.where((m) => m.type == MessageType.spam).toList();

  List<Message> get phishingMessages => 
      _messages.where((m) => m.type == MessageType.phishing).toList();

  int get totalMessages => _messages.length;
  int get spamCount => spamMessages.length;
  int get phishingCount => phishingMessages.length;

  void moveMessage(String messageId, MessageType newType) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(type: newType);
      notifyListeners();
    }
  }

  void markAsRead(String messageId) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(isRead: true);
      notifyListeners();
    }
  }
}
