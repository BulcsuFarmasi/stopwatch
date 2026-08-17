import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/formatters/format_duration.dart';

class LapRow extends StatelessWidget {
  const new({super.key, required this.lap});

  final Lap lap;

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
            formatDuration(lap.split),
            style: theme.textTheme.bodyMedium,
            textAlign: .center,
          ),
        ),
        Expanded(
          child: Text(
            formatDuration(lap.total),
            style: theme.textTheme.bodyMedium,
            textAlign: .center,
          ),
        ),
      ],
    );
  }
}
