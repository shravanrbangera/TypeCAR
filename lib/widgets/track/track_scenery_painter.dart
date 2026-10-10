import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/track_theme_model.dart';

class TrackSceneryPainter extends CustomPainter {
  final TrackEnvironment environment;
  final double animationValue;

  TrackSceneryPainter({
    required this.environment,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (environment) {
      case TrackEnvironment.beach:
        _drawBeachScenery(canvas, size);
        break;
      case TrackEnvironment.cyberpunk:
        _drawCyberScenery(canvas, size);
        break;
      case TrackEnvironment.asphalt:
        _drawAsphaltScenery(canvas, size);
        break;
    }
  }

  void _drawBeachScenery(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ocean waves at the top
    final oceanPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, 28));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, 22), oceanPaint);

    // Animated foam wave crest
    final foamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final wavePath = Path();
    wavePath.moveTo(0, 20);
    for (double x = 0; x <= w; x += 15) {
      final y = 20 + sin((x / 20) + (animationValue * 2 * pi)) * 3.5;
      wavePath.lineTo(x, y);
    }
    canvas.drawPath(wavePath, foamPaint);

    // Spectators along the beach fence
    final spectatorColors = [
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
    ];

    for (double x = 40; x < w - 60; x += 36) {
      final headColor = spectatorColors[(x ~/ 36) % spectatorColors.length];
      final headPaint = Paint()..color = headColor;
      canvas.drawCircle(Offset(x, 10), 3.5, headPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - 3, 14, 6, 6), const Radius.circular(2)),
        headPaint,
      );
    }

    // Beach Umbrellas
    _drawBeachUmbrella(canvas, 90, 8, const Color(0xFFFF5722), Colors.white);
    _drawBeachUmbrella(canvas, w * 0.45, 8, const Color(0xFFFFD600), const Color(0xFF00E5FF));
    _drawBeachUmbrella(canvas, w * 0.78, 8, const Color(0xFF00E676), Colors.white);

    // Palm Trees along the sides/edges
    _drawPalmTree(canvas, 18, 12);
    _drawPalmTree(canvas, w - 24, 12);
    _drawPalmTree(canvas, w * 0.60, h - 8);
  }

  void _drawBeachUmbrella(Canvas canvas, double cx, double cy, Color c1, Color c2) {
    final p1 = Paint()..color = c1;
    final p2 = Paint()..color = c2;
    // Circular striped umbrella top
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: 9),
      0,
      pi,
      true,
      p1,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: 9),
      pi / 3,
      pi / 3,
      true,
      p2,
    );
  }

  void _drawPalmTree(Canvas canvas, double cx, double cy) {
    final leafPaint = Paint()..color = const Color(0xFF15803D);
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5);
      final ex = cx + cos(angle) * 14;
      final ey = cy + sin(angle) * 10;
      canvas.drawLine(Offset(cx, cy), Offset(ex, ey), leafPaint..strokeWidth = 2.5);
    }
    // Coconuts
    final coconutPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawCircle(Offset(cx, cy), 3, coconutPaint);
  }

  void _drawCyberScenery(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glowing cyber circuit grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    for (double x = 0; x < w; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }

    // Floating Holographic Booster Arrows on track
    final boosterPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (double x = 120; x < w - 120; x += 180) {
      final arrowPath = Path()
        ..moveTo(x, h * 0.5 - 8)
        ..lineTo(x + 12, h * 0.5)
        ..lineTo(x, h * 0.5 + 8);
      canvas.drawPath(arrowPath, boosterPaint);
    }
  }

  void _drawAsphaltScenery(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Tire Skid Marks
    final skidPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final skidPath = Path()
      ..moveTo(80, h * 0.35)
      ..quadraticBezierTo(140, h * 0.40, 200, h * 0.36);
    canvas.drawPath(skidPath, skidPaint);

    final skidPath2 = Path()
      ..moveTo(w * 0.5, h * 0.65)
      ..quadraticBezierTo(w * 0.5 + 60, h * 0.60, w * 0.5 + 120, h * 0.64);
    canvas.drawPath(skidPath2, skidPaint);

    // Distance Markers on road (50m, 100m)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final markers = [
      {'x': w * 0.25, 'text': '100m'},
      {'x': w * 0.50, 'text': '200m'},
      {'x': w * 0.75, 'text': '300m'},
    ];

    for (final m in markers) {
      textPainter.text = TextSpan(
        text: m['text'] as String,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.2),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(m['x'] as double, h - 18));
    }
  }

  @override
  bool shouldRepaint(covariant TrackSceneryPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.environment != environment;
  }
}
