import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_sms_app/models/message.dart';
import 'package:secure_sms_app/services/sms_platform_service.dart';
import '../providers/message_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/message_list.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    // Initialize SMS listener and fetch messages
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final messageProvider = Provider.of<MessageProvider>(
        context,
        listen: false,
      );
      try {
        await messageProvider.initSmsListener();
        await messageProvider.fetchMessages();
      } catch (e) {
        debugPrint('Error initializing: $e');
        // Show error to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load messages: $e')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Messaging'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: themeProvider.toggleTheme,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
          // Show loading indicator while fetching messages
          if (messageProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _currentIndex == 0
              ? _buildDashboard(messageProvider)
              : _buildMessages(messageProvider);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        ],
      ),
    );
  }

  Widget _buildDashboard(MessageProvider messageProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message Overview',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Total Messages',
                  value: messageProvider.totalMessages.toString(),
                  icon: Icons.message,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardCard(
                  title: 'Spam Detected',
                  value: messageProvider.spamCount.toString(),
                  icon: Icons.warning,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child:
                messageProvider.allMessages.isEmpty
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No recent activity'),
                      ),
                    )
                    : Column(
                      children: [
                        // Show last few messages as activity
                        ...messageProvider.allMessages
                            .take(3)
                            .map(
                              (message) => Column(
                                children: [
                                  _buildActivityItem(
                                    message.type == MessageType.spam
                                        ? 'Spam message filtered from ${message.sender}'
                                        : 'Message from ${message.sender}',
                                    _formatTime(message.timestamp),
                                    message.type == MessageType.spam
                                        ? Icons.warning
                                        : Icons.message,
                                    message.type == MessageType.spam
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                  if (messageProvider.allMessages.indexOf(
                                        message,
                                      ) <
                                      (messageProvider.allMessages.length > 3
                                          ? 2
                                          : messageProvider.allMessages.length -
                                              1))
                                    const Divider(),
                                ],
                              ),
                            )
                            .toList(),
                      ],
                    ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: SmsPlatformService.requestDefaultSmsApp,
            child: const Text('Set as Default SMS App'),
          ),
          const SizedBox(height: 16),
          // Add refresh button
          ElevatedButton.icon(
            onPressed: () async {
              await messageProvider.fetchMessages();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Messages'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(MessageProvider messageProvider) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Inbox (${messageProvider.inboxMessages.length})'),
              Tab(text: 'Spam (${messageProvider.spamMessages.length})'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              MessageList(messageType: MessageType.legitimate),
              MessageList(messageType: MessageType.spam),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
