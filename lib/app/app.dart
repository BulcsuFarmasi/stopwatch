import 'package:flutter/material.dart';
import 'package:stopwatch/features/stopwatch/view/stopwatch_screen.dart';

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: StopwatchScreen( ),
    );
  }
}