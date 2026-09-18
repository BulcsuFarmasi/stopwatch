import 'package:flutter/material.dart';

class StopwatchAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> actions;

  const new({
    super.key,
    required this.title,
    required this.description,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, textAlign: .center),
      content: Text(description, textAlign: .center),
      actions: actions,
    );
  }
}

Future<void> showStopwatchAlertDialog(
  BuildContext context,
  StopwatchAlertDialog alertDialog,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => alertDialog,
  );
}
