class AppConstants {
  static const String appName = 'TypeRacer';
  static const String appTagline = 'Multiplayer Turbo Typing Racing';
  static const String appVersion = '1.0.0';

  // Room Defaults
  static const int minPlayers = 2;
  static const int maxPlayers = 8;
  static const int defaultMaxPlayers = 4;
  static const int roomCodeLength = 6;

  // Race Constants
  static const int countdownSeconds = 3;
  static const int nitroStreakThreshold = 20; // 20 correct chars triggers nitro
  static const double nitroBoostMultiplier = 1.25;
  static const int progressUpdateDebounceMs = 250; // Throttle Firebase sync

  // Storage Keys
  static const String keyPlayerNickname = 'player_nickname';
  static const String keyPlayerCarId = 'player_car_id';
  static const String keyPlayerCarColor = 'player_car_color_value';
  static const String keyPlayerAvatarIndex = 'player_avatar_index';
  static const String keyRacesPlayed = 'stats_races_played';
  static const String keyRacesWon = 'stats_races_won';
  static const String keyBestWpm = 'stats_best_wpm';
  static const String keyTotalWords = 'stats_total_words';
  static const String keyAvgAccuracy = 'stats_avg_accuracy';
  static const String keySoundEnabled = 'settings_sound_enabled';
  static const String keyHapticsEnabled = 'settings_haptics_enabled';
}

enum TextDifficulty {
  easy('Easy', 'Short, simple words (40-60 chars)'),
  medium('Medium', 'Standard paragraphs with punctuation (100-150 chars)'),
  hard('Hard', 'Complex vocabulary, quotes, symbols (180+ chars)');

  final String label;
  final String description;
  const TextDifficulty(this.label, this.description);
}

enum TextCategory {
  funFacts('Fun Facts', '🧠 Amazing tidbits and trivia'),
  techCoding('Tech & Code', '💻 Programming, AI, and cyberspace'),
  moviesPop('Movies & Pop', '🎬 Iconic cinema quotes and pop culture'),
  speedQuotes('Speed Quotes', '⚡ Adrenaline-fueled racing wisdom'),
  scienceNature('Science & Nature', '🌌 Cosmos, biology, and the wild world'),
  generalKnowledge('General Knowledge', '🌍 History, geography, and world events');

  final String label;
  final String description;
  const TextCategory(this.label, this.description);
}

enum RoomStatus {
  waiting,
  starting,
  racing,
  finished,
  closed,
}
