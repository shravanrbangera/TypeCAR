import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/sample_texts.dart';
import '../core/utils/room_code_generator.dart';
import '../models/player_model.dart';
import '../models/race_model.dart';
import '../models/room_model.dart';
import 'room_service_interface.dart';

class RoomService implements IRoomService {
  final FirebaseDatabase _database;

  RoomService([FirebaseDatabase? database])
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _roomsRef => _database.ref().child('rooms');

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
    // Generate code with collision check
    String roomCode = '';
    bool isUnique = false;
    int attempts = 0;

    while (!isUnique && attempts < 10) {
      attempts++;
      final candidate = RoomCodeGenerator.generate();
      final snapshot = await _roomsRef.child(candidate).get();
      if (!snapshot.exists) {
        roomCode = candidate;
        isUnique = true;
      }
    }

    if (roomCode.isEmpty) {
      throw Exception('Could not allocate a unique room code. Please try again.');
    }

    final initialTextItem = SampleTexts.getRandomText(
      category: category,
      difficulty: difficulty,
    );

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

    final initialRace = RaceModel(
      targetText: initialTextItem.text,
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
      players: {hostId: hostPlayer},
    );

    await _roomsRef.child(roomCode).set(room.toMap());

    // Register onDisconnect cleanup for host
    try {
      final hostPlayerRef = _roomsRef.child('$roomCode/players/$hostId');
      await hostPlayerRef.onDisconnect().update({
        'connected': false,
        'lastActive': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint("Warning registering onDisconnect: $e");
    }

    return roomCode;
  }

  @override
  Future<RoomModel?> getRoom(String roomCode) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final snapshot = await _roomsRef.child(normalized).get();
    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }
    final data = snapshot.value;
    if (data is Map) {
      return RoomModel.fromMap(normalized, data);
    }
    return null;
  }

  @override
  Future<void> joinRoom(String roomCode, PlayerModel player) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final roomRef = _roomsRef.child(normalized);

    final snapshot = await roomRef.get();
    if (!snapshot.exists || snapshot.value == null) {
      throw Exception('Room $normalized does not exist.');
    }

    final roomData = snapshot.value as Map;
    final currentStatus = roomData['status']?.toString();
    if (currentStatus != RoomStatus.waiting.name && currentStatus != RoomStatus.finished.name) {
      throw Exception('Race is already in progress or room is closed.');
    }

    final maxP = (roomData['maxPlayers'] as num?)?.toInt() ?? AppConstants.defaultMaxPlayers;
    final playersMap = (roomData['players'] as Map?) ?? {};

    if (!playersMap.containsKey(player.id) && playersMap.length >= maxP) {
      throw Exception('Room is full (Maximum $maxP racers).');
    }

    // Join room
    await roomRef.child('players/${player.id}').set(player.toMap());

    // Set onDisconnect
    try {
      await roomRef.child('players/${player.id}').onDisconnect().update({
        'connected': false,
        'lastActive': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint("Warning onDisconnect: $e");
    }
  }

  @override
  Future<void> toggleReady(String roomCode, String playerId, bool isReady) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    await _roomsRef.child('$normalized/players/$playerId/isReady').set(isReady);
  }

  @override
  Future<void> startRace(String roomCode, {String? targetText}) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final room = await getRoom(normalized);
    if (room == null) throw Exception('Room not found');

    final text = targetText ?? room.race.targetText;
    final startTimestamp = DateTime.now().millisecondsSinceEpoch + (AppConstants.countdownSeconds * 1000);

    // Reset player race stats for the new run
    final updates = <String, dynamic>{
      'status': RoomStatus.starting.name,
      'race/startAt': startTimestamp,
      'race/endAt': null,
      'race/winnerId': null,
      'race/winnerNickname': null,
      'race/isStarted': true,
      'race/targetText': text,
    };

    for (final p in room.players.keys) {
      updates['players/$p/progress'] = 0.0;
      updates['players/$p/wpm'] = 0.0;
      updates['players/$p/accuracy'] = 100.0;
      updates['players/$p/finished'] = false;
      updates['players/$p/finishAt'] = null;
      updates['players/$p/rank'] = null;
      updates['players/$p/nitroActive'] = false;
    }

    await _roomsRef.child(normalized).update(updates);
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
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final updates = <String, dynamic>{
      'players/$playerId/progress': progress.clamp(0.0, 1.0),
      'players/$playerId/wpm': wpm,
      'players/$playerId/accuracy': accuracy,
      'players/$playerId/finished': finished,
      'players/$playerId/nitroActive': nitroActive,
      'players/$playerId/lastActive': nowMs,
    };

    if (finished) {
      updates['players/$playerId/finishAt'] = nowMs;
    }

    await _roomsRef.child(normalized).update(updates);

    if (finished) {
      // Check if winner should be recorded
      final room = await getRoom(normalized);
      if (room != null && room.race.winnerId == null) {
        final winnerPlayer = room.players[playerId];
        await _roomsRef.child(normalized).update({
          'race/winnerId': playerId,
          'race/winnerNickname': winnerPlayer?.nickname ?? 'Racer',
          'race/endAt': nowMs,
          'status': RoomStatus.finished.name,
        });
      }
    }
  }

  @override
  Future<void> requestRematch(String roomCode, TextCategory category, TextDifficulty difficulty) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final nextText = SampleTexts.getRandomText(category: category, difficulty: difficulty);

    final room = await getRoom(normalized);
    if (room == null) return;

    final updates = <String, dynamic>{
      'status': RoomStatus.waiting.name,
      'race/targetText': nextText.text,
      'race/category': category.name,
      'race/difficulty': difficulty.name,
      'race/startAt': null,
      'race/endAt': null,
      'race/winnerId': null,
      'race/winnerNickname': null,
      'race/isStarted': false,
    };

    for (final p in room.players.keys) {
      final isHost = room.players[p]?.isHost == true;
      updates['players/$p/isReady'] = isHost; // Host starts ready
      updates['players/$p/progress'] = 0.0;
      updates['players/$p/wpm'] = 0.0;
      updates['players/$p/accuracy'] = 100.0;
      updates['players/$p/finished'] = false;
      updates['players/$p/finishAt'] = null;
      updates['players/$p/rank'] = null;
      updates['players/$p/nitroActive'] = false;
    }

    await _roomsRef.child(normalized).update(updates);
  }

  @override
  Future<void> kickPlayer(String roomCode, String playerId) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    await _roomsRef.child('$normalized/players/$playerId').remove();
  }

  @override
  Future<void> leaveRoom(String roomCode, String playerId) async {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    final room = await getRoom(normalized);
    if (room == null) return;

    final isHost = room.hostId == playerId;
    if (isHost) {
      // Find another connected player to migrate host, otherwise close room
      final remainingPlayers = room.players.values.where((p) => p.id != playerId && p.connected).toList();
      if (remainingPlayers.isNotEmpty) {
        final newHost = remainingPlayers.first;
        await _roomsRef.child(normalized).update({
          'hostId': newHost.id,
          'players/${newHost.id}/isHost': true,
          'players/${newHost.id}/isReady': true,
        });
        await _roomsRef.child('$normalized/players/$playerId').remove();
      } else {
        await _roomsRef.child(normalized).update({
          'status': RoomStatus.closed.name,
        });
        await _roomsRef.child('$normalized/players/$playerId').remove();
      }
    } else {
      await _roomsRef.child('$normalized/players/$playerId').remove();
    }
  }

  @override
  Stream<RoomModel?> roomStream(String roomCode) {
    final normalized = RoomCodeGenerator.normalize(roomCode);
    return _roomsRef.child(normalized).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return null;
      }
      final val = event.snapshot.value;
      if (val is Map) {
        return RoomModel.fromMap(normalized, val);
      }
      return null;
    });
  }

  @override
  void dispose() {}
}
