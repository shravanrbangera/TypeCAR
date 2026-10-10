import 'package:flutter_test/flutter_test.dart';
import 'package:typeracer/core/constants/app_constants.dart';
import 'package:typeracer/models/player_model.dart';
import 'package:typeracer/models/race_model.dart';
import 'package:typeracer/models/room_model.dart';

void main() {
  group('RoomModel & Leaderboard Tests', () {
    test('allPlayersReady and canStartRace logic', () {
      final host = const PlayerModel(id: 'p1', nickname: 'Host', isHost: true, isReady: true);
      final guest1 = const PlayerModel(id: 'p2', nickname: 'Guest1', isReady: false);

      final roomNotReady = RoomModel(
        roomCode: 'ABCD12',
        hostId: 'p1',
        createdAt: 1000,
        race: const RaceModel(targetText: 'Test text'),
        players: {'p1': host, 'p2': guest1},
      );

      expect(roomNotReady.allPlayersReady, false);
      expect(roomNotReady.canStartRace, false);

      final guest1Ready = guest1.copyWith(isReady: true);
      final roomReady = roomNotReady.copyWith(
        players: {'p1': host, 'p2': guest1Ready},
      );

      expect(roomReady.allPlayersReady, true);
      expect(roomReady.canStartRace, true);
    });

    test('Leaderboard sorts finished players by finish time and others by progress', () {
      final p1 = const PlayerModel(
        id: 'p1',
        nickname: 'FastFinisher',
        progress: 1.0,
        wpm: 80.0,
        finished: true,
        finishAt: 12000,
      );

      final p2 = const PlayerModel(
        id: 'p2',
        nickname: 'SuperFastFinisher',
        progress: 1.0,
        wpm: 95.0,
        finished: true,
        finishAt: 10000, // finished earlier!
      );

      final p3 = const PlayerModel(
        id: 'p3',
        nickname: 'Halfway',
        progress: 0.6,
        wpm: 60.0,
        finished: false,
      );

      final p4 = const PlayerModel(
        id: 'p4',
        nickname: 'Starting',
        progress: 0.2,
        wpm: 40.0,
        finished: false,
      );

      final room = RoomModel(
        roomCode: 'RACER1',
        hostId: 'p1',
        createdAt: 1000,
        race: const RaceModel(targetText: 'Test'),
        players: {'p1': p1, 'p2': p2, 'p3': p3, 'p4': p4},
      );

      final leaderboard = room.leaderboard;
      expect(leaderboard.length, 4);
      expect(leaderboard[0].id, 'p2'); // 1st: SuperFastFinisher
      expect(leaderboard[1].id, 'p1'); // 2nd: FastFinisher
      expect(leaderboard[2].id, 'p3'); // 3rd: Halfway (0.6 progress)
      expect(leaderboard[3].id, 'p4'); // 4th: Starting (0.2 progress)
    });

    test('Serialization roundtrip toMap and fromMap', () {
      final original = RoomModel(
        roomCode: 'TEST99',
        hostId: 'host_123',
        status: RoomStatus.racing,
        createdAt: 1700000000000,
        maxPlayers: 6,
        race: const RaceModel(
          targetText: 'A race test',
          category: TextCategory.techCoding,
          difficulty: TextDifficulty.hard,
        ),
        players: {
          'host_123': const PlayerModel(
            id: 'host_123',
            nickname: 'Coder',
            carId: 'cyber_racer',
            progress: 0.75,
            wpm: 88.0,
          ),
        },
      );

      final map = original.toMap();
      final reconstructed = RoomModel.fromMap('TEST99', map);

      expect(reconstructed.roomCode, 'TEST99');
      expect(reconstructed.hostId, 'host_123');
      expect(reconstructed.status, RoomStatus.racing);
      expect(reconstructed.maxPlayers, 6);
      expect(reconstructed.race.category, TextCategory.techCoding);
      expect(reconstructed.race.difficulty, TextDifficulty.hard);
      expect(reconstructed.players.length, 1);
      expect(reconstructed.players['host_123']?.wpm, 88.0);
    });
  });
}
