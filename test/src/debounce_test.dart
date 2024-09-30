import 'package:flutter_execution_utilities/flutter_execution_utilities.dart';
import 'package:test/test.dart';

void main() {
  group('Debounce Function', () {
    test('should debounce calls and use the last argument', () async {
      final calls = <String>[];
      final debouncedAction = debounce<String>(
        (arg) => calls.add('Called with: $arg'),
        const Duration(milliseconds: 100),
      );

      debouncedAction('First call');
      debouncedAction('Second call');
      debouncedAction('Third call');

      expect(calls.length, 0);

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(calls.length, 1);
      expect(calls[0], 'Called with: Third call');
    });

    test('should call immediately when leading is true', () async {
      final calls = <String>[];
      final debouncedAction = debounce<String>(
        (arg) => calls.add('Called with: $arg'),
        const Duration(milliseconds: 100),
        leading: true,
      );

      debouncedAction('First call');
      debouncedAction('Second call');
      debouncedAction('Third call');

      expect(calls.length, 1);
      expect(calls[0], 'Called with: First call');

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(calls.length, 1);
    });
  });

  group('Throttle Function', () {
    test('should throttle calls and use the first argument', () async {
      final calls = <String>[];
      final throttledAction = throttle<String>(
        (arg) => calls.add('Called with: $arg'),
        const Duration(milliseconds: 100),
      );

      throttledAction('First call');
      throttledAction('Second call');
      throttledAction('Third call');

      expect(calls.length, 1);
      expect(calls[0], 'Called with: First call');

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(calls.length, 1);
    });

    test('should call trailing when trailing is true', () async {
      final calls = <String>[];
      final throttledAction = throttle<String>(
        (arg) => calls.add('Called with: $arg'),
        const Duration(milliseconds: 100),
        trailing: true,
      );

      throttledAction('First call');
      throttledAction('Second call');
      throttledAction('Third call');

      expect(calls.length, 1);
      expect(calls[0], 'Called with: First call');

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(calls.length, 2);
      expect(calls[1], 'Called with: Third call');
    });

    test('should not call leading when leading is false', () async {
      final calls = <String>[];
      final throttledAction = throttle<String>(
        (arg) => calls.add('Called with: $arg'),
        const Duration(milliseconds: 100),
        leading: false,
        trailing: true,
      );

      throttledAction('First call');
      throttledAction('Second call');

      expect(calls.length, 0);

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(calls.length, 1);
      expect(calls[0], 'Called with: Second call');
    });
  });
}
