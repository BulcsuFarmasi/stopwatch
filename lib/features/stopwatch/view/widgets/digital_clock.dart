import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';

class DigitalClock extends StatelessWidget {
  const new({super.key, required this.elapsed});

  final Duration elapsed;

  String get timeText {
    final int minutes = elapsed.inMinutes;
    final int seconds = elapsed.inSeconds % 60;
    final int milliseconds = elapsed.inMilliseconds % 1000;

    return "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}.${milliseconds.toString().padLeft(3, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      timeText,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: AppColors.primary),
      textAlign: .center,
    );
  }
}
