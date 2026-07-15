import 'package:flutter_test/flutter_test.dart';
import 'package:streaks/features/habits/domain/habit_validation.dart';

void main() {
  group('validateHabitName', () {
    test('rejects an empty name', () {
      final result = validateHabitName('');
      expect(result, isA<HabitNameInvalid>());
    });

    test('rejects a whitespace-only name', () {
      final result = validateHabitName('   ');
      expect(result, isA<HabitNameInvalid>());
    });

    test('trims a valid name', () {
      final result = validateHabitName('  Read daily  ');
      expect(result, isA<HabitNameValid>());
      expect((result as HabitNameValid).trimmed, 'Read daily');
    });

    test('accepts a name at the 80 character limit', () {
      final name = 'a' * 80;
      final result = validateHabitName(name);
      expect(result, isA<HabitNameValid>());
    });

    test('rejects a name over the 80 character limit', () {
      final name = 'a' * 81;
      final result = validateHabitName(name);
      expect(result, isA<HabitNameInvalid>());
    });

    test('rejects a name over the limit even after trimming', () {
      final name = '  ${'a' * 81}  ';
      final result = validateHabitName(name);
      expect(result, isA<HabitNameInvalid>());
    });
  });
}
