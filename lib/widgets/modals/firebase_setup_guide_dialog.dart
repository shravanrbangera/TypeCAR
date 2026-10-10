import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/firebase_service.dart';
import '../common/arcade_button.dart';

class FirebaseSetupGuideDialog extends StatelessWidget {
  final bool isUsingMock;
  final ValueChanged<bool> onToggleMockMode;

  const FirebaseSetupGuideDialog({
    super.key,
    required this.isUsingMock,
    required this.onToggleMockMode,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_sync_rounded, color: AppColors.electricCyan),
                      const SizedBox(width: 8),
                      Text('BACKEND STATUS', style: AppTypography.headingMedium),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Divider(color: AppColors.surfaceBorder, height: 24),
              // Backend Status Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isUsingMock
                      ? AppColors.neonOrange.withValues(alpha: 0.12)
                      : AppColors.electricGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isUsingMock ? AppColors.neonOrange : AppColors.electricGreen,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUsingMock ? Icons.smart_toy_rounded : Icons.check_circle_rounded,
                      color: isUsingMock ? AppColors.neonOrange : AppColors.electricGreen,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUsingMock ? 'ACTIVE MODE: LOCAL BOT SIMULATION' : 'ACTIVE MODE: FIREBASE LIVE REALTIME',
                            style: AppTypography.headingMedium.copyWith(
                              fontSize: 12,
                              color: isUsingMock ? AppColors.neonOrange : AppColors.electricGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isUsingMock
                                ? 'No credentials needed! You can test full room creation, join, AI bot racers, and racing instantly.'
                                : 'Connected to Firebase Realtime Database and Anonymous Auth.',
                            style: AppTypography.bodyMedium.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Setup Instructions
              Text('HOW TO CONNECT YOUR FIREBASE PROJECT', style: AppTypography.hudLabel),
              const SizedBox(height: 8),
              _buildStepItem(
                '1',
                'Create a Firebase Project at console.firebase.google.com and enable Anonymous Auth & Realtime Database.',
              ),
              const SizedBox(height: 8),
              _buildStepItem(
                '2',
                'Run `flutterfire configure` or add `google-services.json` to android/app/.',
              ),
              const SizedBox(height: 8),
              _buildStepItem(
                '3',
                'Deploy the database security rules provided in `database.rules.json`.',
              ),
              if (FirebaseService.initErrorMessage != null) ...[
                const SizedBox(height: 14),
                Text('INITIALIZATION NOTICE', style: AppTypography.hudLabel.copyWith(color: AppColors.neonPink)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.neonPink.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    FirebaseService.initErrorMessage!,
                    style: AppTypography.bodyMedium.copyWith(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Toggle Mode Button
              ArcadeButton(
                text: isUsingMock ? 'SWITCH TO FIREBASE MODE' : 'SWITCH TO LOCAL DEMO MODE',
                isSecondary: true,
                onPressed: () {
                  onToggleMockMode(!isUsingMock);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 10),
              ArcadeButton(
                text: 'CLOSE',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(String step, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.surfaceElevated,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: AppTypography.hudLabel.copyWith(fontSize: 10, color: AppColors.electricCyan),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
        ),
      ],
    );
  }
}
