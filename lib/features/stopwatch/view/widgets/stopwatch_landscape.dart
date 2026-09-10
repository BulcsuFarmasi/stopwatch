import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_controls.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_display.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_laps.dart';

class StopwatchLandscape extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(StopwatchConstants.basePadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: StopwatchConstants.baseSpacing,
        children: [
          Expanded(flex: 5, child: StopwatchDisplay()),
          Expanded(flex: 7, child: StopwatchLaps()),
          Expanded(flex: 3, child: StopwatchControls(useCompactLayout: true)),
        ],
      ),
    );
  }
}
