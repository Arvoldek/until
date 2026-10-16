import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that manages the counter state.
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  /// Increments the counter by one.
  void increment() => state++;
}

/// Provider that exposes the [CounterNotifier] and its state.
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});
