import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0B0F19);
  static const Color surface = Color(0xFF131B2E);
  static const Color surfaceElevated = Color(0xFF1B253F);
  static const Color surfaceBorder = Color(0xFF28365B);
  
  // Neon Accents
  static const Color electricGreen = Color(0xFF00E676);
  static const Color electricCyan = Color(0xFF00E5FF);
  static const Color electricBlue = Color(0xFF2979FF);
  static const Color electricYellow = Color(0xFFFFEA00);
  static const Color neonOrange = Color(0xFFFF9100);
  static const Color neonPink = Color(0xFFFF1744);
  static const Color neonPurple = Color(0xFFD500F9);
  
  // Track colors
  static const Color trackAsphalt = Color(0xFF1E2430);
  static const Color trackAsphaltLight = Color(0xFF2A3242);
  static const Color trackBorder = Color(0xFF4B5563);
  static const Color trackLaneLine = Color(0xFFE2E8F0);
  static const Color finishLineYellow = Color(0xFFFFD700);
  static const Color curbRed = Color(0xFFEF4444);
  static const Color curbWhite = Color(0xFFF9FAFB);
  
  // Typing Status Colors
  static const Color charCorrect = Color(0xFF00E676);
  static const Color charIncorrect = Color(0xFFFF5252);
  static const Color charIncorrectBg = Color(0x40FF1744);
  static const Color charRemaining = Color(0xFF94A3B8);
  static const Color charCurrent = Color(0xFF00E5FF);
  static const Color charCurrentBg = Color(0x3300E5FF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  
  // Car Presets
  static const List<Color> carColors = [
    Color(0xFF00E5FF), // Cyan
    Color(0xFF00E676), // Neon Green
    Color(0xFFFF9100), // Solar Orange
    Color(0xFFFF1744), // Crimson Red
    Color(0xFFD500F9), // Cyber Violet
    Color(0xFFFFEA00), // Lightning Yellow
    Color(0xFF3B82F6), // Azure Blue
    Color(0xFFEC4899), // Hot Pink
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nitroGradient = LinearGradient(
    colors: [Color(0xFFFFEA00), Color(0xFFFF9100), Color(0xFFFF1744)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF131B2E), Color(0xFF0E1524)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
