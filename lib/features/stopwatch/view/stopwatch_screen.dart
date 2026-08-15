import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_controls.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_display.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_laps.dart';

class StopwatchScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Stopwatch",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compactHeight =
              constraints.maxHeight <
              StopwatchConstants.compactHeightBreakpoint;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: StopwatchConstants.baseWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: compactHeight
                      ? StopwatchConstants.compactVerticalPadding
                      : StopwatchConstants.baseVerticalPadding,
                ),
                child: Column(
                  spacing: compactHeight
                      ? StopwatchConstants.compactVerticalSpacing
                      : StopwatchConstants.baseVerticalSpacing,
                  children: [
                    StopwatchDisplay(),
                    Expanded(child: StopwatchLaps()),
                    StopwatchControls(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
