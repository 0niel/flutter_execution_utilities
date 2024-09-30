import 'dart:async';

/// Represents the state of the circuit breaker.
///
/// - [closed]: The circuit is closed, and calls to the function are allowed.
/// - [open]: The circuit is open, and calls to the function are blocked.
/// - [halfOpen]: The circuit is half-open, allowing a limited number of test
/// calls.
enum CircuitState { closed, open, halfOpen }

/// A Circuit Breaker implementation to prevent repeated failures by
/// wrapping an asynchronous function and controlling its execution based
/// on the success or failure rate.
///
/// The circuit breaker transitions between the following states:
/// - **Closed**: Calls to the function are allowed.
/// - **Open**: Calls to the function are blocked to prevent system overload.
/// - **Half-Open**: A test state where limited calls are allowed to check if
/// the issue is resolved.
///
/// This pattern helps in making your system more resilient by avoiding
/// cascading failures and providing a mechanism to recover from errors.
///
/// ### Example Usage:
/// ```dart
/// // Define an asynchronous function that may fail
/// Future<void> unreliableOperation() async {
///   // Implementation that might throw an exception
/// }
///
/// // Create a circuit breaker for the function
/// var circuitBreaker = CircuitBreaker<void>(
///   unreliableOperation,
///   failureThreshold: 5,
///   resetTimeout: Duration(seconds: 10),
/// );
///
/// // Use the circuit breaker to call the function
/// try {
///   await circuitBreaker.call();
/// } catch (e) {
///   // Handle the exception
///   print('Operation failed: $e');
/// }
/// ```
class CircuitBreaker<T> {
  /// Creates a new [CircuitBreaker] that wraps the provided asynchronous
  /// [func].
  ///
  /// - [func]: The asynchronous function to wrap.
  /// - [failureThreshold]: The number of consecutive failures before opening
  /// the circuit.
  ///   Defaults to 5 if not specified.
  /// - [resetTimeout]: The duration the circuit remains open before
  /// transitioning to half-open.
  CircuitBreaker(
    this.func, {
    required this.resetTimeout,
    this.failureThreshold = 5,
    Timer Function(Duration, void Function())? timerFactory,
  }) : _timerFactory = timerFactory ?? Timer.new;

  /// The asynchronous function that the circuit breaker wraps.
  final Future<T> Function() func;

  /// The number of consecutive failures allowed before opening the circuit.
  final int failureThreshold;

  /// The duration the circuit remains open before attempting to reset.
  final Duration resetTimeout;

  CircuitState _state = CircuitState.closed;

  int _failureCount = 0;

  Timer? _resetTimer;

  /// Exposes the current state of the circuit breaker.
  CircuitState get state => _state;

  /// Exposes the current failure count.
  int get failureCount => _failureCount;

  /// A function that creates a [Timer]. Useful for injecting a mock timer in
  /// tests.
  final Timer Function(Duration duration, void Function() callback) _timerFactory;

  /// Executes the wrapped function based on the current circuit state.
  ///
  /// - If the circuit is **closed**, it attempts to execute the function.
  /// - If the circuit is **open**, it immediately throws an exception.
  /// - If the circuit is **half-open**, it attempts to execute the function
  ///   to test if the external resource has recovered.
  ///
  /// Returns a [Future] that completes with the result of [func] or an error.
  ///
  /// ### Example:
  /// ```dart
  /// try {
  ///   var result = await circuitBreaker.call();
  /// } catch (e) {
  ///   // Handle failure
  /// }
  /// ```
  Future<T> call() async {
    switch (_state) {
      case CircuitState.open:
        // Circuit is open; do not attempt to call the function
        throw Exception('Circuit is open. Calls are temporarily blocked.');
      case CircuitState.halfOpen:
        // Circuit is half-open; attempt to reset by calling the function
        return _attemptReset();
      case CircuitState.closed:
        // Circuit is closed; proceed to execute the function
        return _execute();
    }
  }

  void _reset() {
    _state = CircuitState.closed;
    _failureCount = 0;
    _resetTimer?.cancel();
    _resetTimer = null;
  }

  void _trip() {
    _state = CircuitState.open;
    _resetTimer?.cancel();
    _resetTimer = _timerFactory(resetTimeout, _halfOpen);
  }

  void _halfOpen() {
    _state = CircuitState.halfOpen;
  }

  Future<T> _execute() async {
    try {
      final result = await func();
      _reset();
      return result;
    } catch (e) {
      _failureCount++;
      if (_failureCount >= failureThreshold) {
        _trip();
      }
      rethrow;
    }
  }

  Future<T> _attemptReset() async {
    try {
      final result = await func();
      _reset();
      return result;
    } catch (e) {
      _trip();
      rethrow;
    }
  }
}
