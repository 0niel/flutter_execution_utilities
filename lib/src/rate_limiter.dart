import 'dart:collection';

/// Creates a rate-limited version of [func] that allows only [maxCalls]
/// executions per [duration].
///
/// Example:
/// ```dart
/// var limitedFunction = rateLimiter(myFunction, 5, Duration(seconds: 1));
/// ```
Function rateLimiter(Function func, int maxCalls, Duration duration) {
  var callCount = 0;
  final callTimestamps = Queue<DateTime>();

  return ([List<dynamic>? args]) {
    final now = DateTime.now();

    while (callTimestamps.isNotEmpty && now.difference(callTimestamps.first) > duration) {
      callTimestamps.removeFirst();
      callCount--;
    }

    if (callCount < maxCalls) {
      callCount++;
      callTimestamps.addLast(now);
      return Function.apply(func, args ?? []);
    } else {
      throw Exception('Rate limit exceeded');
    }
  };
}
