import 'package:cupertino_ui/cupertino_ui.dart';

import '../features/counter/presentation/counter_page.dart';

/// The root application widget.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Until',
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.systemPurple,
      ),
      localizationsDelegates: GlobalCupertinoLocalizations.delegates,
      home: const CounterPage(title: 'Until'),
    );
  }
}
