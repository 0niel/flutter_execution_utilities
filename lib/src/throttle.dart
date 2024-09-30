import 'dart:async';

/// Creates a throttled function that only invokes [action] at most once
/// every [delay] duration.
///
/// The [leading] parameter determines whether the [action] should be called
/// at the beginning of the delay period (`true`) or at the end (`false`).
/// The [trailing] parameter determines if the last invocation should be called
/// after the delay. By default, [leading] is `true` and [trailing] is `false`.
///
/// ### Example:
/// ```dart
/// final throttledPrint = throttle<String>((text) {
///   print(text);
/// }, Duration(milliseconds: 500));
///
/// // 'First call' is printed immediately.
/// // 'Third call' is printed after 500ms.
/// throttledPrint('First call');
/// throttledPrint('Second call');
/// throttledPrint('Third call');
/// ```
///
/// [action]: The function to throttle.
/// [delay]: The duration to wait before allowing another call to [action].
/// [leading]: If `true`, [action] is invoked at the leading edge of the delay.
/// [trailing]: If `true`, ensures the last call is invoked after the delay.
Function(T) throttle<T>(
  void Function(T args) action,
  Duration delay, {
  bool leading = true,
  bool trailing = false,
}) {
  var isThrottling = false;
  T? lastArgs;
  Timer? timer;

  void invokeAction(T args) {
    action(args);
    isThrottling = true;
    timer = Timer(delay, () {
      isThrottling = false;
      if (trailing && lastArgs != null) {
        invokeAction(lastArgs as T);
        lastArgs = null;
      }
    });
  }

  return (T args) {
    if (!isThrottling) {
      if (leading) {
        invokeAction(args);
      } else if (trailing) {
        lastArgs = args;
        timer ??= Timer(delay, () {
          isThrottling = false;
          if (lastArgs != null) {
            action(lastArgs as T);
            lastArgs = null;
          }
        });
      }
    } else if (trailing) {
      lastArgs = args;
    }
  };
}
