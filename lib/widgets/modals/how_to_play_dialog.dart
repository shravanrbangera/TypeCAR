import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../common/arcade_button.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sports_esports_rounded, color: AppColors.electricCyan),
                    const SizedBox(width: 8),
                    Text('HOW TO PLAY', style: AppTypography.headingMedium),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Divider(color: AppColors.surfaceBorder, height: 24),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildRuleItem(
                      step: '1',
                      title: 'TYPE ACCURATELY & FAST',
                      description: 'Type the exact paragraph shown on screen. Every correct character advances your car down the track.',
                      icon: Icons.keyboard_rounded,
                      color: AppColors.electricCyan,
                    ),
                    const SizedBox(height: 14),
                    _buildRuleItem(
                      step: '2',
                      title: 'FIX MISTAKES TO ADVANCE',
                      description: 'If you make a mistake, it turns red. You must hit Backspace to fix it before your car can continue accelerating.',
                      icon: Icons.backspace_rounded,
                      color: AppColors.neonPink,
                    ),
                    const SizedBox(height: 14),
                    _buildRuleItem(
                      step: '3',
                      title: 'UNLEASH NITRO BOOST',
                      description: 'Hit a streak of ${AppConstants.nitroStreakThreshold} flawless characters in a row to activate Nitro Boost with fiery exhaust flames!',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.neonOrange,
                    ),
                    const SizedBox(height: 14),
                    _buildRuleItem(
                      step: '4',
                      title: 'RACE YOUR FRIENDS',
                      description: 'Create a room to get a 6-letter room code. Share it with up to 8 friends for synchronized real-time multiplayer racing!',
                      icon: Icons.groups_rounded,
                      color: AppColors.electricGreen,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ArcadeButton(
              text: 'GOT IT, LET\'S RACE!',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem({
    required String step,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headingMedium.copyWith(fontSize: 13, color: color)),
                const SizedBox(height: 4),
                Text(description, style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
