import 'package:flutter/material.dart';
import 'package:flutter_application/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeData _themeData;
  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData == darkTheme;

  ThemeProvider() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _themeData = brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightTheme) {
      themeData = darkTheme;
    }
    else {
      themeData = lightTheme;
    }
  }
}