import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/l10n/app_strings.dart';

class StartButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );

    final ({bool isInitial, bool areStopwatchActionsBlocked}) state = ref.watch(
      stopwatchNotifierProvider.select(
        (AsyncValue<StopwatchState> state) => (
          isInitial: state.value?.status == .initial,
          areStopwatchActionsBlocked:
              state.value?.areStopwatchActionsBlocked ?? false,
        ),
      ),
    );

    return FilledButton(
      onPressed: state.isInitial && !state.areStopwatchActionsBlocked
          ? () => notifier.start()
          : null,
      child: Text(AppStrings.controlsStart),
    );
  }
}
