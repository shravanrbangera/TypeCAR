import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/car_model.dart';
import '../models/player_model.dart';
import '../models/room_model.dart';
import '../services/auth_service.dart';
import '../services/mock_room_service.dart';
import '../services/room_service.dart';
import '../services/room_service_interface.dart';
import '../widgets/car/custom_car_painter.dart';
import '../widgets/common/arcade_button.dart';
import '../widgets/common/arcade_card.dart';
import '../widgets/common/glowing_avatar.dart';
import '../widgets/common/neon_text.dart';
import 'lobby_screen.dart';

class ResultsScreen extends StatefulWidget {
  final String roomCode;
  final bool isMockMode;

  const ResultsScreen({
    super.key,
    required this.roomCode,
    this.isMockMode = false,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late ConfettiController _confettiController;
  StreamSubscription<RoomModel?>? _roomSubscription;
  RoomModel? _room;
  bool _isNavigatingToLobby = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();
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

      setState(() {
        _room = room;
      });

      // If host initiated a rematch, navigate all players back to lobby
      if (room.status == RoomStatus.waiting && !_isNavigatingToLobby) {
        _isNavigatingToLobby = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LobbyScreen(
              roomCode: widget.roomCode,
              isHost: room.hostId == Provider.of<AuthService>(context, listen: false).currentUserId,
              isMockMode: widget.isMockMode,
            ),
          ),
        );
      }
    });
  }

  Future<void> _handleRematch() async {
    if (_room == null) return;
    final IRoomService roomService = widget.isMockMode
        ? Provider.of<MockRoomService>(context, listen: false)
        : Provider.of<RoomService>(context, listen: false);

    await roomService.requestRematch(
      widget.roomCode,
      _room!.race.category,
      _room!.race.difficulty,
    );
  }

  void _returnHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _roomSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final myId = authService.currentUserId;
    final isHost = _room?.hostId == myId;

    final leaderboard = _room?.leaderboard ?? [];
    final winner = leaderboard.isNotEmpty ? leaderboard.first : null;
    final isMeWinner = winner?.id == myId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Confetti Particle Explosion
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.electricCyan,
              AppColors.electricGreen,
              AppColors.electricYellow,
              AppColors.neonOrange,
              AppColors.neonPink,
            ],
            numberOfParticles: 35,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Header
                  Center(
                    child: Column(
                      children: [
                        NeonText(
                          text: isMeWinner ? 'VICTORY!' : 'RACE FINISHED',
                          glowColor: isMeWinner ? AppColors.electricGreen : AppColors.electricCyan,
                          blurRadius: 20,
                          style: AppTypography.gameTitle.copyWith(
                            fontSize: 32,
                            color: isMeWinner ? AppColors.electricGreen : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isMeWinner
                              ? '🏆 YOU TOOK 1ST PLACE ON THE PODIUM!'
                              : 'GREAT EFFORT! CHECK THE FINAL RANKINGS BELOW',
                          style: AppTypography.hudLabel.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),
                  // Winner Hero Showcase
                  if (winner != null)
                    _buildWinnerPodiumCard(winner, isMeWinner).animate().scale(
                          begin: const Offset(0.9, 0.9),
                          duration: 400.ms,
                        ),
                  const SizedBox(height: 16),
                  // Full Leaderboard Table Header
                  Text('FINAL LEADERBOARD & STATS', style: AppTypography.hudLabel),
                  const SizedBox(height: 8),
                  // Leaderboard List
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: leaderboard.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final player = leaderboard[index];
                        final rank = index + 1;
                        final isMe = player.id == myId;
                        return _buildLeaderboardRow(player, rank, isMe);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons
                  if (isHost) ...[
                    ArcadeButton(
                      text: 'RACE AGAIN (REMATCH)',
                      icon: Icons.replay_rounded,
                      primaryColor: AppColors.electricGreen,
                      onPressed: _handleRematch,
                    ),
                    const SizedBox(height: 10),
                  ],
                  ArcadeButton(
                    text: 'RETURN TO GARAGE',
                    icon: Icons.home_rounded,
                    isSecondary: true,
                    height: 48,
                    onPressed: _returnHome,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerPodiumCard(PlayerModel winner, bool isMe) {
    final car = CarModel.getById(winner.carId);

    return ArcadeCard(
      borderColor: AppColors.electricYellow,
      hasGlow: true,
      backgroundColor: const Color(0xFF161F33),
      child: Row(
        children: [
          GlowingAvatar(
            avatarIndex: winner.avatarIndex,
            size: 56,
            glowColor: AppColors.electricYellow,
            isReady: true,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🥇 ', style: TextStyle(fontSize: 18)),
                    Flexible(
                      child: Text(
                        winner.nickname + (isMe ? ' (YOU)' : ''),
                        style: AppTypography.headingMedium.copyWith(
                          fontSize: 18,
                          color: AppColors.electricYellow,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${winner.wpm.toInt()} WPM  •  ${winner.accuracy.toInt()}% ACCURACY',
                  style: AppTypography.hudLabel.copyWith(
                    color: AppColors.electricCyan,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 75,
            height: 40,
            child: CustomPaint(
              painter: CustomCarPainter(
                carColor: winner.carColor,
                bodyType: car.bodyType,
                nitroActive: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(PlayerModel player, int rank, bool isMe) {
    final car = CarModel.getById(player.carId);
    Color rankColor = AppColors.textPrimary;
    if (rank == 1) rankColor = const Color(0xFFFFD700);
    if (rank == 2) rankColor = const Color(0xFFE2E8F0);
    if (rank == 3) rankColor = const Color(0xFFCD7F32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? AppColors.electricCyan : AppColors.surfaceBorder,
          width: isMe ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rankColor.withValues(alpha: 0.15),
              border: Border.all(color: rankColor),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: AppTypography.hudValue.copyWith(fontSize: 13, color: rankColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Player & Car Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.nickname + (isMe ? ' (YOU)' : ''),
                  style: AppTypography.headingMedium.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  car.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: player.carColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Metrics
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player.wpm.toInt()} WPM',
                style: AppTypography.hudValue.copyWith(
                  fontSize: 15,
                  color: AppColors.electricCyan,
                ),
              ),
              Text(
                '${player.accuracy.toInt()}% ACC',
                style: AppTypography.hudLabel.copyWith(
                  fontSize: 10,
                  color: player.accuracy > 90 ? AppColors.electricGreen : AppColors.electricYellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
