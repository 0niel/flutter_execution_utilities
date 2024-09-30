import 'dart:async';

/// A utility class that batches calls to [func] within a specified [duration],
/// aggregating arguments into a list.
///
/// [func] should accept a list of items and will be called after the specified
/// duration has passed since the last item was added.
///
/// ### Example Usage:
/// ```dart
/// void processBatch(List<int> items) {
///   print('Processing batch: $items');
/// }
///
/// var batcher = Batcher<int>(processBatch, Duration(milliseconds: 100));
///
/// for (int i = 0; i < 10; i++) {
///   batcher.add(i);
/// }
///
/// // After 100 milliseconds, the output will be:
/// // Processing batch: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
/// ```
class Batcher<T> {
  /// Creates a [Batcher] that will call [func] with batched items
  /// after the specified [duration].
  ///
  /// - [func]: The function that will process the batch of items.
  /// - [duration]: The duration to wait before calling [func] with the
  /// batched items.
  Batcher(this.func, this.duration);

  /// The function that processes the batched items.
  final void Function(List<T>) func;

  /// The duration to wait before processing the batch.
  final Duration duration;

  final List<T> _batch = [];

  Timer? _timer;

  /// Adds an item to the batch and starts the timer if it is not already running.
  ///
  /// This method will call [func] with the aggregated items after the
  /// specified [duration] has passed since the last addition.
  ///
  /// ### Example:
  /// ```dart
  /// var batcher = Batcher<int>(processBatch, Duration(milliseconds: 100));
  /// batcher.add(1);
  /// batcher.add(2);
  /// // After 100ms, processBatch will be called with [1, 2].
  /// ```
  void add(T item) {
    _batch.add(item);
    _timer ??= Timer(duration, _flush);
  }

  void _flush() {
    func(List<T>.from(_batch));
    _batch.clear();
    _timer = null;
  }
}
