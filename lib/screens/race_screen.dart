import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/wpm_calculator.dart';
import '../models/room_model.dart';
import '../models/track_theme_model.dart';
import '../services/auth_service.dart';
import '../services/mock_room_service.dart';
import '../services/room_service.dart';
import '../services/room_service_interface.dart';
import '../services/storage_service.dart';
import '../services/typing_engine.dart';
import '../widgets/track/race_countdown_widget.dart';
import '../widgets/track/racing_track_widget.dart';
import '../widgets/typing/typing_panel_widget.dart';
import 'results_screen.dart';

class RaceScreen extends StatefulWidget {
  final String roomCode;
  final bool isMockMode;
  final TrackEnvironment environment;

  const RaceScreen({
    super.key,
    required this.roomCode,
    this.isMockMode = false,
    this.environment = TrackEnvironment.beach,
  });

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  late TypingEngine _typingEngine;
  late TextEditingController _textController;
  late FocusNode _focusNode;
  
  StreamSubscription<RoomModel?>? _roomSubscription;
  RoomModel? _room;
  
  bool _isCountdownActive = true;
  bool _isRaceActive = false;
  bool _hasFinishedNavigated = false;
  
  Timer? _syncDebounceTimer;
  double _lastSyncedProgress = -1.0;

  @override
  void initState() {
    super.initState();
    _typingEngine = TypingEngine();
    _textController = TextEditingController();
    _focusNode = FocusNode();

    _typingEngine.addListener(_onTypingEngineUpdated);
    _subscribeToRoom();
  }

  void _subscribeToRoom() {
    final IRoomService roomService = widget.isMockMode
        ? Provider.of<MockRoomService>(context, listen: false)
        : Provider.of<RoomService>(context, listen: false);

    _roomSubscription = roomService.roomStream(widget.roomCode).listen((room) {
      if (!mounted) return;

      if (room == null || room.status == RoomStatus.closed) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }

      final isFirstLoad = _room == null;
      setState(() {
        _room = room;
      });

      if (isFirstLoad) {
        _typingEngine.resetWithText(room.race.targetText);
      }

      // If race concluded, transition to results
      if (room.status == RoomStatus.finished && !_hasFinishedNavigated && _typingEngine.isFinished) {
        _navigateToResults();
      }
    });
  }

  void _onTypingEngineUpdated() {
    if (!mounted) return;
    setState(() {});

    final authService = Provider.of<AuthService>(context, listen: false);
    final myId = authService.currentUserId;

    final progress = _typingEngine.progress;
    final wpm = _typingEngine.currentWpm;
    final accuracy = _typingEngine.accuracy;
    final finished = _typingEngine.isFinished;
    final isNitro = _typingEngine.isNitroActive;

    if ((progress - _lastSyncedProgress).abs() > 0.02 || finished) {
      _lastSyncedProgress = progress;
      _syncProgress(myId, progress, wpm, accuracy, finished, isNitro);
    }

    if (finished && !_hasFinishedNavigated) {
      _handleLocalPlayerFinished();
    }
  }

  void _syncProgress(
    String myId,
    double progress,
    double wpm,
    double accuracy,
    bool finished,
    bool isNitro,
  ) {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      final IRoomService roomService = widget.isMockMode
          ? Provider.of<MockRoomService>(context, listen: false)
          : Provider.of<RoomService>(context, listen: false);

      roomService.updateProgress(
        roomCode: widget.roomCode,
        playerId: myId,
        progress: progress,
        wpm: wpm,
        accuracy: accuracy,
        finished: finished,
        nitroActive: isNitro,
      );
    });
  }

  Future<void> _handleLocalPlayerFinished() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    final stats = storageService.getUserStats();
    final authService = Provider.of<AuthService>(context, listen: false);
    final myId = authService.currentUserId;

    final isWinner = _room?.race.winnerId == myId || _room?.race.winnerId == null;
    final wordsCount = (_typingEngine.correctCharactersCount / 5.0).round();

    final updatedStats = stats.recordRaceResult(
      won: isWinner,
      raceWpm: _typingEngine.currentWpm,
      raceAccuracy: _typingEngine.accuracy,
      wordsCount: wordsCount,
    );
    await storageService.saveUserStats(updatedStats);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && !_hasFinishedNavigated) {
        _navigateToResults();
      }
    });
  }

  void _navigateToResults() {
    _hasFinishedNavigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          roomCode: widget.roomCode,
          isMockMode: widget.isMockMode,
        ),
      ),
    );
  }

  void _onCountdownFinished() {
    setState(() {
      _isCountdownActive = false;
      _isRaceActive = true;
    });
    _typingEngine.startRace();
    _focusNode.requestFocus();
  }

  Future<void> _handleExitRace() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('FORFEIT RACE?', style: AppTypography.headingMedium),
        content: Text(
          'Leaving now will forfeit the race and return to the main menu.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('STAY & RACE', style: TextStyle(color: AppColors.electricCyan)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPink),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('FORFEIT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final IRoomService roomService = widget.isMockMode
          ? Provider.of<MockRoomService>(context, listen: false)
          : Provider.of<RoomService>(context, listen: false);

      await roomService.leaveRoom(widget.roomCode, authService.currentUserId);
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  void dispose() {
    _typingEngine.removeListener(_onTypingEngineUpdated);
    _typingEngine.dispose();
    _roomSubscription?.cancel();
    _syncDebounceTimer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final myId = authService.currentUserId;
    final players = _room?.playerList ?? [];

    int myPosition = 1;
    if (_room != null) {
      final leaderboard = _room!.leaderboard;
      final myIndex = leaderboard.indexWhere((p) => p.id == myId);
      if (myIndex != -1) {
        myPosition = myIndex + 1;
      }
    }

    final startAtMs = _room?.race.startAt ?? DateTime.now().millisecondsSinceEpoch + 3000;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Telemetry Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.neonPink, size: 22),
                            onPressed: _handleExitRace,
                            tooltip: 'Exit Race',
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Text(
                              'ROOM: ${widget.roomCode}',
                              style: AppTypography.hudLabel.copyWith(
                                color: AppColors.electricCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Elapsed Timer Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: AppColors.electricYellow),
                            const SizedBox(width: 6),
                            Text(
                              WpmCalculator.formatDuration(_typingEngine.elapsedSeconds),
                              style: AppTypography.hudValue.copyWith(
                                fontSize: 14,
                                color: AppColors.electricYellow,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // --- SCENIC RACETRACK ---
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: RacingTrackWidget(
                      players: players,
                      currentUserId: myId,
                      environment: widget.environment,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // --- INTEGRATED COCKPIT DASHBOARD & TYPING PANEL ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TypingPanelWidget(
                    typingEngine: _typingEngine,
                    textController: _textController,
                    focusNode: _focusNode,
                    isRaceActive: _isRaceActive,
                    position: myPosition,
                    totalRacers: players.length,
                  ),
                ),
              ],
            ),
            // Countdown Overlay
            if (_isCountdownActive)
              Positioned.fill(
                child: RaceCountdownWidget(
                  startAtMs: startAtMs,
                  onCountdownFinished: _onCountdownFinished,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
