import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/counter_notifier.dart';

/// The counter page, displaying the current count and an increment button.
class CounterPage extends ConsumerWidget {
  const CounterPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have pushed the button this many times:'),
              Text(
                '$counter',
                style: CupertinoTheme.of(context)
                    .textTheme
                    .navLargeTitleTextStyle,
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: () => ref.read(counterProvider.notifier).increment(),
                child: const Icon(CupertinoIcons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
