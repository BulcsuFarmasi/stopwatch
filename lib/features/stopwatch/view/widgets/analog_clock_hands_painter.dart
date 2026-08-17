import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';

class AnalogClockHandsPainter extends CustomPainter {
  new({required this.elapsed});

  final Duration elapsed;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale =
        size.shortestSide / StopwatchConstants.analogClockBaseDiameter;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final double radius = size.width / 2;

    final double hourHandLength = radius * 0.6;

    final double minuteHandLength = radius * 0.8;

    final double secondHandLength = radius * 0.85;

    final double hourAngle =
        elapsed.inMilliseconds / 3600000 / 12 * 2 * pi - pi / 2;

    final double minuteAngle =
        elapsed.inMilliseconds / 60000 / 60 * 2 * pi - pi / 2;

    final double secondAngle =
        elapsed.inMilliseconds / 1000 / 60 * 2 * pi - pi / 2;

    final hourEnd = Offset(
      center.dx + cos(hourAngle) * hourHandLength,
      center.dy + sin(hourAngle) * hourHandLength,
    );

    final minuteEnd = Offset(
      center.dx + cos(minuteAngle) * minuteHandLength,
      center.dy + sin(minuteAngle) * minuteHandLength,
    );

    final secondEnd = Offset(
      center.dx + cos(secondAngle) * secondHandLength,
      center.dy + sin(secondAngle) * secondHandLength,
    );

    canvas.drawLine(
      center,
      hourEnd,
      Paint()
        ..strokeWidth = 5 * scale
        ..strokeCap = StrokeCap.round
        ..color = AppColors.text,
    );

    canvas.drawLine(
      center,
      minuteEnd,
      Paint()
        ..strokeWidth = 4 * scale
        ..strokeCap = StrokeCap.round
        ..color = AppColors.text,
    );

    canvas.drawLine(
      center,
      secondEnd,
      Paint()
        ..strokeWidth = 2 * scale
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primary,
    );

    final Paint pinPaint = Paint()
      ..color = AppColors.text
      ..style = .fill;

    canvas.drawCircle(center, 5 * scale, pinPaint);
  }

  @override
  bool shouldRepaint(covariant AnalogClockHandsPainter oldDelegate) =>
      oldDelegate.elapsed != elapsed;
}
