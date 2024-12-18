import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color _primaryPurple = Color(0xFF8E24AA); // Deep purple
  static const Color _secondaryPurple =
      Color(0xFFAB47BC); // Lighter purple for accents

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: _primaryPurple,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: _primaryPurple,
      secondary: _secondaryPurple,
      surface: Color(0xFFF5F5F5), // Colors.grey[100]
      background: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: _primaryPurple,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: _primaryPurple,
    scaffoldBackgroundColor: const Color(0xFF212121), // Colors.grey[900]
    colorScheme: const ColorScheme.dark(
      primary: _primaryPurple,
      secondary: _secondaryPurple,
      surface: Color(0xFF303030), // Colors.grey[850]
      background: Color(0xFF212121), // Colors.grey[900]
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF212121), // Colors.grey[900]
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
  );
}
