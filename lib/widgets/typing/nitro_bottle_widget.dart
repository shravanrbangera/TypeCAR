import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class NitroBottleWidget extends StatefulWidget {
  final int streak;
  final bool isNitroActive;

  const NitroBottleWidget({
    super.key,
    required this.streak,
    required this.isNitroActive,
  });

  @override
  State<NitroBottleWidget> createState() => _NitroBottleWidgetState();
}

class _NitroBottleWidgetState extends State<NitroBottleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillFraction = widget.isNitroActive
        ? 1.0
        : ((widget.streak % AppConstants.nitroStreakThreshold) /
                AppConstants.nitroStreakThreshold)
            .clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nitro Bottle Visual
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Outer Metallic Cylinder Frame
            Container(
              width: 38,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                border: Border.all(
                  color: widget.isNitroActive ? AppColors.neonOrange : AppColors.electricCyan,
                  width: 2.0,
                ),
                boxShadow: widget.isNitroActive
                    ? [
                        BoxShadow(
                          color: AppColors.neonOrange.withValues(alpha: 0.6),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.electricCyan.withValues(alpha: 0.25),
                          blurRadius: 10,
                        ),
                      ],
              ),
            ),
            // Glowing Blue/Orange Liquid Fill Level
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 34,
                height: 68 * fillFraction,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isNitroActive
                        ? [
                            const Color(0xFFFF1744),
                            const Color(0xFFFF9100),
                            const Color(0xFFFFEA00),
                          ]
                        : [
                            const Color(0xFF0284C7),
                            const Color(0xFF00E5FF),
                          ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _bubbleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _BubblePainter(
                        animationValue: _bubbleController.value,
                        isNitro: widget.isNitroActive,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Top Valve & Nozzle Cap
            Positioned(
              top: 0,
              child: Container(
                width: 14,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF94A3B8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            // Label / NOS Icon
            Positioned(
              top: 24,
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  widget.isNitroActive ? 'BOOST' : 'NITRO',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.isNitroActive ? '🔥 READY' : '${(fillFraction * 100).toInt()}%',
          style: AppTypography.hudLabel.copyWith(
            fontSize: 9,
            color: widget.isNitroActive ? AppColors.neonOrange : AppColors.electricCyan,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _BubblePainter extends CustomPainter {
  final double animationValue;
  final bool isNitro;

  _BubblePainter({required this.animationValue, required this.isNitro});

  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);

    for (int i = 0; i < 4; i++) {
      final x = (size.width * 0.25) + (i * 7);
      final y = size.height - (((animationValue + (i * 0.25)) % 1.0) * size.height);
      final r = 1.5 + (sin(animationValue * pi * 2 + i) * 0.8);
      canvas.drawCircle(Offset(x, y), r.clamp(1.0, 3.0), bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}
