import 'package:streaks/core/failures.dart';

/// Outcome of a fallible operation: either a success value of type [T] or a
/// [Failure]. Used by repositories and services instead of throwing so
/// callers handle failure paths explicitly.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;

  const factory Result.error(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;

  bool get isError => this is Err<T>;

  /// Reduces the result to a single value by handling both branches.
  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) error,
  }) {
    final self = this;
    return switch (self) {
      Ok<T>() => ok(self.value),
      Err<T>() => error(self.failure),
    };
  }
}

class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
