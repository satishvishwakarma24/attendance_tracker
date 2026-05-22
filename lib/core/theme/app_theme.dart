import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0050CB),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFF0066FF),
          onPrimaryContainer: Color(0xFFF8F7FF),
          secondary: Color(0xFF585F66),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFDDE3EC),
          onSecondaryContainer: Color(0xFF5E656D),
          surface: Color(0xFFF8F9FF),
          onSurface: Color(0xFF0B1C30),
          surfaceContainerLow: Color(0xFFEFF4FF),
          surfaceContainerLowest: Colors.white,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0066FF),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFF0050CB),
          onPrimaryContainer: Color(0xFFF8F7FF),
          secondary: Color(0xFFB0B3BC),
          onSecondary: Colors.black,
          secondaryContainer: Color(0xFF2C2F36),
          onSecondaryContainer: Color(0xFFEFF4FF),
          surface: Color(0xFF121318),
          onSurface: Color(0xFFE2E2E9),
          surfaceContainerLow: Color(0xFF1A1B20),
          surfaceContainerLowest: Color(0xFF0E0E12),
        ),
      );
}
