import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/message_provider.dart';

class MessageDetailScreen extends StatelessWidget {
  final Message message;

  const MessageDetailScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(message.sender),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              final messageProvider = Provider.of<MessageProvider>(
                context,
                listen: false,
              );
              switch (value) {
                case 'mark_legitimate':
                  messageProvider.moveMessage(
                    message.id,
                    MessageType.legitimate,
                  );
                  Navigator.pop(context);
                  break;
                case 'mark_spam':
                  messageProvider.moveMessage(message.id, MessageType.spam);
                  Navigator.pop(context);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'mark_legitimate',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Mark as Legitimate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'mark_spam',
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Mark as Spam'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'mark_phishing',
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Mark as Phishing'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getTypeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getTypeColor().withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(_getTypeIcon(), color: _getTypeColor()),
                  const SizedBox(width: 8),
                  Text(
                    _getTypeLabel(),
                    style: TextStyle(
                      color: _getTypeColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (message.isVerified) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 16, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            'Verified Sender',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'From: ${message.sender}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Received: ${_formatDateTime(message.timestamp)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Message:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Text(
                message.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (message.type == MessageType.spam) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Spam Alert',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This message has been identified as spam. Do not click any links or provide personal information.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reported to TCRA'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.report),
                      label: const Text('Report to TCRA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (message.type) {
      case MessageType.legitimate:
        return Colors.green;
      case MessageType.spam:
        return Colors.orange;
    }
  }

  IconData _getTypeIcon() {
    switch (message.type) {
      case MessageType.legitimate:
        return Icons.check_circle;
      case MessageType.spam:
        return Icons.warning;
    }
  }

  String _getTypeLabel() {
    switch (message.type) {
      case MessageType.legitimate:
        return 'Legitimate Message';
      case MessageType.spam:
        return 'Spam Message';
    }
  }

  String _formatDateTime(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
