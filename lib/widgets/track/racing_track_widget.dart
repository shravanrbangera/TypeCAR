import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../models/player_model.dart';
import '../../models/track_theme_model.dart';
import 'racing_lane_widget.dart';
import 'track_scenery_painter.dart';

class RacingTrackWidget extends StatefulWidget {
  final List<PlayerModel> players;
  final String currentUserId;
  final double? height;
  final TrackEnvironment environment;

  const RacingTrackWidget({
    super.key,
    required this.players,
    required this.currentUserId,
    this.height,
    this.environment = TrackEnvironment.beach,
  });

  @override
  State<RacingTrackWidget> createState() => _RacingTrackWidgetState();
}

class _RacingTrackWidgetState extends State<RacingTrackWidget> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = TrackThemeModel.getTheme(widget.environment);

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final double calculatedLaneHeight = widget.height != null
            ? ((widget.height! - 40) / (widget.players.isEmpty ? 1 : widget.players.length))
                .clamp(58.0, 85.0)
            : 74.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: theme.sceneryColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.borderGlowColor.withValues(alpha: 0.8), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: theme.borderGlowColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // 1. Dynamic Environmental Scenery (Waves, umbrellas, palm trees, spectators)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: TrackSceneryPainter(
                          environment: widget.environment,
                          animationValue: _waveController.value,
                        ),
                      );
                    },
                  ),
                ),
                // 2. Track Lanes Container
                Padding(
                  padding: EdgeInsets.only(top: widget.environment == TrackEnvironment.beach ? 22 : 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Rumble Strip
                      _buildCurbStrip(theme),
                      // Lanes for each player
                      ...List.generate(widget.players.length, (index) {
                        final player = widget.players[index];
                        return RacingLaneWidget(
                          player: player,
                          isCurrentPlayer: player.id == widget.currentUserId,
                          laneIndex: index,
                          trackWidth: trackWidth,
                          laneHeight: calculatedLaneHeight,
                          theme: theme,
                        );
                      }),
                      // Bottom Rumble Strip
                      _buildCurbStrip(theme),
                    ],
                  ),
                ),
                // 3. Starting Line Checkers
                Positioned(
                  left: 65,
                  top: widget.environment == TrackEnvironment.beach ? 30 : 16,
                  bottom: 16,
                  child: CustomPaint(
                    size: const Size(12, double.infinity),
                    painter: _CheckeredLinePainter(isGold: false),
                  ),
                ),
                // 4. 3D Finish Line Arch Banner
                Positioned(
                  right: 20,
                  top: widget.environment == TrackEnvironment.beach ? 24 : 10,
                  bottom: 12,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFFFD700),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          '🏁 FINISH',
                          style: AppTypography.hudLabel.copyWith(
                            fontSize: 9,
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Expanded(
                        child: CustomPaint(
                          size: const Size(18, double.infinity),
                          painter: _CheckeredLinePainter(isGold: true),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurbStrip(TrackThemeModel theme) {
    return Container(
      height: 9,
      decoration: BoxDecoration(color: theme.curbColor1),
      child: CustomPaint(
        size: const Size(double.infinity, 9),
        painter: _CurbPatternPainter(curbColor2: theme.curbColor2),
      ),
    );
  }
}

class _CurbPatternPainter extends CustomPainter {
  final Color curbColor2;
  _CurbPatternPainter({required this.curbColor2});

  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()..color = curbColor2;
    const stripeWidth = 18.0;
    double x = 0;
    bool alt = false;

    while (x < size.width) {
      if (alt) {
        canvas.drawRect(Rect.fromLTWH(x, 0, stripeWidth, size.height), whitePaint);
      }
      x += stripeWidth;
      alt = !alt;
    }
  }

  @override
  bool shouldRepaint(covariant _CurbPatternPainter oldDelegate) => oldDelegate.curbColor2 != curbColor2;
}

class _CheckeredLinePainter extends CustomPainter {
  final bool isGold;
  _CheckeredLinePainter({this.isGold = false});

  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 6.0;
    final p1 = Paint()..color = isGold ? const Color(0xFFFFD700) : Colors.white;
    final p2 = Paint()..color = Colors.black;

    final cols = (size.width / squareSize).ceil();
    final rows = (size.height / squareSize).ceil();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final isEven = (r + c) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(c * squareSize, r * squareSize, squareSize, squareSize),
          isEven ? p1 : p2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
