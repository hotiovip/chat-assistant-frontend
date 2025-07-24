import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100,
    primary: Colors.grey.shade200,
    secondary: Colors.grey,
    tertiary: Colors.green,
    error: Colors.red
  )
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade800,
    primary: Colors.grey.shade900,
    secondary: Colors.black87,
    tertiary: Colors.green.shade900,
    error: Colors.red.shade900
  )
);