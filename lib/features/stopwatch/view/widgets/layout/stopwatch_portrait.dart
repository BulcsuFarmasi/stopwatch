import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/stopwatch_controls.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/display/stopwatch_display.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps/stopwatch_laps.dart';

class StopwatchPortrait extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final baseFontHeight =
            Theme.of(context).textTheme.bodyMedium?.fontSize ?? 18;

        final double scaledFontSize = MediaQuery.textScalerOf(context)
            .scale(baseFontHeight);

        final bool usesLargeText =
            scaledFontSize >=
            baseFontHeight * StopwatchConstants.largeTextScaleThreshold;

        final bool compactHeight =
            constraints.maxHeight <
                StopwatchConstants.compactHeightBreakpoint ||
            usesLargeText &&
                constraints.maxHeight <
                    StopwatchConstants.largeTextCompactHeightBreakpoint;

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
                  if (compactHeight)
                    SizedBox(
                      height: StopwatchConstants.compactDisplayHeight,
                      child: StopwatchDisplay(digitalOnly: true),
                    )
                  else
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
