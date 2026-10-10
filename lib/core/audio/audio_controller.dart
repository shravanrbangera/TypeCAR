import 'package:flutter/services.dart';

class AudioController {
  static bool soundEnabled = true;
  static bool hapticsEnabled = true;

  static void playKeyClick() {
    if (!hapticsEnabled) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static void playKeyError() {
    if (hapticsEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    if (soundEnabled) {
      try {
        SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }

  static void playCountdownTick() {
    if (hapticsEnabled) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
    if (soundEnabled) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  static void playRaceStart() {
    if (hapticsEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    if (soundEnabled) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  static void playNitroBoost() {
    if (hapticsEnabled) {
      try {
        HapticFeedback.vibrate();
      } catch (_) {}
    }
    if (soundEnabled) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  static void playFinishRace() {
    if (hapticsEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    if (soundEnabled) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }
}
