/// Current and longest streak for a single habit, as computed by
/// `streak_calculator.dart`.
class StreakResult {
  const StreakResult({required this.current, required this.longest});

  /// Consecutive scheduled, completed days ending today (or the most
  /// recent scheduled day if today is not scheduled). Zero when there is
  /// no completed history.
  final int current;

  /// The longest run of consecutive scheduled, completed days anywhere in
  /// the habit's history, including but not limited to the current run.
  final int longest;

  static const StreakResult zero = StreakResult(current: 0, longest: 0);

  @override
  bool operator ==(Object other) =>
      other is StreakResult && other.current == current && other.longest == longest;

  @override
  int get hashCode => Object.hash(current, longest);

  @override
  String toString() => 'StreakResult(current: $current, longest: $longest)';
}
