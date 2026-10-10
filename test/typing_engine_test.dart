import 'package:flutter_test/flutter_test.dart';
import 'package:typeracer/core/audio/audio_controller.dart';
import 'package:typeracer/services/typing_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TypingEngine Tests', () {
    late TypingEngine engine;

    setUp(() {
      AudioController.soundEnabled = false;
      AudioController.hapticsEnabled = false;
      engine = TypingEngine();
    });

    test('Initial state after resetWithText', () {
      engine.resetWithText('Hello World');
      expect(engine.targetText, 'Hello World');
      expect(engine.userInput, '');
      expect(engine.progress, 0.0);
      expect(engine.correctCharactersCount, 0);
      expect(engine.incorrectCharactersCount, 0);
      expect(engine.isFinished, false);
      expect(engine.hasStarted, false);
      expect(engine.isNitroActive, false);
    });

    test('Ignores input before startRace', () {
      engine.resetWithText('Hello World');
      engine.handleInputChanged('Hello');
      expect(engine.userInput, '');
      expect(engine.correctCharactersCount, 0);
    });

    test('Correct keystrokes advance progress', () {
      engine.resetWithText('Hello World');
      engine.startRace();

      engine.handleInputChanged('Hell');
      expect(engine.correctCharactersCount, 4);
      expect(engine.incorrectCharactersCount, 0);
      expect(engine.progress, 4 / 11);
      expect(engine.currentStreak, 4);
      expect(engine.bestStreak, 4);
    });

    test('Incorrect keystrokes halt progress and trigger errors', () {
      engine.resetWithText('Hello World');
      engine.startRace();

      engine.handleInputChanged('Helx');
      expect(engine.correctCharactersCount, 3);
      expect(engine.incorrectCharactersCount, 1);
      expect(engine.currentStreak, 0); // streak reset
      expect(engine.progress, 3 / 11);
    });

    test('Backspace removes incorrect character and recovers progress', () {
      engine.resetWithText('Hello World');
      engine.startRace();

      engine.handleInputChanged('Helx');
      expect(engine.incorrectCharactersCount, 1);

      // Backspace simulation
      engine.handleInputChanged('Hel');
      expect(engine.incorrectCharactersCount, 0);
      expect(engine.correctCharactersCount, 3);

      // Continue typing correctly
      engine.handleInputChanged('Hell');
      expect(engine.correctCharactersCount, 4);
      expect(engine.incorrectCharactersCount, 0);
    });

    test('Completing text finishes race with 100% progress', () {
      engine.resetWithText('Speed');
      engine.startRace();

      engine.handleInputChanged('Speed');
      expect(engine.isFinished, true);
      expect(engine.progress, 1.0);
      expect(engine.correctCharactersCount, 5);
      expect(engine.accuracy, 100.0);
    });

    test('Accuracy drops when mistakes are made', () {
      engine.resetWithText('Car');
      engine.startRace();

      // Mistake on 1st char: 'X', then backspace '', then 'C', 'a', 'r'
      engine.handleInputChanged('X');
      engine.handleInputChanged('');
      engine.handleInputChanged('C');
      engine.handleInputChanged('Ca');
      engine.handleInputChanged('Car');

      expect(engine.isFinished, true);
      // Total attempted: 4 ('X', 'C', 'a', 'r'), Correct: 3
      expect(engine.totalAttemptedKeystrokes, 4);
      expect(engine.accuracy, (3 / 4) * 100);
    });
  });
}
