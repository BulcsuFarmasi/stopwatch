import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';

class StopwatchLapRow extends StatelessWidget {
  const new({super.key, required this.lap});

  final Lap lap;

  String getTimeText(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds % 60;
    final int milliseconds = duration.inMilliseconds % 1000;

    return "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}.${milliseconds.toString().padLeft(3, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      spacing: StopwatchConstants.controlSpacing,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '${lap.number}',
            style: theme.textTheme.bodyMedium,
            textAlign: .center,
          ),
        ),
        Expanded(
          child: Text(
            getTimeText(lap.split),
            style: theme.textTheme.bodyMedium,
            textAlign: .center,
          ),
        ),
        Expanded(
          child: Text(
            getTimeText(lap.total),
            style: theme.textTheme.bodyMedium,
            textAlign: .center,
          ),
        ),
      ],
    );
  }
}
