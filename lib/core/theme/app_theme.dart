import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFFFFFEFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF23282F);
  static const Color textSecondary = Color(0xFF68717E);
  static const Color splashBackground = Color(0xFF15122B);
  static const Color skipTextColor = Color(0xFF151A20);
  static const Color inactiveIndicatorColor = Color(0xFFDCECF6);
  static const Color brandCyan = Color(0xFF00D7E1);
  static const Color brandBlue = Color(0xFF197FC5);

  // Drone feature colors
  static const Color connectedGreen = Color(0xFF34C759);
  static const Color disconnectedRed = Color(0xFFFF3B30);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFF0F0F0);
  static const Color statsOverlay = Color(0xCC1A1A2E);
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color warningOrange = Color(0xFFFF9500);
  static const Color reportCardBg = Color(0xFFF8F9FA);
  static const Color navBarBg = Color(0xFFFFFFFF);
  static const Color navBarInactive = Color(0xFFB0B8C4);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brandCyan, brandBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: const Color(0xFF197FC5),
      canvasColor: surfaceColor,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: skipTextColor,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          height: 1.25,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
      ),
    );
  }
}
