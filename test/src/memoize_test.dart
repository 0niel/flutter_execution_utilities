import 'package:flutter_execution_utilities/flutter_execution_utilities.dart';
import 'package:test/test.dart';

void main() {
  test('memoize caches results based on arguments', () {
    int compute(int x) {
      print('Computing...');
      return x * x;
    }

    final memoizedCompute = memoize(compute);

    expect(memoizedCompute([2]), 4);

    expect(memoizedCompute([2]), 4);

    expect(memoizedCompute([3]), 9);

    expect(memoizedCompute([3]), 9);
  });

  test('memoize handles multiple arguments', () {
    int add(int x, int y) {
      print('Adding...');
      return x + y;
    }

    final memoizedAdd = memoize(add);

    expect(memoizedAdd([2, 3]), 5);

    expect(memoizedAdd([2, 3]), 5);

    expect(memoizedAdd([3, 4]), 7);

    expect(memoizedAdd([3, 4]), 7);
  });

  test('memoize handles no arguments', () {
    int returnTen() {
      print('Returning 10...');
      return 10;
    }

    final memoizedReturnTen = memoize(returnTen);

    expect(memoizedReturnTen(<int>[]), 10);

    expect(memoizedReturnTen(<int>[]), 10);
  });
}
