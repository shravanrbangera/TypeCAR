import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlowingAvatar extends StatelessWidget {
  final int avatarIndex;
  final double size;
  final Color glowColor;
  final bool isReady;
  final bool showBadge;

  const GlowingAvatar({
    super.key,
    required this.avatarIndex,
    this.size = 48,
    this.glowColor = AppColors.electricCyan,
    this.isReady = false,
    this.showBadge = false,
  });

  static const List<IconData> avatarIcons = [
    Icons.sports_motorsports_rounded,
    Icons.speed_rounded,
    Icons.electric_bolt_rounded,
    Icons.flight_takeoff_rounded,
    Icons.military_tech_rounded,
    Icons.psychology_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final icon = avatarIcons[avatarIndex % avatarIcons.length];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceElevated,
            border: Border.all(
              color: isReady ? AppColors.electricGreen : glowColor,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isReady ? AppColors.electricGreen : glowColor).withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: isReady ? AppColors.electricGreen : glowColor,
              size: size * 0.55,
            ),
          ),
        ),
        if (showBadge)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isReady ? AppColors.electricGreen : Colors.orange,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: Icon(
                isReady ? Icons.check : Icons.hourglass_top_rounded,
                size: size * 0.28,
                color: Colors.black,
              ),
            ),
          ),
      ],
    );
  }
}
