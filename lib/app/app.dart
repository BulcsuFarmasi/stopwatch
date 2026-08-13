import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/stopwatch_screen.dart';

class StopwatchApp extends StatelessWidget {
  const new({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: StopwatchScreen(),
    );
  }
}
