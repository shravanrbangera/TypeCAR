import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle get gameTitle => GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
    color: AppColors.textPrimary,
  );

  static TextStyle get headingLarge => GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get headingMedium => GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.textPrimary,
  );

  static TextStyle get arcadeSubheading => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodyLarge => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get buttonText => GoogleFonts.orbitron(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: Colors.black,
  );

  static TextStyle get codeTyping => GoogleFonts.firaCode(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 0.5,
  );

  static TextStyle get hudValue => GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.electricCyan,
  );

  static TextStyle get hudLabel => GoogleFonts.orbitron(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.textMuted,
  );
}
