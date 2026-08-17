import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';

class ButtonSlot extends StatelessWidget {
  const new({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact =
            MediaQuery.sizeOf(context).width <
            StopwatchConstants.compactControlsBreakpoint;

        final double width = compact
            ? constraints.maxWidth - 20
            : (constraints.maxWidth - StopwatchConstants.controlSpacing * 2) /
                  3;

        return SizedBox(width: width, child: child);
      },
    );
  }
}
