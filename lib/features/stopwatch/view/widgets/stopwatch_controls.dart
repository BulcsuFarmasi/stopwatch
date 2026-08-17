import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/button_slot.dart';

class StopwatchControls extends ConsumerWidget {
  const new({super.key, this.useCompactLayout = false});

  final bool useCompactLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );

    final StopwatchStatus status = ref.watch(
      stopwatchNotifierProvider.select((StopwatchState state) => state.status),
    );

    final bool isPaused = status == .paused;
    final bool isInitial = status == .initial;
    final bool isRunning = status == .running;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact =
            useCompactLayout ||
            MediaQuery.sizeOf(context).width <
                StopwatchConstants.compactControlsBreakpoint;

        final Widget startButton = FilledButton(
          onPressed: isInitial ? () => notifier.start() : null,
          child: Text("Start"),
        );

        final Widget pauseButton = FilledButton(
          onPressed: isInitial
              ? null
              : () => isPaused ? notifier.start() : notifier.pause(),
          child: Text(isPaused ? "Resume" : "Pause"),
        );

        final Widget resetButton = FilledButton(
          onPressed: isInitial ? null : () => notifier.reset(),
          child: Text("Reset"),
        );

        final Widget lapButton = FilledButton(
          onPressed: isRunning ? () => notifier.recordLap() : null,
          style: FilledButton.styleFrom(backgroundColor: AppColors.secondary),
          child: Text("Lap"),
        );

        if (compact) {
          return Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
            child: Column(
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
