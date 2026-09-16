import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';
import 'package:stopwatch/l10n/app_strings.dart';

class LapsHeader extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: AppStrings.lapsHeaderSemantics,
      child: Column(
        children: [
          Row(
            spacing: StopwatchConstants.controlSpacing,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  AppStrings.lapsLap,
                  style: theme.textTheme.bodyMedium,
                  textAlign: .center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  AppStrings.lapsSplit,
                  style: theme.textTheme.bodyMedium,
                  textAlign: .center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  AppStrings.lapsTotal,
                  style: theme.textTheme.bodyMedium,
                  textAlign: .center,
                ),
              ),
            ],
          ),
          Divider(color: AppColors.text),
        ],
      ),
    );
  }
}
