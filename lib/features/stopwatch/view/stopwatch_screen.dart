import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/app/app_lifecycle_observer.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_landscape.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_portrait.dart';
import 'package:stopwatch/l10n/app_strings.dart';

class StopwatchScreen extends ConsumerWidget {
  const StopwatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );
    return AppLifecycleObserver(
      onVisible: () => notifier.startRefreshTimer(),
      onHidden: () => notifier.stopRefreshTimer(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.appTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: SafeArea(
          top: false,
          child: switch (MediaQuery.orientationOf(context)) {
            .portrait => StopwatchPortrait(),
            .landscape => StopwatchLandscape(),
          },
        ),
      ),
    );
  }
}
