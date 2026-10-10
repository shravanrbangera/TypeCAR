class UserStatsModel {
  final int racesPlayed;
  final int racesWon;
  final double bestWpm;
  final int totalWordsTyped;
  final double averageAccuracy;

  const UserStatsModel({
    this.racesPlayed = 0,
    this.racesWon = 0,
    this.bestWpm = 0.0,
    this.totalWordsTyped = 0,
    this.averageAccuracy = 100.0,
  });

  double get winRate {
    if (racesPlayed == 0) return 0.0;
    return (racesWon / racesPlayed) * 100.0;
  }

  UserStatsModel recordRaceResult({
    required bool won,
    required double raceWpm,
    required double raceAccuracy,
    required int wordsCount,
  }) {
    final int newPlayed = racesPlayed + 1;
    final int newWon = won ? (racesWon + 1) : racesWon;
    final double newBest = raceWpm > bestWpm ? raceWpm : bestWpm;
    final int newWords = totalWordsTyped + wordsCount;
    // Cumulative average accuracy
    final double newAvgAcc = racesPlayed == 0
        ? raceAccuracy
        : ((averageAccuracy * racesPlayed) + raceAccuracy) / newPlayed;

    return UserStatsModel(
      racesPlayed: newPlayed,
      racesWon: newWon,
      bestWpm: newBest,
      totalWordsTyped: newWords,
      averageAccuracy: newAvgAcc.clamp(0.0, 100.0),
    );
  }
}
