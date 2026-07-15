import 'package:flutter/material.dart';
import 'package:streaks/app/theme/app_theme.dart';
import 'package:streaks/features/habits/presentation/habit_list_screen.dart';

/// Root widget: `MaterialApp` with the light/dark theme and the habit list
/// as the home screen. Must be mounted under a `ProviderScope` (see
/// `main.dart`).
class StreaksApp extends StatelessWidget {
  const StreaksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'streaks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HabitListScreen(),
    );
  }
}
