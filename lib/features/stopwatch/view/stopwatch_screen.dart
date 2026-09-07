import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/app/app_lifecycle_observer.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_controls.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_display.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_laps.dart';
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
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compactHeight =
                  constraints.maxHeight <
                  StopwatchConstants.compactHeightBreakpoint;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: StopwatchConstants.baseWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: compactHeight
                          ? StopwatchConstants.compactVerticalPadding
                          : StopwatchConstants.baseVerticalPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      spacing: compactHeight
                          ? StopwatchConstants.compactVerticalSpacing
                          : StopwatchConstants.baseVerticalSpacing,
                      children: [
                        Flexible(child: StopwatchDisplay()),
                        Expanded(child: StopwatchLaps()),
                        StopwatchControls(useCompactLayout: compactHeight),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
