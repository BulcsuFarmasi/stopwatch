import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/formatters/format_duration.dart';
import 'package:stopwatch/l10n/app_strings.dart';

class LapRow extends StatelessWidget {
  const new({super.key, required this.lap});

  final Lap lap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final DurationParts splitParts = splitDuration(lap.split);
    final DurationParts totalParts = splitDuration(lap.total);

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: AppStrings.lapsSemantics(
        number: lap.number,
        splitSemantics: AppStrings.splitSemantics(
          minutes: splitParts.minutes,
          seconds: splitParts.seconds,
          milliseconds: splitParts.milliseconds,
        ),
        totalSemantics: AppStrings.totalSemantics(
          minutes: totalParts.minutes,
          seconds: totalParts.seconds,
          milliseconds: totalParts.milliseconds,
        ),
      ),
      child: Row(
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
      ),
    );
  }
}
