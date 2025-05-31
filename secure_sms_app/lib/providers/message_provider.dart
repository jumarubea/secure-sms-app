import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:another_telephony/telephony.dart';
import 'dart:convert';
import '../models/message.dart';

final Telephony telephony = Telephony.instance;

class MessageProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get allMessages => _messages;

  List<Message> get inboxMessages =>
      _messages.where((m) => m.type == MessageType.legitimate).toList();

  List<Message> get spamMessages =>
      _messages.where((m) => m.type == MessageType.spam).toList();

  int get totalMessages => _messages.length;
  int get spamCount => spamMessages.length;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Change this to your actual Flask server URL
  static const String _baseUrl =
      'http://192.168.126.158:5000'; // For Android emulator
  // static const String _baseUrl = 'http://localhost:5000'; // For iOS simulator
  // static const String _baseUrl = 'http://YOUR_COMPUTER_IP:5000'; // For physical device

  // Top-level function for background SMS handling
  static Future<void> backgroundMessageHandler(SmsMessage message) async {
    try {
      debugPrint('Background message received: ${message.body}');
      final url = Uri.parse('$_baseUrl/classify');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sender': message.address ?? 'Unknown',
              'message': message.body ?? '',
              'timestamp': DateTime.now().toIso8601String(),
              'is_verified': false,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('Background classification response: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error in background message handler: $e');
    }
  }

  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Fetch messages from backend
  Future<void> fetchMessages() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('Fetching messages from: $_baseUrl/messages');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/messages'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Fetch response status: ${response.statusCode}');
      debugPrint('Fetch response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        if (responseBody.isEmpty) {
          _messages = [];
          debugPrint('Empty response body, setting messages to empty list');
        } else {
          final dynamic decodedData = jsonDecode(responseBody);

          if (decodedData is List) {
            _messages =
                decodedData
                    .map((item) {
                      try {
                        return Message(
                          id:
                              item['id']?.toString() ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          sender: item['sender']?.toString() ?? 'Unknown',
                          content:
                              item['content']?.toString() ??
                              item['message']?.toString() ??
                              '',
                          timestamp:
                              item['timestamp'] != null
                                  ? DateTime.parse(item['timestamp'].toString())
                                  : DateTime.now(),
                          type:
                              (item['status']?.toString() ?? '')
                                          .toLowerCase() ==
                                      'spam'
                                  ? MessageType.spam
                                  : MessageType.legitimate,
                          isVerified: item['is_verified'] == true,
                          isRead: false, // Managed locally
                        );
                      } catch (e) {
                        debugPrint(
                          'Error parsing message item: $e, item: $item',
                        );
                        return null;
                      }
                    })
                    .where((message) => message != null)
                    .cast<Message>()
                    .toList();
          } else if (decodedData is Map &&
              decodedData.containsKey('messages')) {
            // Handle case where response is wrapped in an object
            final List<dynamic> messagesList = decodedData['messages'] as List;
            _messages =
                messagesList
                    .map((item) {
                      try {
                        return Message(
                          id:
                              item['id']?.toString() ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          sender: item['sender']?.toString() ?? 'Unknown',
                          content:
                              item['content']?.toString() ??
                              item['message']?.toString() ??
                              '',
                          timestamp:
                              item['timestamp'] != null
                                  ? DateTime.parse(item['timestamp'].toString())
                                  : DateTime.now(),
                          type:
                              (item['status']?.toString() ?? '')
                                          .toLowerCase() ==
                                      'spam'
                                  ? MessageType.spam
                                  : MessageType.legitimate,
                          isVerified: item['is_verified'] == true,
                          isRead: false,
                        );
                      } catch (e) {
                        debugPrint(
                          'Error parsing message item: $e, item: $item',
                        );
                        return null;
                      }
                    })
                    .where((message) => message != null)
                    .cast<Message>()
                    .toList();
          } else {
            debugPrint('Unexpected response format: $decodedData');
            _messages = [];
          }
        }

        debugPrint('Successfully fetched ${_messages.length} messages');
        // Sort by timestamp (newest first)
        _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } else {
        _error = 'Server error: ${response.statusCode}';
        debugPrint(
          'Failed to fetch messages: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _error = 'Connection error: ${e.toString()}';
      debugPrint('Error fetching messages: $e');

      // If it's a connection error, you might want to load some dummy data for testing
      if (e.toString().contains('Connection') ||
          e.toString().contains('SocketException')) {
        _loadDummyData();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load dummy data for testing when backend is not available
  void _loadDummyData() {
    _messages = [
      Message(
        id: '1',
        sender: 'M-PESA',
        content:
            'Confirmed. Ksh 1,000 sent to John Doe. Transaction cost Ksh 0. New M-PESA balance is Ksh 5,000.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: MessageType.legitimate,
        isVerified: true,
        isRead: false,
      ),
      Message(
        id: '2',
        sender: '+1234567890',
        content:
            'CONGRATULATIONS! You have won 10,000. Click here to claim: http://suspicious-link.com',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: MessageType.spam,
        isVerified: false,
        isRead: false,
      ),
      Message(
        id: '3',
        sender: 'Safaricom',
        content:
            'Dear customer, your bundle expires in 2 days. Dial *444# to renew.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: MessageType.legitimate,
        isVerified: true,
        isRead: false,
      ),
    ];
    debugPrint('Loaded ${_messages.length} dummy messages for testing');
  }

  // Add a new message by classifying it
  Future<void> addMessage({
    required String sender,
    required String content,
    required DateTime timestamp,
    bool isVerified = false,
  }) async {
    try {
      debugPrint('Adding message from $sender: $content');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/classify'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sender': sender,
              'message': content,
              'timestamp': timestamp.toIso8601String(),
              'is_verified': isVerified,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('Add message response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Refresh messages after adding
        await fetchMessages();
      } else {
        debugPrint(
          'Classification failed: ${response.statusCode} - ${response.body}',
        );
        _error = 'Failed to classify message';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error classifying message: $e');
      _error = 'Error classifying message: $e';
      notifyListeners();
    }
  }

  Future<void> moveMessage(String messageId, MessageType newType) async {
    try {
      final status = newType == MessageType.spam ? 'spam' : 'not-spam';
      final response = await http
          .put(
            Uri.parse('$_baseUrl/messages/$messageId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await fetchMessages(); // Refresh messages after update
      } else {
        debugPrint('Failed to update message: ${response.statusCode}');
        _error = 'Failed to update message';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating message: $e');
      _error = 'Error updating message: $e';
      notifyListeners();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/messages/$messageId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await fetchMessages(); // Refresh messages after deletion
      } else {
        debugPrint('Failed to delete message: ${response.statusCode}');
        _error = 'Failed to delete message';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting message: $e');
      _error = 'Error deleting message: $e';
      notifyListeners();
    }
  }

  Future<void> verifyMessage(String messageId) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/messages/$messageId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'is_verified': true}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await fetchMessages();
      } else {
        debugPrint('Failed to verify message: ${response.statusCode}');
        _error = 'Failed to verify message';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error verifying message: $e');
      _error = 'Error verifying message: $e';
      notifyListeners();
    }
  }

  Future<void> unverifyMessage(String messageId) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/messages/$messageId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'is_verified': false}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await fetchMessages(); // Refresh messages after update
      } else {
        debugPrint('Failed to unverify message: ${response.statusCode}');
        _error = 'Failed to unverify message';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error unverifying message: $e');
      _error = 'Error unverifying message: $e';
      notifyListeners();
    }
  }

  Future<void> markAsSpam(String messageId) =>
      moveMessage(messageId, MessageType.spam);

  Future<void> markAsLegitimate(String messageId) =>
      moveMessage(messageId, MessageType.legitimate);

  Future<void> markAsRead(String messageId) async {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> initSmsListener() async {
    try {
      debugPrint('Initializing SMS listener...');

      // Request permissions
      bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
      debugPrint('SMS permissions granted: $permissionsGranted');

      if (permissionsGranted == true) {
        await Future.delayed(const Duration(seconds: 2));
        telephony.listenIncomingSms(
          onNewMessage: (SmsMessage message) async {
            debugPrint(
              'New SMS received from ${message.address}: ${message.body}',
            );
            try {
              // Send SMS to backend for filtering/classification
              await addMessage(
                sender: message.address ?? 'Unknown',
                content: message.body ?? '',
                timestamp: DateTime.now(),
              );
            } catch (e) {
              debugPrint('Error processing incoming SMS: $e');
            }
          },
          listenInBackground: true,
          onBackgroundMessage: backgroundMessageHandler,
        );
        debugPrint('SMS listener initialized successfully');
      } else {
        _error = 'SMS permissions not granted';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing SMS listener: $e');
      _error = 'Error initializing SMS listener: $e';
      notifyListeners();
    }
  }
}
