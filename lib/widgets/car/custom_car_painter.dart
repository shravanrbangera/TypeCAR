import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/car_model.dart';

class CustomCarPainter extends CustomPainter {
  final Color carColor;
  final CarBodyType bodyType;
  final bool nitroActive;
  final double wheelAngle;
  final bool showHeadlightBeams;

  CustomCarPainter({
    required this.carColor,
    required this.bodyType,
    this.nitroActive = false,
    this.wheelAngle = 0.0,
    this.showHeadlightBeams = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw Headlight Beams (casting forward on the track)
    if (showHeadlightBeams) {
      _drawHeadlightBeams(canvas, size);
    }

    // 2. Realistic Ground Drop Shadow with tire contact patches
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.16, w * 0.88, h * 0.72),
        const Radius.circular(10),
      ),
      shadowPaint,
    );

    // 3. Draw Specific Car Model Body with 3D Depth
    switch (bodyType) {
      case CarBodyType.f1:
        _drawF1Apex(canvas, size);
        break;
      case CarBodyType.buggy:
        _drawSunDazerBuggy(canvas, size);
        break;
      case CarBodyType.retro:
        _drawOldTimerMuscle(canvas, size);
        break;
      case CarBodyType.truck:
        _drawSkullCrusherTruck(canvas, size);
        break;
      case CarBodyType.cyber:
        _drawPhantomHypercar(canvas, size);
        break;
      case CarBodyType.supercar:
        _drawCyberSupercar(canvas, size);
        break;
    }

    // 4. Exhaust Particles & Nitro Flames
    if (nitroActive) {
      _drawMegaNitroFlame(canvas, size);
    }
  }

  void _drawHeadlightBeams(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.35),
          const Color(0xFF00E5FF).withValues(alpha: 0.0),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(w * 0.85, 0, w * 0.6, h));

    // Top Beam
    final topBeam = Path()
      ..moveTo(w * 0.88, h * 0.28)
      ..lineTo(w * 1.45, h * 0.08)
      ..lineTo(w * 1.45, h * 0.45)
      ..lineTo(w * 0.88, h * 0.36)
      ..close();
    canvas.drawPath(topBeam, beamPaint);

    // Bottom Beam
    final botBeam = Path()
      ..moveTo(w * 0.88, h * 0.64)
      ..lineTo(w * 1.45, h * 0.55)
      ..lineTo(w * 1.45, h * 0.92)
      ..lineTo(w * 0.88, h * 0.72)
      ..close();
    canvas.drawPath(botBeam, beamPaint);
  }

  void _drawHighDetailWheels(
    Canvas canvas,
    Size size, {
    double wheelW = 0.20,
    double wheelH = 0.28,
    bool isWide = false,
  }) {
    final w = size.width;
    final h = size.height;

    final tireRubber = Paint()..color = const Color(0xFF1E293B);
    final tireTread = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rimChrome = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Color(0xFF64748B), Color(0xFFF8FAFC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final caliperPaint = Paint()..color = const Color(0xFFFF1744);

    final positions = [
      Offset(w * 0.22, h * 0.07), // Front-top
      Offset(w * 0.22, h * 0.93), // Front-bottom
      Offset(w * 0.80, h * 0.07), // Rear-top
      Offset(w * 0.80, h * 0.93), // Rear-bottom
    ];

    for (final pos in positions) {
      final rect = Rect.fromCenter(
        center: pos,
        width: w * (isWide ? wheelW * 1.2 : wheelW),
        height: h * wheelH,
      );

      // Rubber Tire with rounded tread
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), tireRubber);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), tireTread);

      // Brake Caliper
      canvas.drawRect(
        Rect.fromCenter(center: Offset(pos.dx, pos.dy), width: w * (wheelW * 0.7), height: h * (wheelH * 0.7)),
        caliperPaint,
      );

      // Chrome Alloy Rim
      final rimRect = Rect.fromCenter(
        center: pos,
        width: w * (wheelW * 0.55),
        height: h * (wheelH * 0.55),
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rimRect, const Radius.circular(3)), rimChrome);

      // Center Hub Nut in car accent color
      canvas.drawCircle(pos, 2.5, Paint()..color = carColor);
    }
  }

  // --- 1. SUPERCAR (Cyber Neon Coupe) ---
  void _drawCyberSupercar(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawHighDetailWheels(canvas, size, wheelW: 0.18, wheelH: 0.28);

    // Sculpted Metallic Body
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          carColor,
          carColor.withValues(alpha: 0.9),
          HSLColor.fromColor(carColor).withLightness(0.25).toColor(),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path = Path()
      ..moveTo(w * 0.94, h * 0.5) // Front aerodynamic nose
      ..lineTo(w * 0.86, h * 0.20)
      ..lineTo(w * 0.65, h * 0.22) // Front fender
      ..lineTo(w * 0.40, h * 0.18) // Roofline
      ..lineTo(w * 0.12, h * 0.20) // Rear quarter
      ..lineTo(w * 0.06, h * 0.35)
      ..lineTo(w * 0.05, h * 0.65) // Rear diffuser
      ..lineTo(w * 0.12, h * 0.80)
      ..lineTo(w * 0.40, h * 0.82)
      ..lineTo(w * 0.65, h * 0.78)
      ..lineTo(w * 0.86, h * 0.80)
      ..close();
    canvas.drawPath(path, bodyPaint);

    // Specular Highlight Streak across body
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.6), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.2, h * 0.25, w * 0.6, h * 0.15));
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.24, w * 0.55, 3), highlightPaint);

    // Tinted Aero Cockpit Windshield with Sky Reflection
    final glassPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF0F172A), Color(0xFF1E293B)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(w * 0.35, h * 0.26, w * 0.35, h * 0.48));

    final glassPath = Path()
      ..moveTo(w * 0.70, h * 0.5)
      ..lineTo(w * 0.60, h * 0.30)
      ..lineTo(w * 0.36, h * 0.32)
      ..lineTo(w * 0.30, h * 0.5)
      ..lineTo(w * 0.36, h * 0.68)
      ..lineTo(w * 0.60, h * 0.70)
      ..close();
    canvas.drawPath(glassPath, glassPaint);

    // Dual LED Headlights
    final ledPaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.86, h * 0.25, w * 0.06, h * 0.10), const Radius.circular(2)),
      ledPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.86, h * 0.65, w * 0.06, h * 0.10), const Radius.circular(2)),
      ledPaint,
    );

    // Carbon Fiber GT Rear Wing
    final wingPaint = Paint()..color = const Color(0xFF0B0F19);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.04, h * 0.16, w * 0.07, h * 0.68), const Radius.circular(3)),
      wingPaint,
    );
    // Wing endplates in car color
    canvas.drawRect(Rect.fromLTWH(w * 0.03, h * 0.14, w * 0.09, 3), Paint()..color = carColor);
    canvas.drawRect(Rect.fromLTWH(w * 0.03, h * 0.83, w * 0.09, 3), Paint()..color = carColor);
  }

  // --- 2. FORMULA 1 APEX ---
  void _drawF1Apex(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawHighDetailWheels(canvas, size, wheelW: 0.20, wheelH: 0.32, isWide: true);

    // Monocoque & Sidepods Body
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          carColor,
          Colors.white.withValues(alpha: 0.9),
          carColor,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path = Path()
      ..moveTo(w * 0.97, h * 0.5) // Needle nose
      ..lineTo(w * 0.70, h * 0.38)
      ..lineTo(w * 0.55, h * 0.26) // Sculpted sidepod intake
      ..lineTo(w * 0.22, h * 0.32)
      ..lineTo(w * 0.08, h * 0.42)
      ..lineTo(w * 0.08, h * 0.58)
      ..lineTo(w * 0.22, h * 0.68)
      ..lineTo(w * 0.55, h * 0.74)
      ..lineTo(w * 0.70, h * 0.62)
      ..close();
    canvas.drawPath(path, bodyPaint);

    // Front Aerodynamic Multi-Element Wing
    final carbonPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.88, h * 0.12, w * 0.06, h * 0.76), const Radius.circular(2)),
      carbonPaint,
    );

    // Rear High-Downforce Wing with DRS Flap
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.03, h * 0.08, w * 0.07, h * 0.84), const Radius.circular(3)),
      carbonPaint,
    );

    // Cockpit & Halo Titanium Ring
    final cockpitHole = Paint()..color = const Color(0xFF090D16);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.48, h * 0.5), width: w * 0.24, height: h * 0.30),
      cockpitHole,
    );

    // Driver Racing Helmet with Gold Visor
    final helmetPaint = Paint()..color = const Color(0xFFFFD600);
    canvas.drawCircle(Offset(w * 0.48, h * 0.5), h * 0.12, helmetPaint);
    final visorPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.50, h * 0.5), radius: h * 0.09),
      -pi / 3,
      2 * pi / 3,
      true,
      visorPaint,
    );
  }

  // --- 3. SUN DAZER BEACH BUGGY ---
  void _drawSunDazerBuggy(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Big knobby offroad tires
    _drawHighDetailWheels(canvas, size, wheelW: 0.24, wheelH: 0.36, isWide: true);

    // Fiberglass Buggy Tub
    final tubPaint = Paint()
      ..shader = LinearGradient(
        colors: [carColor, HSLColor.fromColor(carColor).withLightness(0.3).toColor()],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.16, h * 0.22, w * 0.68, h * 0.56));

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.16, h * 0.22, w * 0.68, h * 0.56), const Radius.circular(10)),
      tubPaint,
    );

    // Chrome Roll Cage Tubular Bars
    final barPaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.30, h * 0.26, w * 0.38, h * 0.48), const Radius.circular(6)),
      barPaint,
    );
    canvas.drawLine(Offset(w * 0.30, h * 0.26), Offset(w * 0.68, h * 0.74), barPaint);
    canvas.drawLine(Offset(w * 0.30, h * 0.74), Offset(w * 0.68, h * 0.26), barPaint);

    // Yellow Baja Fog Lamps
    final fogPaint = Paint()..color = const Color(0xFFFFEA00);
    canvas.drawCircle(Offset(w * 0.85, h * 0.30), 5.5, fogPaint);
    canvas.drawCircle(Offset(w * 0.85, h * 0.70), 5.5, fogPaint);

    // Driver in beach visor
    canvas.drawCircle(Offset(w * 0.46, h * 0.5), 6.5, Paint()..color = const Color(0xFFF97316));
  }

  // --- 4. OLD TIMER RETRO MUSCLE ---
  void _drawOldTimerMuscle(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawHighDetailWheels(canvas, size, wheelW: 0.20, wheelH: 0.32);

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [carColor, HSLColor.fromColor(carColor).withLightness(0.2).toColor()],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path = Path()
      ..moveTo(w * 0.92, h * 0.5)
      ..lineTo(w * 0.90, h * 0.20)
      ..lineTo(w * 0.12, h * 0.20)
      ..lineTo(w * 0.08, h * 0.35)
      ..lineTo(w * 0.08, h * 0.65)
      ..lineTo(w * 0.12, h * 0.80)
      ..lineTo(w * 0.90, h * 0.80)
      ..close();
    canvas.drawPath(path, bodyPaint);

    // Double White Racing Stripes
    final stripePaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawRect(Rect.fromLTWH(w * 0.08, h * 0.42, w * 0.84, h * 0.06), stripePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.08, h * 0.52, w * 0.84, h * 0.06), stripePaint);

    // Chrome Blower / Supercharger Hood Scoop
    final blowerPaint = Paint()..color = const Color(0xFFCBD5E1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.58, h * 0.36, w * 0.18, h * 0.28), const Radius.circular(4)),
      blowerPaint,
    );
    canvas.drawCircle(Offset(w * 0.74, h * 0.44), 3, Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(Offset(w * 0.74, h * 0.56), 3, Paint()..color = const Color(0xFFEF4444));
  }

  // --- 5. SKULL CRUSHER MONSTER TRUCK ---
  void _drawSkullCrusherTruck(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Massive monster treads
    _drawHighDetailWheels(canvas, size, wheelW: 0.28, wheelH: 0.40, isWide: true);

    final truckPaint = Paint()..color = carColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.24, w * 0.64, h * 0.52), const Radius.circular(8)),
      truckPaint,
    );

    // Roof Lightbar (4 Orange Xenon Lamps)
    final lightbarPaint = Paint()..color = const Color(0xFFFF9100);
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(Offset(w * 0.42 + (i * 7), h * 0.20), 3, lightbarPaint);
      canvas.drawCircle(Offset(w * 0.42 + (i * 7), h * 0.80), 3, lightbarPaint);
    }
  }

  // --- 6. PHANTOM HYPERCAR ---
  void _drawPhantomHypercar(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawHighDetailWheels(canvas, size, wheelW: 0.18, wheelH: 0.26);

    // Stealth Fighter Geometry
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          carColor,
          const Color(0xFF0F172A),
          carColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path = Path()
      ..moveTo(w * 0.98, h * 0.5)
      ..lineTo(w * 0.78, h * 0.18)
      ..lineTo(w * 0.45, h * 0.20)
      ..lineTo(w * 0.15, h * 0.16)
      ..lineTo(w * 0.04, h * 0.5)
      ..lineTo(w * 0.15, h * 0.84)
      ..lineTo(w * 0.45, h * 0.80)
      ..lineTo(w * 0.78, h * 0.82)
      ..close();
    canvas.drawPath(path, bodyPaint);

    // Neon Glow Line Edges
    final edgePaint = Paint()
      ..color = carColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
    canvas.drawPath(path, edgePaint);
  }

  // --- MEGA NITRO BOOST FLAME EFFECT ---
  void _drawMegaNitroFlame(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final flameCore = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFF00E5FF),
          Color(0xFFFF9100),
          Color(0xFFFF1744),
          Colors.transparent,
        ],
        stops: [0.1, 0.35, 0.65, 0.85, 1.0],
      ).createShader(Rect.fromLTWH(-w * 0.55, h * 0.15, w * 0.65, h * 0.70));

    final flamePath = Path()
      ..moveTo(w * 0.05, h * 0.35)
      ..lineTo(-w * 0.45, h * 0.5)
      ..lineTo(w * 0.05, h * 0.65)
      ..close();

    canvas.drawPath(flamePath, flameCore);

    // Floating Nitro Energy Sparks
    final sparkPaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(-w * 0.20, h * 0.28), 2.5, sparkPaint);
    canvas.drawCircle(Offset(-w * 0.35, h * 0.62), 2.0, sparkPaint);
    canvas.drawCircle(Offset(-w * 0.50, h * 0.48), 3.0, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomCarPainter oldDelegate) {
    return oldDelegate.carColor != carColor ||
        oldDelegate.bodyType != bodyType ||
        oldDelegate.nitroActive != nitroActive ||
        oldDelegate.showHeadlightBeams != showHeadlightBeams;
  }
}
