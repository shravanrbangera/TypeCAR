import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/car_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/car/custom_car_painter.dart';
import '../widgets/common/neon_text.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusText = 'IGNITING TURBO ENGINE...';

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _statusText = 'CONNECTING TO FIREBASE GRID...';
    });

    await FirebaseService.initialize();
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.initialize();

    if (!mounted) return;
    setState(() {
      _statusText = 'ALL SYSTEMS GO!';
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background grid overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: CustomPaint(
                painter: _GridBackgroundPainter(),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Racing Car Icon Animated
                SizedBox(
                  width: 140,
                  height: 70,
                  child: CustomPaint(
                    painter: CustomCarPainter(
                      carColor: AppColors.electricCyan,
                      bodyType: CarBodyType.cyber,
                      nitroActive: true,
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .moveY(begin: -5, end: 5, duration: 900.ms, curve: Curves.easeInOut)
                    .shimmer(duration: 1500.ms, color: AppColors.electricCyan.withValues(alpha: 0.4)),
                const SizedBox(height: 24),
                // Game Title
                NeonText(
                  text: 'TYPERACER',
                  glowColor: AppColors.electricCyan,
                  blurRadius: 24,
                  style: AppTypography.gameTitle.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.85, 0.85)),
                const SizedBox(height: 8),
                Text(
                  'MULTIPLAYER TURBO RACING',
                  style: AppTypography.hudLabel.copyWith(
                    color: AppColors.electricGreen,
                    letterSpacing: 3.0,
                    fontSize: 12,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                const SizedBox(height: 48),
                // Status indicator
                SizedBox(
                  width: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      backgroundColor: AppColors.surfaceBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricCyan),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusText,
                  style: AppTypography.hudLabel.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.electricCyan.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;

    const gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
