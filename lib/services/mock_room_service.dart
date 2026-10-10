import 'dart:async';
import 'dart:math';
import '../core/constants/app_constants.dart';
import '../core/constants/sample_texts.dart';
import '../core/utils/room_code_generator.dart';
import '../models/player_model.dart';
import '../models/race_model.dart';
import '../models/room_model.dart';
import 'room_service_interface.dart';

class MockRoomService implements IRoomService {
  final Map<String, RoomModel> _mockRooms = {};
  final Map<String, StreamController<RoomModel?>> _controllers = {};
  final Map<String, Timer> _botSimulationTimers = {};

  StreamController<RoomModel?> _getController(String roomCode) {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    return _controllers.putIfAbsent(
      normalized,
      () => StreamController<RoomModel?>.broadcast(),
    );
  }

  void _notify(String roomCode) {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final room = _mockRooms[normalized];
    if (_controllers.containsKey(normalized)) {
      _controllers[normalized]!.add(room);
    }
  }

  @override
  Future<String> createRoom({
    required String hostId,
    required String hostNickname,
    required String carId,
    required int carColorValue,
    required int avatarIndex,
    required int maxPlayers,
    required TextDifficulty difficulty,
    required TextCategory category,
  }) async {
    final roomCode = RoomCodeGenerator.generate();
    final textItem = SampleTexts.getRandomText(category: category, difficulty: difficulty);

    final hostPlayer = PlayerModel(
      id: hostId,
      nickname: hostNickname,
      carId: carId,
      carColorValue: carColorValue,
      avatarIndex: avatarIndex,
      isHost: true,
      isReady: true,
      connected: true,
      lastActive: DateTime.now().millisecondsSinceEpoch,
    );

    // Add 1-3 AI Bot Challengers for lively local simulation
    final botCount = min(3, maxPlayers - 1);
    final botNames = ['NitroBot 🤖', 'TurboDash ⚡', 'CyberDrifter 🏎️', 'VaporRacer 🏁'];
    final botCars = ['cyber_racer', 'lightning_f1', 'retro_cruiser', 'skull_truck'];
    final botColors = [0xFFFF1744, 0xFF00E676, 0xFFFFD600, 0xFFD500F9];

    final playersMap = <String, PlayerModel>{
      hostId: hostPlayer,
    };

    for (int i = 0; i < botCount; i++) {
      final botId = 'bot_${i + 1}';
      playersMap[botId] = PlayerModel(
        id: botId,
        nickname: botNames[i % botNames.length],
        carId: botCars[i % botCars.length],
        carColorValue: botColors[i % botColors.length],
        avatarIndex: (i + 1) % 6,
        isHost: false,
        isReady: true,
        connected: true,
        isBot: true,
        lastActive: DateTime.now().millisecondsSinceEpoch,
      );
    }

    final initialRace = RaceModel(
      targetText: textItem.text,
      category: category,
      difficulty: difficulty,
      isStarted: false,
    );

    final room = RoomModel(
      roomCode: roomCode,
      hostId: hostId,
      status: RoomStatus.waiting,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      maxPlayers: maxPlayers,
      race: initialRace,
      players: playersMap,
    );

    _mockRooms[roomCode] = room;
    _notify(roomCode);
    return roomCode;
  }

  @override
  Future<RoomModel?> getRoom(String roomCode) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    return _mockRooms[normalized];
  }

  @override
  Future<void> joinRoom(String roomCode, PlayerModel player) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final room = _mockRooms[normalized];
    if (room == null) {
      throw Exception('Room $normalized does not exist.');
    }
    if (room.isFull && !room.players.containsKey(player.id)) {
      throw Exception('Room is full.');
    }
    if (room.status != RoomStatus.waiting && room.status != RoomStatus.finished) {
      throw Exception('Race has already started.');
    }

    final newPlayers = Map<String, PlayerModel>.from(room.players);
    newPlayers[player.id] = player;

    _mockRooms[normalized] = room.copyWith(players: newPlayers);
    _notify(normalized);
  }

  @override
  Future<void> toggleReady(String roomCode, String playerId, bool isReady) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final room = _mockRooms[normalized];
    if (room == null) return;

    final player = room.players[playerId];
    if (player == null) return;

    final updated = player.copyWith(isReady: isReady);
    final newPlayers = Map<String, PlayerModel>.from(room.players);
    newPlayers[playerId] = updated;

    _mockRooms[normalized] = room.copyWith(players: newPlayers);
    _notify(normalized);
  }

  @override
  Future<void> startRace(String roomCode, {String? targetText}) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final room = _mockRooms[normalized];
    if (room == null) return;

    final text = targetText ?? room.race.targetText;
    final startTimestamp = DateTime.now().millisecondsSinceEpoch + (AppConstants.countdownSeconds * 1000);

    final resetPlayers = <String, PlayerModel>{};
    for (final entry in room.players.entries) {
      resetPlayers[entry.key] = entry.value.copyWith(
        progress: 0.0,
        wpm: 0.0,
        accuracy: 100.0,
        finished: false,
        finishAt: null,
        rank: null,
        nitroActive: false,
      );
    }

    final newRace = room.race.copyWith(
      targetText: text,
      startAt: startTimestamp,
      endAt: null,
      winnerId: null,
      winnerNickname: null,
      isStarted: true,
    );

    _mockRooms[normalized] = room.copyWith(
      status: RoomStatus.starting,
      race: newRace,
      players: resetPlayers,
    );
    _notify(normalized);

    // Schedule Bot Simulation after countdown
    _startBotSimulation(normalized, startTimestamp, text.length);
  }

  void _startBotSimulation(String roomCode, int startTimestampMs, int textLength) {
    _botSimulationTimers[roomCode]?.cancel();

    final delayMs = max(0, startTimestampMs - DateTime.now().millisecondsSinceEpoch);
    Timer(Duration(milliseconds: delayMs), () {
      final currentRoom = _mockRooms[roomCode];
      if (currentRoom == null) return;

      _mockRooms[roomCode] = currentRoom.copyWith(status: RoomStatus.racing);
      _notify(roomCode);

      final random = Random();
      // Each bot gets a target speed profile (40 - 75 WPM)
      final botTargetWpms = <String, double>{};
      for (final p in currentRoom.players.values) {
        if (p.isBot) {
          botTargetWpms[p.id] = 45.0 + random.nextDouble() * 30.0;
        }
      }

      final startTime = DateTime.now();

      _botSimulationTimers[roomCode] = Timer.periodic(const Duration(milliseconds: 300), (timer) {
        final roomNow = _mockRooms[roomCode];
        if (roomNow == null || roomNow.status == RoomStatus.closed) {
          timer.cancel();
          return;
        }

        final elapsedSec = max(0.1, DateTime.now().difference(startTime).inMilliseconds / 1000.0);
        bool allFinished = true;
        final updatedPlayers = Map<String, PlayerModel>.from(roomNow.players);

        for (final entry in botTargetWpms.entries) {
          final botId = entry.key;
          final targetWpm = entry.value;
          final botPlayer = updatedPlayers[botId];
          if (botPlayer == null) continue;

          if (botPlayer.finished) continue;

          allFinished = false;
          // Calculate chars per second: (WPM * 5) / 60
          final charsPerSec = (targetWpm * 5.0) / 60.0;
          // Add slight jitter
          final jitter = (random.nextDouble() - 0.5) * 0.5;
          final currentChars = (charsPerSec + jitter) * elapsedSec;
          final progress = (currentChars / textLength).clamp(0.0, 1.0);
          final isFinished = progress >= 1.0;
          final finishAt = isFinished ? DateTime.now().millisecondsSinceEpoch : null;

          final isNitro = random.nextDouble() < 0.15; // occasional nitro flare

          updatedPlayers[botId] = botPlayer.copyWith(
            progress: progress,
            wpm: targetWpm + (random.nextDouble() * 4 - 2),
            accuracy: 94.0 + random.nextDouble() * 5.0,
            finished: isFinished,
            finishAt: finishAt,
            nitroActive: isNitro,
          );

          // Check if bot is the first winner
          if (isFinished && roomNow.race.winnerId == null) {
            _mockRooms[roomCode] = roomNow.copyWith(
              players: updatedPlayers,
              race: roomNow.race.copyWith(
                winnerId: botId,
                winnerNickname: botPlayer.nickname,
                endAt: finishAt,
              ),
            );
          }
        }

        _mockRooms[roomCode] = _mockRooms[roomCode]!.copyWith(players: updatedPlayers);
        _notify(roomCode);

        if (allFinished) {
          timer.cancel();
        }
      });
    });
  }

  @override
  Future<void> updateProgress({
    required String roomCode,
    required String playerId,
    required double progress,
    required double wpm,
    required double accuracy,
    required bool finished,
    required bool nitroActive,
  }) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final room = _mockRooms[normalized];
    if (room == null) return;

    final player = room.players[playerId];
    if (player == null) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final updatedPlayer = player.copyWith(
      progress: progress,
      wpm: wpm,
      accuracy: accuracy,
      finished: finished,
      finishAt: finished ? nowMs : player.finishAt,
      nitroActive: nitroActive,
      lastActive: nowMs,
    );

    final newPlayers = Map<String, PlayerModel>.from(room.players);
    newPlayers[playerId] = updatedPlayer;

    RaceModel race = room.race;
    RoomStatus newStatus = room.status;

    if (finished && race.winnerId == null) {
      race = race.copyWith(
        winnerId: playerId,
        winnerNickname: player.nickname,
        endAt: nowMs,
      );
      newStatus = RoomStatus.finished;
    }

    _mockRooms[normalized] = room.copyWith(
      players: newPlayers,
      race: race,
      status: newStatus,
    );
    _notify(normalized);
  }

  @override
  Future<void> requestRematch(String roomCode, TextCategory category, TextDifficulty difficulty) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final room = _mockRooms[normalized];
    if (room == null) return;

    _botSimulationTimers[normalized]?.cancel();

    final nextText = SampleTexts.getRandomText(category: category, difficulty: difficulty);
    final resetPlayers = <String, PlayerModel>{};

    for (final entry in room.players.entries) {
      resetPlayers[entry.key] = entry.value.copyWith(
        isReady: entry.value.isHost || entry.value.isBot,
        progress: 0.0,
        wpm: 0.0,
        accuracy: 100.0,
        finished: false,
        finishAt: null,
        rank: null,
        nitroActive: false,
      );
    }

    final newRace = RaceModel(
      targetText: nextText.text,
      category: category,
      difficulty: difficulty,
      isStarted: false,
    );

    _mockRooms[normalized] = room.copyWith(
      status: RoomStatus.waiting,
      race: newRace,
      players: resetPlayers,
    );
    _notify(normalized);
  }

  @override
  Future<void> kickPlayer(String roomCode, String playerId) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final room = _mockRooms[normalized];
    if (room == null) return;

    final newPlayers = Map<String, PlayerModel>.from(room.players)..remove(playerId);
    _mockRooms[normalized] = room.copyWith(players: newPlayers);
    _notify(normalized);
  }

  @override
  Future<void> leaveRoom(String roomCode, String playerId) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final room = _mockRooms[normalized];
    if (room == null) return;

    _botSimulationTimers[normalized]?.cancel();

    final newPlayers = Map<String, PlayerModel>.from(room.players)..remove(playerId);
    if (room.hostId == playerId) {
      final remaining = newPlayers.values.where((p) => !p.isBot).toList();
      if (remaining.isNotEmpty) {
        final nextHost = remaining.first;
        newPlayers[nextHost.id] = nextHost.copyWith(isHost: true, isReady: true);
        _mockRooms[normalized] = room.copyWith(
          hostId: nextHost.id,
          players: newPlayers,
        );
      } else {
        _mockRooms[normalized] = room.copyWith(
          status: RoomStatus.closed,
          players: newPlayers,
        );
      }
    } else {
      _mockRooms[normalized] = room.copyWith(players: newPlayers);
    }
    _notify(normalized);
  }

  @override
  Stream<RoomModel?> roomStream(String roomCode) {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final controller = _getController(normalized);
    Future.microtask(() {
      if (_mockRooms.containsKey(normalized)) {
        controller.add(_mockRooms[normalized]);
      }
    });
    return controller.stream;
  }

  @override
  void dispose() {
    for (final t in _botSimulationTimers.values) {
      t.cancel();
    }
    for (final c in _controllers.values) {
      c.close();
    }
  }
}
