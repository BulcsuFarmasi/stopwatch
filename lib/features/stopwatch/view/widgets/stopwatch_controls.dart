import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';

class StopwatchControls extends ConsumerWidget {
  const new({super.key});

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

    return Column(
      children: [
        FilledButton(onPressed: () => notifier.recordLap(), child: Text("Lap")),
        Row(
          spacing: StopwatchConstants.controlSpacing,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FilledButton(
                onPressed: isInitial ? () => notifier.start() : null,
                child: Text("Start"),
              ),
            ),
            Expanded(
              child: FilledButton(
                onPressed: isInitial
                    ? null
                    : () => isPaused ? notifier.start() : notifier.pause(),
                child: Text(isPaused ? "Resume" : "Pause"),
              ),
            ),

            Expanded(
              child: FilledButton(
                onPressed: isInitial ? null : () => notifier.reset(),
                child: Text("Reset"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
