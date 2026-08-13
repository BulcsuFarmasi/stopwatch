import 'package:flutter/material.dart';
import 'package:stopwatch/app/theme/app_theme.dart';
import 'package:stopwatch/features/stopwatch/view/stopwatch_screen.dart';

class StopwatchApp extends StatelessWidget {
  const new({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch',
      theme: appTheme,
      home: StopwatchScreen(),
    );
  }
}
