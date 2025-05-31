import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/message_provider.dart';
import 'message_item.dart';

class MessageList extends StatelessWidget {
  final MessageType messageType;

  const MessageList({super.key, required this.messageType});

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        List<Message> messages;

        switch (messageType) {
          case MessageType.legitimate:
            messages = messageProvider.inboxMessages;
            break;
          case MessageType.spam:
            messages = messageProvider.spamMessages;
            break;
        }

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyIcon(),
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return MessageItem(message: messages[index]);
          },
        );
      },
    );
  }

  IconData _getEmptyIcon() {
    switch (messageType) {
      case MessageType.legitimate:
        return Icons.inbox;
      case MessageType.spam:
        return Icons.warning;
    }
  }

  String _getEmptyMessage() {
    switch (messageType) {
      case MessageType.legitimate:
        return 'No messages in inbox';
      case MessageType.spam:
        return 'No spam messages';
    }
  }
}
