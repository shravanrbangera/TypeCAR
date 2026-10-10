import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class NitroMeterWidget extends StatelessWidget {
  final int streak;
  final bool isNitroActive;

  const NitroMeterWidget({
    super.key,
    required this.streak,
    required this.isNitroActive,
  });

  @override
  Widget build(BuildContext context) {
    final progress = isNitroActive
        ? 1.0
        : (streak % AppConstants.nitroStreakThreshold) / AppConstants.nitroStreakThreshold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNitroActive ? AppColors.neonOrange : AppColors.surfaceBorder,
          width: isNitroActive ? 2.0 : 1.0,
        ),
        boxShadow: isNitroActive
            ? [
                BoxShadow(
                  color: AppColors.neonOrange.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: isNitroActive ? AppColors.neonOrange : AppColors.electricYellow,
            size: 20,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    isNitroActive ? 'NITRO ACTIVE!' : 'NITRO STREAK',
                    style: AppTypography.hudLabel.copyWith(
                      fontSize: 9,
                      color: isNitroActive ? AppColors.neonOrange : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isNitroActive ? '🔥 BOOST' : '$streak/${AppConstants.nitroStreakThreshold}',
                    style: AppTypography.hudLabel.copyWith(
                      fontSize: 9,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: 75,
                height: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black38,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isNitroActive ? AppColors.neonOrange : AppColors.electricYellow,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
