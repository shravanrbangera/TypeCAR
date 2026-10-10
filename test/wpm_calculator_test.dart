import 'package:flutter_test/flutter_test.dart';
import 'package:typeracer/core/utils/wpm_calculator.dart';

void main() {
  group('WpmCalculator Tests', () {
    test('calculateWpm returns 0 on 0 or small elapsed time to avoid division by zero', () {
      expect(WpmCalculator.calculateWpm(correctCharacters: 50, elapsedSeconds: 0.0), 0.0);
      expect(WpmCalculator.calculateWpm(correctCharacters: 50, elapsedSeconds: 0.2), 0.0);
      expect(WpmCalculator.calculateWpm(correctCharacters: 0, elapsedSeconds: 10.0), 0.0);
    });

    test('calculateWpm computes standard 5 chars per word accurately', () {
      // 50 characters in 60 seconds = 10 words in 1 minute = 10 WPM
      expect(WpmCalculator.calculateWpm(correctCharacters: 50, elapsedSeconds: 60.0), 10.0);

      // 150 characters in 30 seconds = 30 words in 0.5 minutes = 60 WPM
      expect(WpmCalculator.calculateWpm(correctCharacters: 150, elapsedSeconds: 30.0), 60.0);

      // 300 characters in 30 seconds = 60 words in 0.5 minutes = 120 WPM
      expect(WpmCalculator.calculateWpm(correctCharacters: 300, elapsedSeconds: 30.0), 120.0);
    });

    test('calculateAccuracy returns 100% when no strokes attempted', () {
      expect(WpmCalculator.calculateAccuracy(correctCharacters: 0, totalAttemptedCharacters: 0), 100.0);
    });

    test('calculateAccuracy calculates percentage within 0-100', () {
      expect(WpmCalculator.calculateAccuracy(correctCharacters: 90, totalAttemptedCharacters: 100), 90.0);
      expect(WpmCalculator.calculateAccuracy(correctCharacters: 45, totalAttemptedCharacters: 50), 90.0);
      expect(WpmCalculator.calculateAccuracy(correctCharacters: 0, totalAttemptedCharacters: 10), 0.0);
    });

    test('calculateProgress clamps between 0.0 and 1.0', () {
      expect(WpmCalculator.calculateProgress(correctCharacters: 0, totalCharacters: 100), 0.0);
      expect(WpmCalculator.calculateProgress(correctCharacters: 50, totalCharacters: 100), 0.5);
      expect(WpmCalculator.calculateProgress(correctCharacters: 100, totalCharacters: 100), 1.0);
      expect(WpmCalculator.calculateProgress(correctCharacters: 150, totalCharacters: 100), 1.0);
    });

    test('formatDuration formats MM:SS.ms correctly', () {
      expect(WpmCalculator.formatDuration(0.0), '00:00.00');
      expect(WpmCalculator.formatDuration(65.42), '01:05.42');
      expect(WpmCalculator.formatDuration(120.00), '02:00.00');
    });
  });
}
