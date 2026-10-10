import 'dart:math';

class RoomCodeGenerator {
  // Omit confusing characters like 0, O, 1, I, L
  static const String _charset = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static final Random _random = Random.secure();

  /// Generates a clean 6-character room code.
  static String generate([int length = 6]) {
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(_charset[_random.nextInt(_charset.length)]);
    }
    return buffer.toString();
  }

  /// Validates a room code format.
  static bool isValid(String? code) {
    if (code == null) return false;
    final trimmed = code.trim().toUpperCase();
    if (trimmed.length != 6) return false;
    final validChars = RegExp(r'^[A-Z0-9]{6}$');
    return validChars.hasMatch(trimmed);
  }

  /// Normalizes room code to uppercase and trimmed string.
  static String normalize(String code) {
    return code.trim().toUpperCase();
  }
}
