import 'package:cupertino_ui/cupertino_ui.dart';

import '../features/counter/presentation/counter_page.dart';
import 'theme.dart';

/// The root application widget.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Follow the system appearance: switch light/dark via platform brightness.
    final brightness = MediaQuery.platformBrightnessOf(context);
    final theme = brightness == Brightness.dark ? darkTheme : lightTheme;

    return CupertinoApp(
      title: 'Until',
      theme: theme,
      localizationsDelegates: GlobalCupertinoLocalizations.delegates,
      home: const CounterPage(title: 'Until'),
    );
  }
}
