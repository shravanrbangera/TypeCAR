import 'package:flutter/material.dart';

enum TrackEnvironment {
  beach('Beach Paradise', '🌴 Sunny ocean shore with sand & palm trees'),
  cyberpunk('Cyber Neon', '⚡ Futuristic highway with laser rails & grid'),
  asphalt('Grand Prix', '🏁 Professional circuit with asphalt & grandstands');

  final String title;
  final String description;
  const TrackEnvironment(this.title, this.description);
}

class TrackThemeModel {
  final TrackEnvironment environment;
  final Color trackColor;
  final Color trackColorAlt;
  final Color curbColor1;
  final Color curbColor2;
  final Color sceneryColor;
  final Color laneLineColor;
  final Color borderGlowColor;

  const TrackThemeModel({
    required this.environment,
    required this.trackColor,
    required this.trackColorAlt,
    required this.curbColor1,
    required this.curbColor2,
    required this.sceneryColor,
    required this.laneLineColor,
    required this.borderGlowColor,
  });

  static const TrackThemeModel beach = TrackThemeModel(
    environment: TrackEnvironment.beach,
    trackColor: Color(0xFFE8C288), // Warm sand
    trackColorAlt: Color(0xFFDFB87A), // Slightly deeper sand
    curbColor1: Color(0xFF38BDF8), // Ocean cyan
    curbColor2: Color(0xFFF8FAFC), // White foam
    sceneryColor: Color(0xFF0284C7), // Deep ocean blue
    laneLineColor: Color(0x66B45309), // Sand track grooves
    borderGlowColor: Color(0xFF38BDF8),
  );

  static const TrackThemeModel cyberpunk = TrackThemeModel(
    environment: TrackEnvironment.cyberpunk,
    trackColor: Color(0xFF0F172A), // Dark cyber asphalt
    trackColorAlt: Color(0xFF131E35),
    curbColor1: Color(0xFF00E5FF), // Neon cyan
    curbColor2: Color(0xFFD500F9), // Neon magenta
    sceneryColor: Color(0xFF060913),
    laneLineColor: Color(0xFF00E5FF),
    borderGlowColor: Color(0xFF00E5FF),
  );

  static const TrackThemeModel asphalt = TrackThemeModel(
    environment: TrackEnvironment.asphalt,
    trackColor: Color(0xFF1E2430), // Pro asphalt
    trackColorAlt: Color(0xFF252D3D),
    curbColor1: Color(0xFFEF4444), // Red curb
    curbColor2: Color(0xFFF9FAFB), // White curb
    sceneryColor: Color(0xFF0F172A),
    laneLineColor: Color(0xFFE2E8F0),
    borderGlowColor: Color(0xFFFFD700),
  );

  static TrackThemeModel getTheme(TrackEnvironment env) {
    switch (env) {
      case TrackEnvironment.beach:
        return beach;
      case TrackEnvironment.cyberpunk:
        return cyberpunk;
      case TrackEnvironment.asphalt:
        return asphalt;
    }
  }
}
