import 'package:flutter/material.dart';
import 'package:flutter_application/auth/auth_service.dart';
import 'package:flutter_application/pages/login_page.dart';
import 'package:flutter_application/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/thread_page.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    title: 'Chat Assistant',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartPage() async {
    final authService = AuthService();
    final loggedIn = await authService.isLoggedIn();
    return loggedIn ? const ThreadPage() : const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartPage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return MaterialApp(
          theme: Provider.of<ThemeProvider>(context).themeData,
          home: snapshot.data!,
        );
      },
    );
  }
}