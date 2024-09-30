import 'dart:async';

/// Creates a debounced function that delays invoking [action] until after
/// [delay] has passed since the last time the debounced function was called.
///
/// The [leading] parameter determines whether the [action] should be called
/// at the beginning of the delay period (`true`) or at the end (`false`).
/// By default, it's set to `false`.
///
/// ### Example:
/// ```dart
/// final debouncedPrint = debounce<String>((text) {
///   print(text);
/// }, Duration(milliseconds: 500));
///
/// // Only 'Third call' will be printed after 500ms.
/// debouncedPrint('First call');
/// debouncedPrint('Second call');
/// debouncedPrint('Third call');
/// ```
///
/// [action]: The function to debounce.
/// [delay]: The duration to wait before invoking [action].
/// [leading]: If `true`, [action] is invoked at the leading edge of the delay.
Function(T args) debounce<T>(
  void Function(T args) action,
  Duration delay, {
  bool leading = false,
}) {
  Timer? timer;
  var isFirstCall = true;

  return (T args) {
    if (leading && isFirstCall) {
      action(args);
      isFirstCall = false;
    }

    timer?.cancel();
    timer = Timer(delay, () {
      if (!leading) {
        action(args);
      }
      isFirstCall = true;
    });
  };
}
