import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/audio/audio_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/car_model.dart';
import '../models/track_theme_model.dart';
import '../models/user_stats_model.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../widgets/car/custom_car_painter.dart';
import '../widgets/common/arcade_button.dart';
import '../widgets/common/arcade_card.dart';
import '../widgets/common/glowing_avatar.dart';
import '../widgets/common/neon_text.dart';
import '../widgets/modals/car_customizer_dialog.dart';
import '../widgets/modals/firebase_setup_guide_dialog.dart';
import '../widgets/modals/how_to_play_dialog.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import 'practice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StorageService _storageService;
  late UserStatsModel _stats;
  String _nickname = '';
  String _carId = 'sun_dazer';
  int _carColor = 0xFF00E5FF;
  int _avatarIndex = 0;
  bool _isMockMode = false;
  TrackEnvironment _selectedEnv = TrackEnvironment.beach;

  @override
  void initState() {
    super.initState();
    _storageService = Provider.of<StorageService>(context, listen: false);
    _isMockMode = !FirebaseService.isFirebaseAvailable;
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _nickname = _storageService.getNickname();
      _carId = _storageService.getCarId();
      _carColor = _storageService.getCarColor();
      _avatarIndex = _storageService.getAvatarIndex();
      _stats = _storageService.getUserStats();
    });
  }

  void _openGarage() {
    showDialog(
      context: context,
      builder: (_) => CarCustomizerDialog(
        storageService: _storageService,
        onSaved: _loadProfile,
      ),
    );
  }

  void _openHowToPlay() {
    showDialog(
      context: context,
      builder: (_) => const HowToPlayDialog(),
    );
  }

  void _openBackendStatus() {
    showDialog(
      context: context,
      builder: (_) => FirebaseSetupGuideDialog(
        isUsingMock: _isMockMode,
        onToggleMockMode: (mock) {
          setState(() {
            _isMockMode = mock;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCar = CarModel.getById(_carId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- TOP BAR: Backend Status & Settings ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _openBackendStatus,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isMockMode
                              ? [const Color(0xFFEA580C), const Color(0xFFC2410C)]
                              : [const Color(0xFF059669), const Color(0xFF047857)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (_isMockMode ? Colors.orange : Colors.green).withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isMockMode ? Icons.smart_toy_rounded : Icons.cloud_done_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isMockMode ? 'LOCAL BOT MODE' : 'ONLINE FIREBASE',
                            style: AppTypography.hudLabel.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'How to Play',
                        icon: const Icon(Icons.help_outline_rounded, color: AppColors.electricCyan, size: 22),
                        onPressed: _openHowToPlay,
                      ),
                      IconButton(
                        tooltip: 'Sound & Haptics',
                        icon: Icon(
                          AudioController.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          color: AppColors.electricCyan,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            AudioController.soundEnabled = !AudioController.soundEnabled;
                            _storageService.setSoundEnabled(AudioController.soundEnabled);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // --- BRAND LOGO WITH MULTI-LAYER NEON GLOW ---
              Center(
                child: Column(
                  children: [
                    NeonText(
                      text: 'TYPERACER',
                      glowColor: AppColors.electricCyan,
                      blurRadius: 28,
                      style: AppTypography.gameTitle.copyWith(
                        fontSize: 38,
                        letterSpacing: 4.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MULTIPLAYER TURBO SPEED RACING',
                      style: AppTypography.hudLabel.copyWith(
                        color: AppColors.electricGreen,
                        letterSpacing: 2.5,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 18),
              // --- DRIVER GARAGE SHOWCASE CARD ---
              ArcadeCard(
                onTap: _openGarage,
                borderColor: Color(_carColor),
                hasGlow: true,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GlowingAvatar(
                          avatarIndex: _avatarIndex,
                          size: 54,
                          glowColor: Color(_carColor),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _nickname,
                                      style: AppTypography.headingMedium.copyWith(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.tune_rounded, size: 16, color: AppColors.electricCyan),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${selectedCar.name} • ${_stats.racesWon} Trophies',
                                style: TextStyle(
                                  color: Color(_carColor),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 2.5D High-detail Car Showcase
                        SizedBox(
                          width: 110,
                          height: 55,
                          child: CustomPaint(
                            painter: CustomCarPainter(
                              carColor: Color(_carColor),
                              bodyType: selectedCar.bodyType,
                              nitroActive: true,
                              showHeadlightBeams: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.1, duration: 400.ms),
              const SizedBox(height: 14),
              // --- LIFETIME STATS METRIC RIBBON ---
              ArcadeCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('RACES', '${_stats.racesPlayed}'),
                    _buildStatDivider(),
                    _buildStatItem('WINS', '${_stats.racesWon}', color: AppColors.electricGreen),
                    _buildStatDivider(),
                    _buildStatItem('TOP WPM', '${_stats.bestWpm.toInt()}', color: AppColors.electricCyan),
                    _buildStatDivider(),
                    _buildStatItem('ACCURACY', '${_stats.averageAccuracy.toInt()}%', color: AppColors.electricYellow),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // --- TRACK ENVIRONMENT SELECTOR ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CIRCUIT THEME', style: AppTypography.hudLabel.copyWith(fontSize: 11)),
                  Text(
                    _selectedEnv.title.toUpperCase(),
                    style: TextStyle(
                      color: _selectedEnv == TrackEnvironment.beach
                          ? const Color(0xFF38BDF8)
                          : (_selectedEnv == TrackEnvironment.cyberpunk
                              ? AppColors.electricCyan
                              : const Color(0xFFFFD700)),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: TrackEnvironment.values.map((env) {
                  final isCur = _selectedEnv == env;
                  Color envColor = const Color(0xFF38BDF8);
                  if (env == TrackEnvironment.cyberpunk) envColor = const Color(0xFFD500F9);
                  if (env == TrackEnvironment.asphalt) envColor = const Color(0xFFFFD700);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedEnv = env),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isCur ? envColor.withValues(alpha: 0.25) : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCur ? envColor : AppColors.surfaceBorder,
                              width: isCur ? 2.0 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              env.title.split(' ')[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isCur ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // --- MAIN ARCADE ACTION BUTTONS ---
              ArcadeButton(
                text: 'PLAY WITH FRIENDS',
                icon: Icons.add_circle_outline_rounded,
                primaryColor: AppColors.electricCyan,
                textColor: Colors.black,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateRoomScreen(isMockMode: _isMockMode),
                    ),
                  ).then((_) => _loadProfile());
                },
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 12),
              ArcadeButton(
                text: 'JOIN A RACE',
                icon: Icons.login_rounded,
                primaryColor: AppColors.electricGreen,
                textColor: Colors.black,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => JoinRoomScreen(isMockMode: _isMockMode),
                    ),
                  ).then((_) => _loadProfile());
                },
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 12),
              ArcadeButton(
                text: 'OFFLINE PRACTICE & BOTS',
                icon: Icons.sports_motorsports_rounded,
                primaryColor: AppColors.neonOrange,
                isSecondary: true,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PracticeScreen(environment: _selectedEnv),
                    ),
                  ).then((_) => _loadProfile());
                },
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 20),
              // --- RULES QUICK ACTION ---
              ArcadeCard(
                onTap: _openHowToPlay,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: AppColors.electricCyan, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RULES OF THE TRACK', style: AppTypography.headingMedium.copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            'Learn how typing accuracy boosts your car and triggers Nitro!',
                            style: AppTypography.bodyMedium.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 26, color: AppColors.surfaceBorder);
  }

  Widget _buildStatItem(String label, String value, {Color color = AppColors.textPrimary}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.hudLabel.copyWith(fontSize: 9)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.hudValue.copyWith(
            fontSize: 17,
            color: color,
          ),
        ),
      ],
    );
  }
}
