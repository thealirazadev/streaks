import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streaks/app/theme/app_spacing.dart';
import 'package:streaks/features/habits/application/habit_form_controller.dart';
import 'package:streaks/features/habits/domain/habit.dart';
import 'package:streaks/features/habits/presentation/widgets/color_picker.dart';
import 'package:streaks/features/habits/presentation/widgets/schedule_picker.dart';

/// Create- or edit-habit form: name, color, and weekly schedule. Pass
/// [habit] to edit an existing habit in place; omit it to create a new one.
class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({this.habit, super.key});

  final Habit? habit;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    _nameController = TextEditingController(text: habit?.name ?? '');
    if (habit != null) {
      // Seed the controller before the first build so `canSubmit` and the
      // displayed color/schedule reflect the existing habit immediately.
      ref.read(habitFormControllerProvider.notifier).startEditing(habit);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref.read(habitFormControllerProvider.notifier).submit();
    if (ok && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(habitFormControllerProvider);
    final controller = ref.read(habitFormControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(state.isEditing ? 'Edit habit' : 'New habit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: 'Habit name',
                errorText: state.nameError,
              ),
              onChanged: controller.nameChanged,
            ),
            const SizedBox(height: AppSpacing.space24),
            Text('Color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.space12),
            ColorPicker(value: state.color, onChanged: controller.colorChanged),
            const SizedBox(height: AppSpacing.space24),
            Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.space12),
            SchedulePicker(
              schedule: state.schedule,
              onToggle: controller.weekdayToggled,
            ),
            if (state.submitError != null) ...[
              const SizedBox(height: AppSpacing.space16),
              Text(
                state.submitError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.space32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.canSubmit ? _submit : null,
                child: state.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
