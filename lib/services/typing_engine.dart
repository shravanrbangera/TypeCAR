import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/audio/audio_controller.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/wpm_calculator.dart';

class TypingEngine extends ChangeNotifier {
  String _targetText = '';
  String _userInput = '';
  
  DateTime? _raceStartTime;
  DateTime? _raceFinishTime;
  Timer? _ticker;

  int _correctCharactersCount = 0;
  int _incorrectCharactersCount = 0;
  int _totalAttemptedKeystrokes = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  bool _isNitroActive = false;
  Timer? _nitroDurationTimer;

  bool _isFinished = false;
  bool _hasStarted = false;

  // Getters
  String get targetText => _targetText;
  String get userInput => _userInput;
  int get correctCharactersCount => _correctCharactersCount;
  int get incorrectCharactersCount => _incorrectCharactersCount;
  int get totalAttemptedKeystrokes => _totalAttemptedKeystrokes;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  bool get isNitroActive => _isNitroActive;
  bool get isFinished => _isFinished;
  bool get hasStarted => _hasStarted;

  double get elapsedSeconds {
    if (_raceStartTime == null) return 0.0;
    final endTime = _raceFinishTime ?? DateTime.now();
    final diffMs = endTime.difference(_raceStartTime!).inMilliseconds;
    return diffMs / 1000.0;
  }

  double get currentWpm {
    return WpmCalculator.calculateWpm(
      correctCharacters: _correctCharactersCount,
      elapsedSeconds: elapsedSeconds,
    );
  }

  double get accuracy {
    return WpmCalculator.calculateAccuracy(
      correctCharacters: _correctCharactersCount,
      totalAttemptedCharacters: _totalAttemptedKeystrokes,
    );
  }

  double get progress {
    return WpmCalculator.calculateProgress(
      correctCharacters: _correctCharactersCount,
      totalCharacters: _targetText.length,
    );
  }

  /// Initialize or reset the engine with target text
  void resetWithText(String text) {
    _ticker?.cancel();
    _nitroDurationTimer?.cancel();
    _targetText = text.trim();
    _userInput = '';
    _raceStartTime = null;
    _raceFinishTime = null;
    _correctCharactersCount = 0;
    _incorrectCharactersCount = 0;
    _totalAttemptedKeystrokes = 0;
    _currentStreak = 0;
    _bestStreak = 0;
    _isNitroActive = false;
    _isFinished = false;
    _hasStarted = false;
    notifyListeners();
  }

  /// Called when race officially starts (countdown reaches 0)
  void startRace() {
    _hasStarted = true;
    _raceStartTime = DateTime.now();
    _raceFinishTime = null;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isFinished) {
        notifyListeners();
      }
    });
    notifyListeners();
  }

  /// Handles updated text input from the TextField controller
  void handleInputChanged(String newInput) {
    if (!_hasStarted || _isFinished) return;

    final oldLength = _userInput.length;
    final newLength = newInput.length;

    // Handle backspace or deletion
    if (newLength < oldLength) {
      _userInput = newInput;
      _recalculateState();
      AudioController.playKeyClick();
      notifyListeners();
      return;
    }

    // Keystrokes were added
    final addedChars = newInput.substring(oldLength);
    for (int i = 0; i < addedChars.length; i++) {
      _totalAttemptedKeystrokes++;
      final targetIndex = oldLength + i;
      
      if (targetIndex < _targetText.length) {
        final expectedChar = _targetText[targetIndex];
        final typedChar = addedChars[i];

        if (typedChar == expectedChar) {
          _currentStreak++;
          if (_currentStreak > _bestStreak) {
            _bestStreak = _currentStreak;
          }
          AudioController.playKeyClick();

          // Check Nitro Trigger
          if (_currentStreak > 0 &&
              _currentStreak % AppConstants.nitroStreakThreshold == 0 &&
              !_isNitroActive) {
            _triggerNitroBoost();
          }
        } else {
          _currentStreak = 0;
          AudioController.playKeyError();
        }
      }
    }

    _userInput = newInput;
    _recalculateState();

    // Check completion condition
    if (_userInput == _targetText && !_isFinished) {
      _finishRace();
    }

    notifyListeners();
  }

  void _recalculateState() {
    int correct = 0;
    int incorrect = 0;

    for (int i = 0; i < _userInput.length; i++) {
      if (i >= _targetText.length) {
        incorrect++;
      } else if (_userInput[i] == _targetText[i]) {
        if (incorrect == 0) {
          correct++;
        } else {
          // If a prior character was wrong, subsequent chars are blocked/incorrect
          incorrect++;
        }
      } else {
        incorrect++;
      }
    }

    _correctCharactersCount = correct;
    _incorrectCharactersCount = incorrect;
  }

  void _triggerNitroBoost() {
    _isNitroActive = true;
    AudioController.playNitroBoost();
    _nitroDurationTimer?.cancel();
    _nitroDurationTimer = Timer(const Duration(seconds: 4), () {
      _isNitroActive = false;
      notifyListeners();
    });
  }

  void _finishRace() {
    _isFinished = true;
    _raceFinishTime = DateTime.now();
    _ticker?.cancel();
    _nitroDurationTimer?.cancel();
    _isNitroActive = false;
    AudioController.playFinishRace();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _nitroDurationTimer?.cancel();
    super.dispose();
  }
}
