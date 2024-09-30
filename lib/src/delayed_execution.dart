import 'dart:async';

/// Returns a function that delays the execution of [func] by [delay] duration.
///
/// Example:
/// ```dart
/// var delayedFunction = delayExecution(myFunction, Duration(seconds: 2));
/// delayedFunction();
/// ```
Function delayExecution(Function func, Duration delay) {
  return ([List<dynamic>? args]) {
    Timer(delay, () => Function.apply(func, args));
  };
}
