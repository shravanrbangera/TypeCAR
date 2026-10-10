import '../core/constants/app_constants.dart';

class RaceModel {
  final String targetText;
  final TextCategory category;
  final TextDifficulty difficulty;
  final int? startAt; // Epoch timestamp in ms for synchronized countdown
  final int? endAt;
  final String? winnerId;
  final String? winnerNickname;
  final bool isStarted;

  const RaceModel({
    required this.targetText,
    this.category = TextCategory.funFacts,
    this.difficulty = TextDifficulty.medium,
    this.startAt,
    this.endAt,
    this.winnerId,
    this.winnerNickname,
    this.isStarted = false,
  });

  RaceModel copyWith({
    String? targetText,
    TextCategory? category,
    TextDifficulty? difficulty,
    int? startAt,
    int? endAt,
    String? winnerId,
    String? winnerNickname,
    bool? isStarted,
  }) {
    return RaceModel(
      targetText: targetText ?? this.targetText,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      winnerId: winnerId ?? this.winnerId,
      winnerNickname: winnerNickname ?? this.winnerNickname,
      isStarted: isStarted ?? this.isStarted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetText': targetText,
      'category': category.name,
      'difficulty': difficulty.name,
      'startAt': startAt,
      'endAt': endAt,
      'winnerId': winnerId,
      'winnerNickname': winnerNickname,
      'isStarted': isStarted,
    };
  }

  factory RaceModel.fromMap(Map<dynamic, dynamic> map) {
    TextCategory cat = TextCategory.funFacts;
    try {
      cat = TextCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => TextCategory.funFacts,
      );
    } catch (_) {}

    TextDifficulty diff = TextDifficulty.medium;
    try {
      diff = TextDifficulty.values.firstWhere(
        (d) => d.name == map['difficulty'],
        orElse: () => TextDifficulty.medium,
      );
    } catch (_) {}

    return RaceModel(
      targetText: map['targetText']?.toString() ?? '',
      category: cat,
      difficulty: diff,
      startAt: (map['startAt'] as num?)?.toInt(),
      endAt: (map['endAt'] as num?)?.toInt(),
      winnerId: map['winnerId']?.toString(),
      winnerNickname: map['winnerNickname']?.toString(),
      isStarted: map['isStarted'] == true,
    );
  }
}
