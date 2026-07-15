/// Base type for typed failures surfaced by the data and notification layers.
///
/// Repositories and services catch low-level exceptions and translate them
/// into a [Failure] with a short, user-safe [message]; raw exception text
/// never reaches the UI.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// A local database operation failed (read, write, or migration).
class DbFailure extends Failure {
  const DbFailure(super.message, {this.cause});

  final Object? cause;
}

/// A local notification could not be scheduled, cancelled, or permission
/// was denied.
class NotificationFailure extends Failure {
  const NotificationFailure(super.message, {this.cause});

  final Object? cause;
}
