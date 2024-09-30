import 'package:flutter_execution_utilities/flutter_execution_utilities.dart';
import 'package:test/test.dart';

void main() {
  group('Retry Function Tests', () {
    test('should succeed without retries', () async {
      var attempt = 0;

      Future<String> successfulFunction() async {
        attempt++;
        return 'Success';
      }

      final result = await retry(successfulFunction);

      expect(result, 'Success');
      expect(attempt, 1);
    });

    test('should retry and succeed on second attempt', () async {
      var attempt = 0;

      Future<String> sometimesFailingFunction() async {
        attempt++;
        if (attempt < 2) {
          throw Exception('Failed on attempt $attempt');
        }
        return 'Success on attempt $attempt';
      }

      final result = await retry(
        sometimesFailingFunction,
      );

      expect(result, 'Success on attempt 2');
      expect(attempt, 2);
    });

    test('should fail after max retries', () async {
      var attempt = 0;

      Future<String> alwaysFailingFunction() async {
        attempt++;
        throw Exception('Failed on attempt $attempt');
      }

      expect(
        retry(
          alwaysFailingFunction,
        ),
        throwsA(isA<Exception>()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(attempt, 3);
    });

    test('should delay between retries', () async {
      var attempt = 0;
      final attemptTimes = <DateTime>[];

      Future<String> sometimesFailingFunction() async {
        attempt++;
        attemptTimes.add(DateTime.now());
        if (attempt < 3) {
          throw Exception('Failed on attempt $attempt');
        }
        return 'Success on attempt $attempt';
      }

      final startTime = DateTime.now();
      final result = await retry(
        sometimesFailingFunction,
        maxRetries: 5,
        delay: const Duration(milliseconds: 100),
      );

      final totalDuration = DateTime.now().difference(startTime).inMilliseconds;
      expect(result, 'Success on attempt 3');
      expect(attempt, 3);

      expect(totalDuration, greaterThanOrEqualTo(200));

      final delay1 = attemptTimes[1].difference(attemptTimes[0]).inMilliseconds;
      final delay2 = attemptTimes[2].difference(attemptTimes[1]).inMilliseconds;

      expect(delay1, greaterThanOrEqualTo(100));
      expect(delay2, greaterThanOrEqualTo(100));
    });

    test('should handle custom exception types', () async {
      var attempt = 0;

      Future<String> functionThrowingCustomException() async {
        attempt++;
        throw CustomException('Custom exception on attempt $attempt');
      }

      expect(
        retry(
          functionThrowingCustomException,
          maxRetries: 2,
        ),
        throwsA(isA<CustomException>()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(attempt, 2);
    });

    test('should not retry if exception is not retryable', () async {
      var attempt = 0;

      Future<String> functionThrowingNonRetryableException() async {
        attempt++;
        throw FormatException('Non-retriable error on attempt $attempt');
      }

      expect(
        retry(
          functionThrowingNonRetryableException,
          maxRetries: 5,
          delay: const Duration(milliseconds: 50),
          retryIf: (e) => false,
        ),
        throwsA(isA<FormatException>()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(attempt, 1);
    });

    test('should retry only if retryIf returns true', () async {
      var attempt = 0;

      Future<String> functionWithSelectiveFailure() async {
        attempt++;
        if (attempt < 3) {
          throw CustomException('Retriable error on attempt $attempt');
        } else {
          throw FormatException('Non-retriable error on attempt $attempt');
        }
      }

      expect(
        retry(
          functionWithSelectiveFailure,
          maxRetries: 5,
          delay: const Duration(milliseconds: 50),
          retryIf: (e) => e is CustomException,
        ),
        throwsA(isA<FormatException>()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(attempt, 3);
    });
  });
}

class CustomException implements Exception {
  CustomException(this.message);

  final String message;

  @override
  String toString() => 'CustomException: $message';
}
