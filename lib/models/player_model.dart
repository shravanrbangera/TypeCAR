import 'package:flutter/material.dart';

class PlayerModel {
  final String id;
  final String nickname;
  final String carId;
  final int carColorValue;
  final int avatarIndex;
  final bool isHost;
  final bool isReady;
  final bool connected;
  final double progress; // 0.0 to 1.0
  final double wpm;
  final double accuracy;
  final bool finished;
  final int? finishAt; // Timestamp in milliseconds
  final int? rank;
  final int lastActive;
  final bool isBot;
  final bool nitroActive;

  const PlayerModel({
    required this.id,
    required this.nickname,
    this.carId = 'sun_dazer',
    this.carColorValue = 0xFF00E5FF,
    this.avatarIndex = 0,
    this.isHost = false,
    this.isReady = false,
    this.connected = true,
    this.progress = 0.0,
    this.wpm = 0.0,
    this.accuracy = 100.0,
    this.finished = false,
    this.finishAt,
    this.rank,
    this.lastActive = 0,
    this.isBot = false,
    this.nitroActive = false,
  });

  Color get carColor => Color(carColorValue);

  PlayerModel copyWith({
    String? id,
    String? nickname,
    String? carId,
    int? carColorValue,
    int? avatarIndex,
    bool? isHost,
    bool? isReady,
    bool? connected,
    double? progress,
    double? wpm,
    double? accuracy,
    bool? finished,
    int? finishAt,
    int? rank,
    int? lastActive,
    bool? isBot,
    bool? nitroActive,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      carId: carId ?? this.carId,
      carColorValue: carColorValue ?? this.carColorValue,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      connected: connected ?? this.connected,
      progress: progress ?? this.progress,
      wpm: wpm ?? this.wpm,
      accuracy: accuracy ?? this.accuracy,
      finished: finished ?? this.finished,
      finishAt: finishAt ?? this.finishAt,
      rank: rank ?? this.rank,
      lastActive: lastActive ?? this.lastActive,
      isBot: isBot ?? this.isBot,
      nitroActive: nitroActive ?? this.nitroActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'carId': carId,
      'carColorValue': carColorValue,
      'avatarIndex': avatarIndex,
      'isHost': isHost,
      'isReady': isReady,
      'connected': connected,
      'progress': progress,
      'wpm': wpm,
      'accuracy': accuracy,
      'finished': finished,
      'finishAt': finishAt,
      'rank': rank,
      'lastActive': lastActive,
      'isBot': isBot,
      'nitroActive': nitroActive,
    };
  }

  factory PlayerModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return PlayerModel(
      id: id,
      nickname: map['nickname']?.toString() ?? 'Racer',
      carId: map['carId']?.toString() ?? 'sun_dazer',
      carColorValue: (map['carColorValue'] as num?)?.toInt() ?? 0xFF00E5FF,
      avatarIndex: (map['avatarIndex'] as num?)?.toInt() ?? 0,
      isHost: map['isHost'] == true,
      isReady: map['isReady'] == true,
      connected: map['connected'] != false,
      progress: ((map['progress'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0),
      wpm: ((map['wpm'] as num?)?.toDouble() ?? 0.0),
      accuracy: ((map['accuracy'] as num?)?.toDouble() ?? 100.0).clamp(0.0, 100.0),
      finished: map['finished'] == true,
      finishAt: (map['finishAt'] as num?)?.toInt(),
      rank: (map['rank'] as num?)?.toInt(),
      lastActive: (map['lastActive'] as num?)?.toInt() ?? 0,
      isBot: map['isBot'] == true,
      nitroActive: map['nitroActive'] == true,
    );
  }
}
