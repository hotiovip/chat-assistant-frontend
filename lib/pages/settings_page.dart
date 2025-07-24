import 'package:flutter/material.dart';
import 'package:flutter_application/auth/auth_service.dart';
import 'package:flutter_application/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  final String title = "Home";

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Press the icon to change the theme'), 
            IconButton(
              color: Theme.of(context).colorScheme.inverseSurface,
              icon: Icon(Provider.of<ThemeProvider>(context).isDarkMode 
              ? Icons.wb_sunny
              : Icons.nightlight),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
            ElevatedButton(onPressed: () {
              _authService.logout(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.inverseSurface,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ), 
            child: const Text("Logout")
            ),
          ],
        ),
      ),
    );
  }
}