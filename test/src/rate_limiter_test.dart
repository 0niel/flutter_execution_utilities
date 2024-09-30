import 'package:flutter_execution_utilities/flutter_execution_utilities.dart';
import 'package:test/test.dart';

void main() {
  test('rateLimiter allows calls within limit', () {
    var callCount = 0;
    void testFunction() {
      callCount++;
    }

    final limitedFunction = rateLimiter(testFunction, 5, const Duration(seconds: 1));

    for (var i = 0; i < 5; i++) {
      limitedFunction();
    }

    expect(callCount, 5);
  });

  test('rateLimiter throws exception when limit is exceeded', () {
    var callCount = 0;
    void testFunction() {
      callCount++;
    }

    final limitedFunction = rateLimiter(testFunction, 5, const Duration(seconds: 1));

    for (var i = 0; i < 5; i++) {
      limitedFunction();
    }

    expect(limitedFunction, throwsException);
  });

  test('rateLimiter resets after duration', () async {
    var callCount = 0;
    void testFunction() {
      callCount++;
    }

    final limitedFunction = rateLimiter(testFunction, 5, const Duration(seconds: 1));

    for (var i = 0; i < 5; i++) {
      limitedFunction();
    }

    await Future<void>.delayed(const Duration(seconds: 1));

    limitedFunction();
    expect(callCount, 6);
  });
}
