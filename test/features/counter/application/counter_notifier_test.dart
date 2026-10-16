import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:until/features/counter/application/counter_notifier.dart';

void main() {
  group('CounterNotifier', () {
    test('initial state is 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(counterProvider), 0);
    });

    test('increment increases state by 1', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(counterProvider.notifier).increment();
      expect(container.read(counterProvider), 1);
    });

    test('multiple increments accumulate', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(counterProvider.notifier);
      notifier.increment();
      notifier.increment();
      notifier.increment();

      expect(container.read(counterProvider), 3);
    });
  });
}
