import 'dart:async';

import 'package:flutter_execution_utilities/flutter_execution_utilities.dart';
import 'package:test/test.dart';

void main() {
  test('Batcher calls function with batched items after duration', () async {
    final batches = <List<int>>[];
    void processBatch(List<int> items) {
      batches.add(items);
    }

    final batcher = Batcher<int>(processBatch, const Duration(milliseconds: 100));

    for (var i = 0; i < 10; i++) {
      batcher.add(i);
    }

    // Wait for the duration to ensure the batch is processed
    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(batches.length, 1);
    expect(batches[0], List.generate(10, (index) => index));
  });

  test('Batcher processes multiple batches correctly', () async {
    final batches = <List<int>>[];
    void processBatch(List<int> items) {
      batches.add(items);
    }

    final batcher = Batcher<int>(processBatch, const Duration(milliseconds: 100));

    batcher.add(1);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    batcher.add(2);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(batches.length, 2);
    expect(batches[0], [1]);
    expect(batches[1], [2]);
  });

  test('Batcher does not call function if no items are added', () async {
    final batches = <List<int>>[];
    void processBatch(List<int> items) {
      batches.add(items);
    }

    final batcher = Batcher<int>(processBatch, const Duration(milliseconds: 100));

    // Wait for the duration to ensure no batch is processed
    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(batches.isEmpty, true);
  });
}
