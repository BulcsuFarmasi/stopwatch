import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/button_slot.dart';
import 'package:stopwatch/l10n/app_strings.dart';

class StopwatchControls extends ConsumerWidget {
  const new({super.key, this.useCompactLayout = false});

  final bool useCompactLayout;

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
    final bool isInitial = state.status == .initial;
    final bool isRunning = state.status == .running;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact =
            useCompactLayout ||
            MediaQuery.sizeOf(context).width <
                StopwatchConstants.compactControlsBreakpoint;
        final bool landscape = MediaQuery.orientationOf(context) == .landscape;

        final Widget startButton = FilledButton(
          onPressed: isInitial && !state.areStopwatchActionsBlocked
              ? () => notifier.start()
              : null,
          child: Text(AppStrings.controlsStart),
        );

        final Widget pauseButton = FilledButton(
          onPressed:
              isInitial ||
                  state.status == null ||
                  state.areStopwatchActionsBlocked
              ? null
              : () => isPaused ? notifier.start() : notifier.pause(),
          child: Text(
            isPaused ? AppStrings.controlsResume : AppStrings.controlsPause,
          ),
        );

        final Widget resetButton = FilledButton(
          onPressed:
              isInitial ||
                  state.status == null ||
                  state.areStopwatchActionsBlocked
              ? null
              : () => notifier.reset(),
          child: Text(AppStrings.controlsReset),
        );

        final Widget lapButton = FilledButton(
          onPressed: isRunning && !state.areStopwatchActionsBlocked
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

        if (landscape) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: StopwatchConstants.compactSpacing,
            children: [startButton, pauseButton, resetButton, lapButton],
          );
        }

        if (compact) {
          return Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: StopwatchConstants.controlSpacing / 4,
              children: [
                Row(
                  spacing: StopwatchConstants.controlSpacing / 4,
                  children: [
                    Expanded(child: startButton),
                    Expanded(child: pauseButton),
                  ],
                ),
                Row(
                  spacing: StopwatchConstants.controlSpacing / 4,
                  children: [
                    Expanded(child: resetButton),
                    Expanded(child: lapButton),
                  ],
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < StopwatchConstants.baseWidth
                ? 10
                : 0,
          ),
          child: Column(
            spacing: StopwatchConstants.controlSpacing,
            children: [
              Row(
                spacing: StopwatchConstants.controlSpacing,
                children: [
                  Expanded(child: startButton),
                  Expanded(child: pauseButton),
                  Expanded(child: resetButton),
                ],
              ),
              ButtonSlot(child: lapButton),
            ],
          ),
        );
      },
    );
  }
}
