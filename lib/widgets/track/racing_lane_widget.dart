import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../models/car_model.dart';
import '../../models/player_model.dart';
import '../../models/track_theme_model.dart';
import '../car/custom_car_painter.dart';
import '../car/floating_keys_particle_widget.dart';
import '../car/nitro_flame_widget.dart';

class RacingLaneWidget extends StatelessWidget {
  final PlayerModel player;
  final bool isCurrentPlayer;
  final int laneIndex;
  final double trackWidth;
  final double laneHeight;
  final TrackThemeModel theme;

  const RacingLaneWidget({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    required this.laneIndex,
    required this.trackWidth,
    required this.theme,
    this.laneHeight = 72,
  });

  @override
  Widget build(BuildContext context) {
    final carModel = CarModel.getById(player.carId);
    final isOdd = laneIndex % 2 == 1;

    // Track horizontal travel bounds
    final startX = 35.0;
    final endX = trackWidth - 110.0;
    final travelDistance = (endX - startX).clamp(10.0, 5000.0);
    final targetX = startX + (player.progress * travelDistance);

    return Container(
      height: laneHeight,
      decoration: BoxDecoration(
        color: isOdd ? theme.trackColor : theme.trackColorAlt,
        border: Border(
          bottom: BorderSide(
            color: theme.laneLineColor.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Track Dashed Center Markings
          Positioned.fill(
            child: CustomPaint(
              painter: _LaneDashesPainter(lineColor: theme.laneLineColor),
            ),
          ),
          // Starting line guide
          Positioned(
            left: startX + 35,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          // Animated Car Position
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: startX, end: targetX),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutQuad,
            builder: (context, animatedX, child) {
              return Positioned(
                left: animatedX,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Floating Key Particle Trail (when typing)
                    FloatingKeysParticleWidget(
                      active: player.wpm > 0 && !player.finished,
                      lastChar: player.nickname.isNotEmpty ? player.nickname[0] : '🏎️',
                    ),
                    // Nitro flame trail behind car
                    NitroFlameWidget(active: player.nitroActive),
                    // Car with Glowing Name Tag
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name Tag Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: isCurrentPlayer
                                ? const LinearGradient(
                                    colors: [Color(0xFF00E5FF), Color(0xFF2563EB)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.black87,
                                      player.carColor.withValues(alpha: 0.4),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrentPlayer
                                  ? Colors.white
                                  : player.carColor.withValues(alpha: 0.8),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isCurrentPlayer
                                    ? const Color(0xFF00E5FF).withValues(alpha: 0.5)
                                    : Colors.black45,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (player.finished) ...[
                                const Text('🏆 ', style: TextStyle(fontSize: 10)),
                              ],
                              Text(
                                player.nickname,
                                style: AppTypography.hudLabel.copyWith(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (player.wpm > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${player.wpm.toInt()} WPM',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: Color(0xFF00E676),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Prominent 2.5D Car Canvas
                        CustomPaint(
                          size: const Size(78, 36),
                          painter: CustomCarPainter(
                            carColor: player.carColor,
                            bodyType: carModel.bodyType,
                            nitroActive: player.nitroActive,
                            showHeadlightBeams: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LaneDashesPainter extends CustomPainter {
  final Color lineColor;
  _LaneDashesPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.25)
      ..strokeWidth = 2.0;

    const dashWidth = 18.0;
    const dashSpace = 20.0;
    double startX = 0.0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _LaneDashesPainter oldDelegate) => oldDelegate.lineColor != lineColor;
}
