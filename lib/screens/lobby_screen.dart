import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'race_screen.dart';

class LobbyScreen extends StatefulWidget {
  final String roomCode;
  final bool isHost;
  final bool isMockMode;

  const LobbyScreen({
    super.key,
    required this.roomCode,
    required this.isHost,
    this.isMockMode = false,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  StreamSubscription<RoomModel?>? _roomSubscription;
  RoomModel? _room;
  bool _isNavigatingToRace = false;

  @override
  void initState() {
    super.initState();
    _subscribeToRoom();
  }

  void _subscribeToRoom() {
    final IRoomService roomService = widget.isMockMode
        ? Provider.of<MockRoomService>(context, listen: false)
        : Provider.of<RoomService>(context, listen: false);

    _roomSubscription = roomService.roomStream(widget.roomCode).listen((room) {
      if (!mounted) return;

      if (room == null || room.status == RoomStatus.closed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room was closed by the host.'),
            backgroundColor: AppColors.neonPink,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }

      setState(() {
        _room = room;
      });

      // If race is starting/racing, launch race screen
      if ((room.status == RoomStatus.starting || room.status == RoomStatus.racing) && !_isNavigatingToRace) {
        _isNavigatingToRace = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RaceScreen(
              roomCode: widget.roomCode,
              isMockMode: widget.isMockMode,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: widget.roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room code ${widget.roomCode} copied to clipboard!'),
        backgroundColor: AppColors.electricCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleReady() async {
    if (_room == null) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    final myPlayer = _room!.players[authService.currentUserId];
    if (myPlayer == null) return;

    final IRoomService roomService = widget.isMockMode
        ? Provider.of<MockRoomService>(context, listen: false)
        : Provider.of<RoomService>(context, listen: false);

    await roomService.toggleReady(widget.roomCode, myPlayer.id, !myPlayer.isReady);
  }

  Future<void> _startRace() async {
    if (_room == null) return;
    final IRoomService roomService = widget.isMockMode
        ? Provider.of<MockRoomService>(context, listen: false)
        : Provider.of<RoomService>(context, listen: false);

    try {
      await roomService.startRace(widget.roomCode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting race: $e'), backgroundColor: AppColors.neonPink),
        );
      }
    }
  }

  Future<void> _leaveRoom() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final IRoomService roomService = widget.isMockMode
        ? Provider.of<MockRoomService>(context, listen: false)
        : Provider.of<RoomService>(context, listen: false);

    await roomService.leaveRoom(widget.roomCode, authService.currentUserId);
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final myId = authService.currentUserId;
    final isCurrentHost = _room?.hostId == myId;
    final myPlayer = _room?.players[myId];
    final isReady = myPlayer?.isReady ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.neonPink),
          onPressed: _leaveRoom,
        ),
        title: Text('RACE LOBBY', style: AppTypography.headingMedium),
        centerTitle: true,
      ),
      body: _room == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.electricCyan),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Room Code Hero Card with Copy Button
                    ArcadeCard(
                      borderColor: AppColors.electricCyan,
                      hasGlow: true,
                      child: Column(
                        children: [
                          Text('ROOM CODE — SHARE WITH FRIENDS', style: AppTypography.hudLabel),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NeonText(
                                text: widget.roomCode,
                                glowColor: AppColors.electricCyan,
                                blurRadius: 16,
                                style: AppTypography.gameTitle.copyWith(
                                  fontSize: 32,
                                  letterSpacing: 6.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 14),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, color: AppColors.electricCyan),
                                onPressed: _copyRoomCode,
                                tooltip: 'Copy Code',
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_room!.race.category.label} • ${_room!.race.difficulty.label} Difficulty',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.electricGreen,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Live Players Counter & Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CONNECTED DRIVERS (${_room!.playerCount}/${_room!.maxPlayers})',
                          style: AppTypography.hudLabel,
                        ),
                        if (_room!.playerCount < 2)
                          Text(
                            'WAITING FOR AT LEAST 2 PLAYERS...',
                            style: AppTypography.hudLabel.copyWith(color: AppColors.neonOrange, fontSize: 10),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Players Grid / List
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _room!.playerList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final player = _room!.playerList[index];
                          final isMe = player.id == myId;
                          final car = CarModel.getById(player.carId);

                          return _buildPlayerCard(player, car, isMe, isCurrentHost);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action Buttons: Start Race (Host) or Ready Up (Guest)
                    if (isCurrentHost) ...[
                      ArcadeButton(
                        text: _room!.canStartRace
                            ? 'START THE RACE!'
                            : (_room!.playerCount < 2
                                ? 'NEED AT LEAST 2 RACERS'
                                : 'WAITING FOR ALL TO READY UP'),
                        icon: Icons.flag_rounded,
                        primaryColor: _room!.canStartRace ? AppColors.electricGreen : Colors.grey.shade700,
                        textColor: _room!.canStartRace ? Colors.black : Colors.white70,
                        onPressed: _room!.canStartRace ? _startRace : null,
                      ),
                    ] else ...[
                      ArcadeButton(
                        text: isReady ? 'READY! (TAP TO UNREADY)' : 'READY UP!',
                        icon: isReady ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                        primaryColor: isReady ? AppColors.electricGreen : AppColors.electricCyan,
                        onPressed: _toggleReady,
                      ),
                    ],
                    const SizedBox(height: 12),
                    ArcadeButton(
                      text: 'LEAVE LOBBY',
                      isSecondary: true,
                      height: 46,
                      onPressed: _leaveRoom,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlayerCard(PlayerModel player, CarModel car, bool isMe, bool isHostView) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? AppColors.electricCyan : AppColors.surfaceBorder,
          width: isMe ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          GlowingAvatar(
            avatarIndex: player.avatarIndex,
            size: 44,
            glowColor: player.carColor,
            isReady: player.isReady || player.isHost,
            showBadge: true,
          ),
          const SizedBox(width: 12),
          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.nickname + (isMe ? ' (YOU)' : ''),
                        style: AppTypography.headingMedium.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (player.isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.electricYellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.electricYellow),
                        ),
                        child: Text(
                          'HOST',
                          style: AppTypography.buttonText.copyWith(
                            fontSize: 9,
                            color: AppColors.electricYellow,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  car.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: player.carColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Mini Car Canvas
          SizedBox(
            width: 50,
            height: 28,
            child: CustomPaint(
              painter: CustomCarPainter(
                carColor: player.carColor,
                bodyType: car.bodyType,
                nitroActive: player.isReady,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Ready Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (player.isReady || player.isHost)
                  ? AppColors.electricGreen.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (player.isReady || player.isHost) ? AppColors.electricGreen : Colors.orange,
              ),
            ),
            child: Text(
              (player.isReady || player.isHost) ? 'READY' : 'WAITING',
              style: AppTypography.buttonText.copyWith(
                fontSize: 10,
                color: (player.isReady || player.isHost) ? AppColors.electricGreen : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
