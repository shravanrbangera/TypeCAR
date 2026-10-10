import '../core/constants/app_constants.dart';
import 'player_model.dart';
import 'race_model.dart';

class RoomModel {
  final String roomCode;
  final String hostId;
  final RoomStatus status;
  final int createdAt;
  final int maxPlayers;
  final RaceModel race;
  final Map<String, PlayerModel> players;

  const RoomModel({
    required this.roomCode,
    required this.hostId,
    this.status = RoomStatus.waiting,
    required this.createdAt,
    this.maxPlayers = AppConstants.defaultMaxPlayers,
    required this.race,
    this.players = const {},
  });

  List<PlayerModel> get playerList => players.values.toList();
  int get playerCount => players.length;
  bool get isFull => playerCount >= maxPlayers;

  bool get allPlayersReady {
    if (players.length < 2) return false;
    for (final player in players.values) {
      if (!player.isHost && !player.isReady) {
        return false;
      }
    }
    return true;
  }

  bool get canStartRace {
    return (status == RoomStatus.waiting || status == RoomStatus.finished) &&
        playerCount >= AppConstants.minPlayers &&
        allPlayersReady;
  }

  List<PlayerModel> get leaderboard {
    final list = playerList;
    list.sort((a, b) {
      // 1. Finished players first, sorted by finishAt ascending
      if (a.finished && b.finished) {
        final aTime = a.finishAt ?? 9999999999999;
        final bTime = b.finishAt ?? 9999999999999;
        return aTime.compareTo(bTime);
      }
      if (a.finished && !b.finished) return -1;
      if (!a.finished && b.finished) return 1;

      // 2. Unfinished players sorted by progress descending
      final progressCmp = b.progress.compareTo(a.progress);
      if (progressCmp != 0) return progressCmp;

      // 3. Fallback to WPM descending
      return b.wpm.compareTo(a.wpm);
    });
    return list;
  }

  RoomModel copyWith({
    String? roomCode,
    String? hostId,
    RoomStatus? status,
    int? createdAt,
    int? maxPlayers,
    RaceModel? race,
    Map<String, PlayerModel>? players,
  }) {
    return RoomModel(
      roomCode: roomCode ?? this.roomCode,
      hostId: hostId ?? this.hostId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      race: race ?? this.race,
      players: players ?? this.players,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomCode': roomCode,
      'hostId': hostId,
      'status': status.name,
      'createdAt': createdAt,
      'maxPlayers': maxPlayers,
      'race': race.toMap(),
      'players': players.map((k, v) => MapEntry(k, v.toMap())),
    };
  }

  factory RoomModel.fromMap(String roomCode, Map<dynamic, dynamic> map) {
    RoomStatus roomStatus = RoomStatus.waiting;
    try {
      roomStatus = RoomStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RoomStatus.waiting,
      );
    } catch (_) {}

    RaceModel raceModel = const RaceModel(targetText: '');
    if (map['race'] != null && map['race'] is Map) {
      raceModel = RaceModel.fromMap(map['race'] as Map);
    }

    final Map<String, PlayerModel> playerMap = {};
    if (map['players'] != null && map['players'] is Map) {
      final pData = map['players'] as Map;
      pData.forEach((key, val) {
        if (val is Map) {
          playerMap[key.toString()] = PlayerModel.fromMap(key.toString(), val);
        }
      });
    }

    return RoomModel(
      roomCode: roomCode,
      hostId: map['hostId']?.toString() ?? '',
      status: roomStatus,
      createdAt: (map['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      maxPlayers: (map['maxPlayers'] as num?)?.toInt() ?? AppConstants.defaultMaxPlayers,
      race: raceModel,
      players: playerMap,
    );
  }
}
