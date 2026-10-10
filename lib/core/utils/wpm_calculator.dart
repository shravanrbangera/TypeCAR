class WpmCalculator {
  /// Calculates Words Per Minute (WPM) using standard 5 characters per word.
  /// Protects against division by zero.
  static double calculateWpm({
    required int correctCharacters,
    required double elapsedSeconds,
  }) {
    if (elapsedSeconds <= 0.5 || correctCharacters <= 0) {
      return 0.0;
    }
    final double minutes = elapsedSeconds / 60.0;
    final double standardWords = correctCharacters / 5.0;
    final double wpm = standardWords / minutes;
    return wpm.isFinite ? wpm : 0.0;
  }

  /// Calculates typing accuracy as a percentage (0.0 to 100.0).
  static double calculateAccuracy({
    required int correctCharacters,
    required int totalAttemptedCharacters,
  }) {
    if (totalAttemptedCharacters <= 0) {
      return 100.0;
    }
    final double acc = (correctCharacters / totalAttemptedCharacters) * 100.0;
    return acc.clamp(0.0, 100.0);
  }

  /// Calculates race completion progress (0.0 to 1.0).
  static double calculateProgress({
    required int correctCharacters,
    required int totalCharacters,
  }) {
    if (totalCharacters <= 0) {
      return 0.0;
    }
    final double progress = correctCharacters / totalCharacters;
    return progress.clamp(0.0, 1.0);
  }

  /// Formats elapsed seconds to MM:SS.ms string.
  static String formatDuration(double elapsedSeconds) {
    if (elapsedSeconds < 0) elapsedSeconds = 0;
    final int minutes = (elapsedSeconds ~/ 60);
    final int seconds = (elapsedSeconds % 60).toInt();
    final int millis = ((elapsedSeconds - elapsedSeconds.toInt()) * 100).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${millis.toString().padLeft(2, '0')}';
  }
}
