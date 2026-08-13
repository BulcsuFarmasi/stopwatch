import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_controls.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_display.dart';

class StopwatchScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stopwatch"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [StopwatchDisplay(), StopwatchControls()],
        ),
      ),
    );
  }
}
