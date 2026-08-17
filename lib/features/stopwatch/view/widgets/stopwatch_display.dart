import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/analog_clock.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/digital_clock.dart';

class StopwatchDisplay extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StopwatchState state = ref.watch(stopwatchNotifierProvider);
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: StopwatchConstants.digitalClockBottomOffset,
          child: DigitalClock(elapsed: state.elapsed),
        ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  (min(
                    MediaQuery.sizeOf(context).width,
                    StopwatchConstants.baseWidth,
                  ) *
                  0.6),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: AnalogClock(elapsed: state.elapsed),
            ),
          ),
        ),
      ],
    );
  }
}
