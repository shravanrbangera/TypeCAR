import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'nitro_meter_widget.dart';

class TypingHudWidget extends StatelessWidget {
  final double wpm;
  final double accuracy;
  final int position;
  final int totalRacers;
  final int streak;
  final bool isNitroActive;
  final double progress;

  const TypingHudWidget({
    super.key,
    required this.wpm,
    required this.accuracy,
    required this.position,
    required this.totalRacers,
    required this.streak,
    required this.isNitroActive,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Position Rank
          _buildMetricItem(
            label: 'POSITION',
            value: position > 0 ? '#$position' : '--',
            subText: totalRacers > 0 ? '/ $totalRacers' : '',
            valueColor: _getPositionColor(position),
          ),
          _buildDivider(),
          // Speed WPM
          _buildMetricItem(
            label: 'SPEED',
            value: wpm.toInt().toString(),
            subText: 'WPM',
            valueColor: AppColors.electricCyan,
          ),
          _buildDivider(),
          // Accuracy
          _buildMetricItem(
            label: 'ACCURACY',
            value: '${accuracy.toInt()}%',
            subText: '',
            valueColor: accuracy > 95
                ? AppColors.electricGreen
                : (accuracy > 85 ? AppColors.electricYellow : AppColors.neonPink),
          ),
          _buildDivider(),
          // Nitro Streak Meter
          NitroMeterWidget(
            streak: streak,
            isNitroActive: isNitroActive,
          ),
        ],
      ),
    );
  }

  Color _getPositionColor(int pos) {
    switch (pos) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFE2E8F0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.textPrimary;
    }
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.surfaceBorder,
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required String subText,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: AppTypography.hudLabel),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTypography.hudValue.copyWith(
                color: valueColor,
                fontSize: 20,
              ),
            ),
            if (subText.isNotEmpty) ...[
              const SizedBox(width: 3),
              Text(
                subText,
                style: AppTypography.hudLabel.copyWith(fontSize: 10),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
