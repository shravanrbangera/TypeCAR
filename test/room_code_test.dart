import 'package:flutter_test/flutter_test.dart';
import 'package:typeracer/core/utils/room_code_generator.dart';

void main() {
  group('RoomCodeGenerator Tests', () {
    test('generate produces 6 character uppercase string', () {
      final code = RoomCodeGenerator.generate();
      expect(code.length, 6);
      expect(RoomCodeGenerator.isValid(code), true);
    });

    test('generate produces random non-confusing characters', () {
      final codes = <String>{};
      for (int i = 0; i < 50; i++) {
        final c = RoomCodeGenerator.generate();
        codes.add(c);
        expect(c.contains('0'), false);
        expect(c.contains('O'), false);
        expect(c.contains('1'), false);
        expect(c.contains('I'), false);
      }
      expect(codes.length, greaterThan(45)); // High entropy
    });

    test('isValid validates code constraints properly', () {
      expect(RoomCodeGenerator.isValid('AB7X89'), true);
      expect(RoomCodeGenerator.isValid('ab7x89'), true); // normalized in isValid
      expect(RoomCodeGenerator.isValid(''), false);
      expect(RoomCodeGenerator.isValid('12345'), false); // too short
      expect(RoomCodeGenerator.isValid('1234567'), false); // too long
      expect(RoomCodeGenerator.isValid('ABC-EF'), false); // special char
    });

    test('normalize trims and uppercases code', () {
      expect(RoomCodeGenerator.normalize('  kv7r8m  '), 'KV7R8M');
    });
  });
}
