import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/l10n/app_strings.dart';

class ClearLapsButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool areStopwatchActionsBlocked = ref.watch(
      stopwatchNotifierProvider.select(
        (AsyncValue<StopwatchState> state) =>
            state.value?.areStopwatchActionsBlocked ?? false,
      ),
    );

    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );

    return OutlinedButton(
      onPressed: areStopwatchActionsBlocked ? null : () => notifier.clearLaps(),
      child: Text(AppStrings.clearLaps),
    );
  }
}
