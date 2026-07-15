import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaks/data/repositories/habit_repository_provider.dart';
import 'package:streaks/features/habits/domain/habit.dart';
import 'package:streaks/features/habits/domain/habit_validation.dart';

/// Default accent color for a new habit: the first swatch in
/// `AppColors.habitPalette` (kept as a plain ARGB int so this layer does
/// not need to import Flutter).
const int defaultHabitColor = 0xFFE4572E;

const Object _unset = Object();

/// Immutable state for the create-habit form.
class HabitFormState {
  const HabitFormState({
    this.name = '',
    this.nameError,
    this.color = defaultHabitColor,
    this.schedule = Schedule.everyDay,
    this.isSaving = false,
    this.submitError,
    this.saved = false,
  });

  final String name;
  final String? nameError;
  final int color;
  final Schedule schedule;
  final bool isSaving;
  final String? submitError;

  /// True once the current form contents have been saved successfully.
  /// The screen watches this to pop itself.
  final bool saved;

  bool get canSubmit => !isSaving && validateHabitName(name) is HabitNameValid;

  HabitFormState copyWith({
    String? name,
    Object? nameError = _unset,
    int? color,
    Schedule? schedule,
    bool? isSaving,
    Object? submitError = _unset,
    bool? saved,
  }) {
    return HabitFormState(
      name: name ?? this.name,
      nameError: identical(nameError, _unset)
          ? this.nameError
          : nameError as String?,
      color: color ?? this.color,
      schedule: schedule ?? this.schedule,
      isSaving: isSaving ?? this.isSaving,
      submitError: identical(submitError, _unset)
          ? this.submitError
          : submitError as String?,
      saved: saved ?? this.saved,
    );
  }
}

/// Controls the create-habit form: field state, validation, and
/// submission. Widgets never call the repository directly (see
/// `docs/rules.md`); they call this controller.
class HabitFormController extends Notifier<HabitFormState> {
  @override
  HabitFormState build() => const HabitFormState();

  void nameChanged(String value) {
    final validation = validateHabitName(value);
    state = state.copyWith(
      name: value,
      // Do not show "required" for an untouched/empty field; only surface
      // it once the user has typed something and cleared it, or on submit.
      nameError: switch (validation) {
        HabitNameValid() => null,
        HabitNameInvalid() => state.nameError == null && value.isEmpty
            ? null
            : (validation as HabitNameInvalid).message,
      },
    );
  }

  void colorChanged(int color) {
    state = state.copyWith(color: color);
  }

  void weekdayToggled(int weekday) {
    state = state.copyWith(schedule: state.schedule.toggle(weekday));
  }

  /// Attempts to save the habit. Returns true on success.
  Future<bool> submit() async {
    final validation = validateHabitName(state.name);
    if (validation is HabitNameInvalid) {
      state = state.copyWith(nameError: validation.message);
      return false;
    }
    final trimmed = (validation as HabitNameValid).trimmed;
    state = state.copyWith(isSaving: true, submitError: null);
    final repository = ref.read(habitRepositoryProvider);
    final result = await repository.createHabit(
      name: trimmed,
      color: state.color,
      schedule: state.schedule,
    );
    return result.when(
      ok: (_) {
        state = state.copyWith(isSaving: false, saved: true);
        return true;
      },
      error: (failure) {
        state = state.copyWith(isSaving: false, submitError: failure.message);
        return false;
      },
    );
  }
}

final habitFormControllerProvider =
    NotifierProvider.autoDispose<HabitFormController, HabitFormState>(
      HabitFormController.new,
    );
