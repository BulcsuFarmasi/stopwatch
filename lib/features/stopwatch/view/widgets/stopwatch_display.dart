import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_time_text.dart';

class StopwatchDisplay extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StopwatchState state = ref.watch(stopwatchNotifierProvider);
    return Column(children: [StopwatchTimeText(elapsed: state.elapsed)]);
  }
}
