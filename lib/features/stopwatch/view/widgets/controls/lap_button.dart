import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/l10n/app_strings.dart';

class LapButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );

    final ({bool isRunning, bool areStopwatchActionsBlocked}) state = ref.watch(
      stopwatchNotifierProvider.select(
        (AsyncValue<StopwatchState> state) => (
          isRunning: state.value?.status == .running,
          areStopwatchActionsBlocked:
              state.value?.areStopwatchActionsBlocked ?? false,
        ),
      ),
    );

    return FilledButton(
      onPressed: state.isRunning && !state.areStopwatchActionsBlocked
          ? () => notifier.recordLap()
          : null,
      style:
          FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.text,
          ).copyWith(
            side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
              if (states.contains(WidgetState.focused)) {
                return BorderSide(color: AppColors.text, width: 3);
              }
              return null;
            }),
          ),
      child: Text(AppStrings.controlsLap),
    );
  }
}
