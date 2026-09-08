import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_controls.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_display.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_laps.dart';

class StopwatchPortrait extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compactHeight =
            constraints.maxHeight < StopwatchConstants.compactHeightBreakpoint;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: StopwatchConstants.baseWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: compactHeight
                    ? StopwatchConstants.compactPadding
                    : StopwatchConstants.basePadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: compactHeight
                    ? StopwatchConstants.compactSpacing
                    : StopwatchConstants.baseSpacing,
                children: [
                  Flexible(child: StopwatchDisplay()),
                  Expanded(child: StopwatchLaps()),
                  StopwatchControls(useCompactLayout: compactHeight),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
