import 'package:flutter_execution_utilities/flutter_execution_utilities.dart';
import 'package:test/test.dart';

void main() {
  group('Throttle Function', () {
    test('should call action immediately if leading is true', () async {
      final calls = <String>[];
      final throttledAction = throttle(
        (args) {
          calls.add('Called with: $args');
        },
        const Duration(milliseconds: 100),
      );

      throttledAction('First call');
      throttledAction('Second call');
      throttledAction('Third call');

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(calls.length, 1);
      expect(calls[0], 'Called with: First call');
    });

    test('should call action after delay if leading is false', () async {
      final calls = <String>[];
      final throttledAction = throttle(
        (args) {
          calls.add('Called with: $args');
        },
        const Duration(milliseconds: 100),
        leading: false,
        trailing: true,
      );

      throttledAction('First call');
      throttledAction('Second call');
      throttledAction('Third call');

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(calls.length, 1);
      expect(calls[0], 'Called with: Third call');
    });
    test('should call trailing action if trailing is true', () async {
      final calls = <String>[];
      final throttledAction = throttle(
        (args) {
          calls.add('Called with: $args');
        },
        const Duration(milliseconds: 100),
        trailing: true,
      );

      throttledAction('First call');
      throttledAction('Second call');
      throttledAction('Third call');

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(calls.length, 2);
      expect(calls[0], 'Called with: First call');
      expect(calls[1], 'Called with: Third call');
    });

    test('should handle null args', () async {
      final calls = <String>[];
      final throttledAction = throttle(
        (args) {
          calls.add('Called with: $args');
        },
        const Duration(milliseconds: 100),
      );

      throttledAction(null);

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(calls.length, 1);
      expect(calls[0], 'Called with: null');
    });

    test('should not call action if throttling and trailing is false', () async {
      final calls = <String>[];
      final throttledAction = throttle(
        (args) {
          calls.add('Called with: $args');
        },
        const Duration(milliseconds: 100),
      );

      throttledAction('First call');
      throttledAction('Second call');
      throttledAction('Third call');

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(calls.length, 1);
      expect(calls[0], 'Called with: First call');
    });
  });
}
