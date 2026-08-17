import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/features/stopwatch/view/formatters/format_duration.dart';

class DigitalClock extends StatelessWidget {
  const new({super.key, required this.elapsed, required this.scale});

  final Duration elapsed;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.bodyMedium;
    final double? fontSize = textStyle?.fontSize;

    return Text(
      formatDuration(elapsed),
      style: textStyle?.copyWith(
        color: AppColors.primary,
        fontSize: fontSize == null ? null : fontSize * scale,
      ),
      textAlign: .center,
    );
  }
}
