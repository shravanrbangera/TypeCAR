import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common/neon_text.dart';

class RaceCountdownWidget extends StatefulWidget {
  final int startAtMs;
  final VoidCallback onCountdownFinished;

  const RaceCountdownWidget({
    super.key,
    required this.startAtMs,
    required this.onCountdownFinished,
  });

  @override
  State<RaceCountdownWidget> createState() => _RaceCountdownWidgetState();
}

class _RaceCountdownWidgetState extends State<RaceCountdownWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  Timer? _countdownTimer;
  int _secondsLeft = 3;
  bool _isGo = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.6, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final remainingMs = widget.startAtMs - nowMs;

    if (remainingMs <= 0 && !_isGo) {
      _isGo = true;
      _secondsLeft = 0;
      _animController.forward(from: 0.0);
      AudioController.playRaceStart();

      Timer(const Duration(milliseconds: 800), () {
        widget.onCountdownFinished();
      });
      return;
    }

    final calculatedSec = (remainingMs / 1000).ceil();
    if (calculatedSec != _secondsLeft && calculatedSec > 0) {
      setState(() {
        _secondsLeft = calculatedSec;
      });
      _animController.forward(from: 0.0);
      AudioController.playCountdownTick();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _isGo ? AppColors.electricGreen : AppColors.electricCyan,
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isGo ? AppColors.electricGreen : AppColors.electricCyan)
                        .withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isGo ? 'RACE IS ON!' : 'GET READY TO TYPE!',
                    style: AppTypography.hudLabel.copyWith(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  NeonText(
                    text: _isGo ? 'GO!' : '$_secondsLeft',
                    glowColor: _isGo ? AppColors.electricGreen : AppColors.electricCyan,
                    blurRadius: 20,
                    style: AppTypography.gameTitle.copyWith(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: _isGo ? AppColors.electricGreen : AppColors.electricCyan,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
