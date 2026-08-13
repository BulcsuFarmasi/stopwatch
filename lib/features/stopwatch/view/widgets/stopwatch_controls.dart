import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';

class StopwatchControls extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StopwatchNotifier notifier = ref.read(
      stopwatchNotifierProvider.notifier,
    );

    final StopwatchState state = ref.watch(stopwatchNotifierProvider);

    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(onPressed: () => notifier.start(), child: Text("Start")),
        FilledButton(
          onPressed: state.isInitial
              ? null
              : () => state.isPaused ? notifier.start() : notifier.pause(),
          child: Text(state.isPaused ? "Resume" : "Pause"),
        ),
        FilledButton(onPressed: () => notifier.reset(), child: Text("Reset")),
      ],
    );
  }
}
