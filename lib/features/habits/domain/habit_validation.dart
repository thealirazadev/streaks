import 'package:streaks/core/constants.dart';

/// Result of validating a habit name: either a [HabitNameValid] trimmed
/// value ready to persist, or a [HabitNameInvalid] with a user-facing
/// message. Pure Dart, no Flutter dependency, so it is testable in
/// isolation from the form widget.
sealed class HabitNameValidation {
  const HabitNameValidation();
}

class HabitNameValid extends HabitNameValidation {
  const HabitNameValid(this.trimmed);

  final String trimmed;
}

class HabitNameInvalid extends HabitNameValidation {
  const HabitNameInvalid(this.message);

  final String message;
}

/// Validates a raw habit name input: trims whitespace, rejects empty or
/// whitespace-only names, and enforces the 1..80 length rule from
/// `docs/rules.md`.
HabitNameValidation validateHabitName(String input) {
  final trimmed = input.trim();
  if (trimmed.length < habitNameMinLength) {
    return const HabitNameInvalid('Name is required.');
  }
  if (trimmed.length > habitNameMaxLength) {
    return const HabitNameInvalid(
      'Name is too long (max $habitNameMaxLength characters).',
    );
  }
  return HabitNameValid(trimmed);
}
