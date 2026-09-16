import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_colors.dart';
import 'package:stopwatch/features/stopwatch/view/constants/stopwatch_constants.dart';

class AnalogClockFacePainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    final double scale =
        size.shortestSide / StopwatchConstants.analogClockBaseDiameter;
    final Paint paint = Paint()
      ..color = AppColors.text
      ..strokeWidth = max(0.5, scale)
      ..style = .stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);

    for (int i = 0; i < 12; i++) {
      final int displayNumber = i == 0 ? 12 : i;

      final double angle = (i * 2 * pi / 12) - pi / 2;

      final numberRadius = radius * 0.85;

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '$displayNumber',
          style: TextStyle(
            fontFamily: 'RobotoCondensed',
            fontWeight: .w500,
            fontSize: 16 * scale,
            color: AppColors.text,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final numberX = center.dx + numberRadius * cos(angle);
      final numberY = center.dy + numberRadius * sin(angle);

      final Offset position = Offset(
        numberX - (textPainter.width / 2),
        numberY - (textPainter.height / 2),
      );

      textPainter.paint(canvas, position);
    }
  }

  @override
  bool shouldRepaint(covariant AnalogClockFacePainter oldDelegate) => false;
}
