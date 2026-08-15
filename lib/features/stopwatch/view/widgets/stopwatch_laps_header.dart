import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/features/stopwatch/constants/stopwatch_constants.dart';

class StopwatchLapsHeader extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        Row(
          spacing: StopwatchConstants.controlSpacing,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Number',
                style: theme.textTheme.bodyMedium,
                textAlign: .center,
              ),
            ),
            Expanded(
              child: Text(
                'Split',
                style: theme.textTheme.bodyMedium,
                textAlign: .center,
              ),
            ),
            Expanded(
              child: Text(
                'Total',
                style: theme.textTheme.bodyMedium,
                textAlign: .center,
              ),
            ),
          ],
        ),
        Divider(color: AppColors.text),
      ],
    );
  }
}
