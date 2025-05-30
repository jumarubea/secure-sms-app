import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/message_provider.dart';
import '../screens/message_detail_screen.dart';

class MessageItem extends StatelessWidget {
  final Message message;

  const MessageItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(message.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.warning, color: Colors.white),
      ),
      onDismissed: (direction) {
        final messageProvider = Provider.of<MessageProvider>(context, listen: false);
        if (direction == DismissDirection.startToEnd) {
          messageProvider.moveMessage(message.id, MessageType.legitimate);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message moved to inbox')),
          );
        } else {
          messageProvider.moveMessage(message.id, MessageType.spam);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message marked as spam')),
          );
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor().withOpacity(0.1),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                message.sender,
                style: TextStyle(
                  fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (message.isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 12, color: Colors.blue),
                    SizedBox(width: 2),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Text(
          message.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(message.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 4),
            if (!message.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () {
          Provider.of<MessageProvider>(context, listen: false)
              .markAsRead(message.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessageDetailScreen(message: message),
            ),
          );
        },
      ),
    );
  }

  Color _getTypeColor() {
    switch (message.type) {
      case MessageType.legitimate:
        return Colors.green;
      case MessageType.spam:
        return Colors.orange;
      case MessageType.phishing:
        return Colors.red;
    }
  }

  IconData _getTypeIcon() {
    switch (message.type) {
      case MessageType.legitimate:
        return Icons.check_circle;
      case MessageType.spam:
        return Icons.warning;
      case MessageType.phishing:
        return Icons.security;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}
