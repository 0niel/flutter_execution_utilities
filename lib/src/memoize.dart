import 'dart:collection';
import 'package:collection/collection.dart';

/// Returns a memoized version of [func].
///
/// The function result is cached based on its arguments.
/// Subsequent calls with the same arguments return the cached result.
///
/// Example:
/// ```dart
/// int compute(int x) {
///   print('Computing...');
///   return x * x;
/// }
///
/// var memoizedCompute = memoize(compute);
/// memoizedCompute(2); // Prints 'Computing...' and returns 4
/// memoizedCompute(2); // Returns 4 without printing
/// ```
Function memoize(Function func) {
  final cache = HashMap<List<dynamic>, dynamic>(
    equals: (a, b) => a.length == b.length && const ListEquality<dynamic>().equals(a, b),
    hashCode: (key) => key.fold(0, (prev, element) => prev ^ element.hashCode),
  );

  return (List<dynamic> args) {
    if (cache.containsKey(args)) {
      return cache[args];
    } else {
      final result = Function.apply(func, args);
      cache[args] = result;
      return result;
    }
  };
}
