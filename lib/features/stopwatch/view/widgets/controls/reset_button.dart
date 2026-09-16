import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';
import 'package:stopwatch/l10n/app_strings.dart';

class ResetButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );

    final ({StopwatchStatus? status, bool areStopwatchActionsBlocked}) state =
        ref.watch(
          stopwatchNotifierProvider.select(
            (AsyncValue<StopwatchState> state) => (
              status: state.value?.status,
              areStopwatchActionsBlocked:
                  state.value?.areStopwatchActionsBlocked ?? false,
            ),
          ),
        );

    final bool isPaused = state.status == .paused;
    final bool isRunning = state.status == .running;

    return FilledButton(
      onPressed: (isPaused || isRunning) && !state.areStopwatchActionsBlocked
          ? () => notifier.reset()
          : null,
      child: Text(AppStrings.controlsReset),
    );
  }
}
