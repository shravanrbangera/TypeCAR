import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/sample_texts.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/player_model.dart';
import '../models/track_theme_model.dart';
import '../services/storage_service.dart';
import '../services/typing_engine.dart';
import '../widgets/common/arcade_button.dart';
import '../widgets/track/race_countdown_widget.dart';
import '../widgets/track/racing_track_widget.dart';
import '../widgets/typing/typing_panel_widget.dart';

class PracticeScreen extends StatefulWidget {
  final TrackEnvironment environment;

  const PracticeScreen({
    super.key,
    this.environment = TrackEnvironment.beach,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late TypingEngine _typingEngine;
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late StorageService _storageService;

  final TextCategory _category = TextCategory.funFacts;
  final TextDifficulty _difficulty = TextDifficulty.medium;

  bool _isCountdownActive = true;
  bool _isRaceActive = false;
  int _countdownStartTime = 0;

  // Bot Racers for practice
  final List<PlayerModel> _practiceRacers = [];
  Timer? _botTimer;

  @override
  void initState() {
    super.initState();
    _typingEngine = TypingEngine();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _storageService = Provider.of<StorageService>(context, listen: false);

    _typingEngine.addListener(_onTypingEngineUpdated);
    _startNewPracticeRound();
  }

  void _startNewPracticeRound() {
    _botTimer?.cancel();
    _textController.clear();
    final textItem = SampleTexts.getRandomText(category: _category, difficulty: _difficulty);
    _typingEngine.resetWithText(textItem.text);

    // Setup Local Player and AI Bots
    final myNickname = _storageService.getNickname();
    final myCarId = _storageService.getCarId();
    final myColor = _storageService.getCarColor();
    final myAvatar = _storageService.getAvatarIndex();

    _practiceRacers.clear();
    _practiceRacers.add(
      PlayerModel(
        id: 'me',
        nickname: myNickname,
        carId: myCarId,
        carColorValue: myColor,
        avatarIndex: myAvatar,
        connected: true,
        isHost: true,
        isReady: true,
      ),
    );

    // Add 2 Practice AI Bots with unique color schemes
    _practiceRacers.add(
      const PlayerModel(
        id: 'bot_turbo',
        nickname: 'TurboBot 🤖',
        carId: 'lightning_f1',
        carColorValue: 0xFFFF1744,
        connected: true,
        isBot: true,
      ),
    );
    _practiceRacers.add(
      const PlayerModel(
        id: 'bot_cyber',
        nickname: 'CyberDrifter ⚡',
        carId: 'cyber_blade',
        carColorValue: 0xFFD500F9,
        connected: true,
        isBot: true,
      ),
    );

    _isCountdownActive = true;
    _isRaceActive = false;
    _countdownStartTime = DateTime.now().millisecondsSinceEpoch + 3000;
    setState(() {});
  }

  void _onCountdownFinished() {
    setState(() {
      _isCountdownActive = false;
      _isRaceActive = true;
    });
    _typingEngine.startRace();
    _focusNode.requestFocus();
    _startBotSimulation();
  }

  void _startBotSimulation() {
    final startTime = DateTime.now();
    final random = Random();
    final textLength = _typingEngine.targetText.length;
    final botWpms = {
      'bot_turbo': 52.0 + random.nextDouble() * 15,
      'bot_cyber': 45.0 + random.nextDouble() * 18,
    };

    _botTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!_isRaceActive) {
        timer.cancel();
        return;
      }

      final elapsed = max(0.1, DateTime.now().difference(startTime).inMilliseconds / 1000.0);
      bool allDone = true;

      for (int i = 1; i < _practiceRacers.length; i++) {
        final bot = _practiceRacers[i];
        if (bot.finished) continue;

        allDone = false;
        final targetWpm = botWpms[bot.id] ?? 50.0;
        final charsPerSec = (targetWpm * 5.0) / 60.0;
        final currentChars = charsPerSec * elapsed;
        final progress = (currentChars / textLength).clamp(0.0, 1.0);
        final isDone = progress >= 1.0;

        _practiceRacers[i] = bot.copyWith(
          progress: progress,
          wpm: targetWpm + (random.nextDouble() * 4 - 2),
          accuracy: 96.0,
          finished: isDone,
          nitroActive: random.nextDouble() < 0.25,
        );
      }

      if (mounted) setState(() {});
      if (allDone) timer.cancel();
    });
  }

  void _onTypingEngineUpdated() {
    if (!mounted) return;

    if (_practiceRacers.isNotEmpty) {
      _practiceRacers[0] = _practiceRacers[0].copyWith(
        progress: _typingEngine.progress,
        wpm: _typingEngine.currentWpm,
        accuracy: _typingEngine.accuracy,
        finished: _typingEngine.isFinished,
        nitroActive: _typingEngine.isNitroActive,
      );
    }

    if (_typingEngine.isFinished && _isRaceActive) {
      _isRaceActive = false;
      _botTimer?.cancel();
      _savePracticeStats();
    }

    setState(() {});
  }

  Future<void> _savePracticeStats() async {
    final stats = _storageService.getUserStats();
    final isWinner = _practiceRacers.every((r) => r.id == 'me' || !r.finished || r.wpm <= _typingEngine.currentWpm);
    final wordsCount = (_typingEngine.correctCharactersCount / 5.0).round();

    final updatedStats = stats.recordRaceResult(
      won: isWinner,
      raceWpm: _typingEngine.currentWpm,
      raceAccuracy: _typingEngine.accuracy,
      wordsCount: wordsCount,
    );
    await _storageService.saveUserStats(updatedStats);
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    _typingEngine.removeListener(_onTypingEngineUpdated);
    _typingEngine.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Bar with Navigation and Next Action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Text('OFFLINE PRACTICE', style: AppTypography.headingMedium.copyWith(fontSize: 16)),
                        ],
                      ),
                      // Refresh button
                      TextButton.icon(
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.electricCyan, size: 18),
                        label: Text(
                          'NEXT TEXT',
                          style: AppTypography.buttonText.copyWith(color: AppColors.electricCyan, fontSize: 11),
                        ),
                        onPressed: _startNewPracticeRound,
                      ),
                    ],
                  ),
                ),
                // Scenic Practice Track with Animated Waves / Trees
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: RacingTrackWidget(
                      players: _practiceRacers,
                      currentUserId: 'me',
                      environment: widget.environment,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Cockpit Dashboard Typing Panel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TypingPanelWidget(
                    typingEngine: _typingEngine,
                    textController: _textController,
                    focusNode: _focusNode,
                    isRaceActive: _isRaceActive,
                    position: 1,
                    totalRacers: _practiceRacers.length,
                  ),
                ),
                // Retry Banner on Finish
                if (_typingEngine.isFinished)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                    child: ArcadeButton(
                      text: 'PRACTICE AGAIN',
                      icon: Icons.replay_rounded,
                      primaryColor: AppColors.electricGreen,
                      onPressed: _startNewPracticeRound,
                    ),
                  ),
              ],
            ),
            // Countdown Overlay
            if (_isCountdownActive)
              Positioned.fill(
                child: RaceCountdownWidget(
                  startAtMs: _countdownStartTime,
                  onCountdownFinished: _onCountdownFinished,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
