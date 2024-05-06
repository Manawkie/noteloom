import 'package:flutter/material.dart';

class AppTheme {
  // Primary text color: white
  // Primary bg color: argb 255 45 53 144
  // Gray: 255 217 217 217
  // Tag color: 255 65 78 226

  static const _primaryColor = Color.fromRGBO(96, 149, 163, 1);
  static const _lightPrimaryColor = Color.fromRGBO(207, 226, 232, 1);
  static const _grayColor = Color.fromRGBO(217, 217, 217, 1);

  static const _darkPrimaryColor = Color.fromRGBO(45, 53, 144, 1);
  Color get primaryColor => _primaryColor;

  static final defaultTheme = ThemeData(
    primaryColor: _primaryColor,
    appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: _primaryColor,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)),
    colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        secondary: _grayColor,
        tertiary: _lightPrimaryColor),
    textTheme: const TextTheme(bodySmall: TextStyle(color: Colors.white)),
    navigationBarTheme:
        const NavigationBarThemeData(backgroundColor: _grayColor),
  );

  static final darkTheme = ThemeData(
    primaryColor: _darkPrimaryColor,
    appBarTheme: const AppBarTheme(
        backgroundColor: _darkPrimaryColor,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _darkPrimaryColor,
    ),
    navigationBarTheme:
        const NavigationBarThemeData(backgroundColor: _grayColor),
  );
}
