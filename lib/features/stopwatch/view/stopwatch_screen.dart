import 'package:flutter/material.dart';

class StopwatchScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stopwatch"), centerTitle: true),
      body: const Center(child: Center(child: Text("Stopwatch"))),
    );
  }
}
