import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/features/stopwatch/view/formatters/format_duration.dart';

class DigitalClock extends StatelessWidget {
  const new({super.key, required this.elapsed});

  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDuration(elapsed),
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: AppColors.primary),
      textAlign: .center,
    );
  }
}
