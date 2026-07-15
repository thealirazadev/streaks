import 'dart:developer' as developer;

/// Severity levels for [Logger] output.
///
/// `debug` traces normal flow, `info` marks lifecycle events, `warning`
/// covers recoverable issues, and `error` covers failures worth surfacing
/// to a developer reading the console.
enum LogLevel { debug, info, warning, error }

/// Thin logging wrapper used app-wide instead of `print`.
///
/// Construct one per file or class with a short, identifying [tag] so log
/// output can be filtered by origin.
class Logger {
  const Logger(this.tag);

  final String tag;

  void debug(String message) => _log(LogLevel.debug, message);

  void info(String message) => _log(LogLevel.info, message);

  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.warning, message, error, stackTrace);

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);

  void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    developer.log(
      message,
      name: tag,
      level: _severity(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  int _severity(LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}
