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

    final StopwatchState state = ref.watch(stopwatchNotifierProvider);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: StopwatchConstants.controlWidth),
      child: Row(
        spacing: StopwatchConstants.controlSpacing,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: FilledButton(
              onPressed: state.isInitial ? () => notifier.start() : null,
              child: Text("Start"),
            ),
          ),
          Expanded(
            child: FilledButton(
              onPressed: state.isInitial
                  ? null
                  : () => state.isPaused ? notifier.start() : notifier.pause(),
              child: Text(state.isPaused ? "Resume" : "Pause"),
            ),
          ),

          Expanded(
            child: FilledButton(
              onPressed: state.isInitial ? null : () => notifier.reset(),
              child: Text("Reset"),
            ),
          ),
        ],
      ),
    );
  }
}
