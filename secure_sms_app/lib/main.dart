import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/message_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final messageProvider = MessageProvider();
  messageProvider.initSmsListener();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => messageProvider),
      ],
      child: const SecureMessagingApp(),
    ),
  );
}

class SecureMessagingApp extends StatelessWidget {
  const SecureMessagingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Secure Messaging',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.white,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.grey,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
