import 'package:flutter/material.dart';

import '../features/counter/presentation/counter_page.dart';

/// The root application widget.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Until',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CounterPage(title: 'Until'),
    );
  }
}
