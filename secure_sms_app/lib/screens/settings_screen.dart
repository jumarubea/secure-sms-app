import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _spamNotifications = true;
  bool _phishingAlerts = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Appearance',
            [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle between light and dark theme'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Language',
            [
              ListTile(
                title: const Text('Language'),
                subtitle: Text(_selectedLanguage),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showLanguageDialog(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Notifications',
            [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive notifications for new messages'),
                value: _notificationsEnabled,
                onChanged: (value) => setState(() => _notificationsEnabled = value),
              ),
              SwitchListTile(
                title: const Text('Spam Alerts'),
                subtitle: const Text('Get notified when spam is detected'),
                value: _spamNotifications,
                onChanged: _notificationsEnabled 
                    ? (value) => setState(() => _spamNotifications = value)
                    : null,
              ),
              SwitchListTile(
                title: const Text('Phishing Alerts'),
                subtitle: const Text('Get notified when phishing is detected'),
                value: _phishingAlerts,
                onChanged: _notificationsEnabled 
                    ? (value) => setState(() => _phishingAlerts = value)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Security',
            [
              ListTile(
                title: const Text('Custom Filter Rules'),
                subtitle: const Text('Set up custom spam detection rules'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showCustomRulesDialog(),
              ),
              ListTile(
                title: const Text('Blocked Senders'),
                subtitle: const Text('Manage blocked phone numbers'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feature coming soon')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'About',
            [
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showPrivacyDialog(),
              ),
              ListTile(
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact support: help@securemessaging.tz')),
                  );
                },
              ),
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Kiswahili'),
              value: 'Kiswahili',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomRulesDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Rule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter keywords or phrases to automatically flag as spam:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g., "win prize", "urgent"',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rule added: "${controller.text}"')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Add Rule'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Information'),
        content: const SingleChildScrollView(
          child: Text(
            'This app processes SMS messages locally on your device to detect spam and phishing attempts. '
            'No personal message content is sent to external servers. Only anonymized detection patterns '
            'are shared to improve the AI model. You can opt out of data sharing in the settings.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
