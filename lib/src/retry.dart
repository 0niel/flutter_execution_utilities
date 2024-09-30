import 'dart:async';

/// Retries the asynchronous operation [func] up to [maxRetries] times with an
/// optional [delay] between attempts.
///
/// The [retryIf] function can be provided to specify which exceptions
/// should trigger a retry. If [retryIf] is not provided, all exceptions will
/// trigger a retry until [maxRetries] is reached.
///
/// ### Example:
/// ```dart
/// Future<int> unreliableFunction() async {
///   // Simulate a failure.
///   throw Exception('Failed');
/// }
///
/// try {
///   final result = await retry<int>(
///     unreliableFunction,
///     maxRetries: 3,
///     delay: Duration(seconds: 1),
///     retryIf: (e) => e is Exception,
///   );
/// } catch (e) {
///   print('Operation failed after retries: $e');
/// }
/// ```
///
/// [func]: The asynchronous operation to retry.
/// [maxRetries]: The maximum number of retry attempts.
/// [delay]: The duration to wait before each retry.
/// [retryIf]: A function that returns `true` if the exception should be retried.
Future<T> retry<T>(
  Future<T> Function() func, {
  int maxRetries = 3,
  Duration? delay,
  bool Function(Object error)? retryIf,
}) async {
  var attempt = 0;
  while (true) {
    try {
      return await func();
    } catch (e) {
      attempt++;
      if (attempt >= maxRetries || (retryIf != null && !retryIf(e))) {
        rethrow;
      }
      if (delay != null) await Future<void>.delayed(delay);
    }
  }
}
