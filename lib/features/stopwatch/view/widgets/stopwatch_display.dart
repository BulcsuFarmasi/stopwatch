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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double widthBasedDiameter =
            min(
              MediaQuery.sizeOf(context).width,
              StopwatchConstants.baseWidth,
            ) *
            StopwatchConstants.analogClockDiameterRatio;
        final double diameter = min(widthBasedDiameter, constraints.maxHeight);
        final double scale =
            diameter / StopwatchConstants.analogClockBaseDiameter;

        return SizedBox.square(
          dimension: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom:
                    diameter * StopwatchConstants.digitalClockBottomOffsetRatio,
                child: DigitalClock(elapsed: state.elapsed, scale: scale),
              ),
              AnalogClock(elapsed: state.elapsed),
            ],
          ),
        );
      },
    );
  }
}
