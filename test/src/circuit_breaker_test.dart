import 'dart:async';

import 'package:flutter_execution_utilities/flutter_execution_utilities.dart';
import 'package:test/test.dart';

void main() {
  group('CircuitBreaker', () {
    late CircuitBreaker<void> circuitBreaker;
    late int callCount;
    late Future<void> Function() unreliableOperation;

    setUp(() {
      callCount = 0;
      unreliableOperation = () async {
        callCount++;
        if (callCount <= 3) {
          throw Exception('Operation failed');
        }
      };
      circuitBreaker = CircuitBreaker<void>(
        unreliableOperation,
        failureThreshold: 3,
        resetTimeout: const Duration(seconds: 1),
      );
    });

    test('initial state is closed', () {
      expect(circuitBreaker.state, CircuitState.closed);
    });

    test('executes function when state is closed', () async {
      await circuitBreaker.call();
      expect(callCount, 1);
    });

    test('transitions to open state after reaching failure threshold', () async {
      for (var i = 0; i < 3; i++) {
        try {
          await circuitBreaker.call();
        } catch (_) {}
      }
      expect(circuitBreaker.state, CircuitState.open);
    });

    test('blocks calls when state is open', () async {
      for (var i = 0; i < 3; i++) {
        try {
          await circuitBreaker.call();
        } catch (_) {}
      }
      expect(circuitBreaker.state, CircuitState.open);

      expect(() async => circuitBreaker.call(), throwsException);
    });

    test('transitions to half-open state after reset timeout', () async {
      for (var i = 0; i < 3; i++) {
        try {
          await circuitBreaker.call();
        } catch (_) {}
      }
      expect(circuitBreaker.state, CircuitState.open);

      await Future<void>.delayed(const Duration(seconds: 1));
      expect(circuitBreaker.state, CircuitState.halfOpen);
    });

    test('resets to closed state after successful call in half-open state', () async {
      for (var i = 0; i < 3; i++) {
        try {
          await circuitBreaker.call();
        } catch (_) {}
      }
      expect(circuitBreaker.state, CircuitState.open);

      await Future<void>.delayed(const Duration(seconds: 1));
      expect(circuitBreaker.state, CircuitState.halfOpen);

      await circuitBreaker.call();
      expect(circuitBreaker.state, CircuitState.closed);
    });

    test('reopens circuit after failure in half-open state', () async {
      for (var i = 0; i < 3; i++) {
        try {
          await circuitBreaker.call();
        } catch (_) {}
      }
      expect(circuitBreaker.state, CircuitState.open);

      await Future<void>.delayed(const Duration(seconds: 1));
      expect(circuitBreaker.state, CircuitState.halfOpen);

      try {
        await circuitBreaker.call();
      } catch (_) {}

      expect(circuitBreaker.state, CircuitState.open);
    });
  });
}
