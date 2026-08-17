import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/analog_clock_face_painter.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/analog_clock_hands_painter.dart';

class AnalogClock extends StatelessWidget {
  const new({super.key, required this.elapsed});

  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: AnalogClockFacePainter()),
        CustomPaint(painter: AnalogClockHandsPainter(elapsed: elapsed)),
      ],
    );
  }
}
