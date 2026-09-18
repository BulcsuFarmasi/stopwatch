import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/shared/widgets/stopwatch_alert_dialog.dart';

void main() {
  const String title = "Test Title";
  const String description = "Test Description";
  group("StopwatchAlertDialog", () {
    final Widget action = TextButton(
      onPressed: () {},
      child: Text("Test Action"),
    );

    Future<void> buildWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StopwatchAlertDialog(
            title: title,
            description: description,
            actions: [action],
          ),
        ),
      );
    }

    testWidgets("should display the title", (WidgetTester tester) async {
      await buildWidget(tester);

      expect(find.text(title), findsOneWidget);
    });

    testWidgets("should display the description", (WidgetTester tester) async {
      await buildWidget(tester);

      expect(find.text(description), findsOneWidget);
    });

    testWidgets("should display the actions", (WidgetTester tester) async {
      await buildWidget(tester);

      expect(find.byWidget(action), findsOneWidget);
    });
  });

  group('showAlertDialog', () {
    testWidgets(
      'displays an alert dialog which can\'t be dismissed by clicking the barrier',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () {
                    showStopwatchAlertDialog(
                      context,
                      StopwatchAlertDialog(
                        title: title,
                        description: description,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.byType(StopwatchAlertDialog), findsOneWidget);

        await tester.tapAt(const Offset(5, 5)); // Outside the dialog.
        await tester.pumpAndSettle();
        expect(find.byType(StopwatchAlertDialog), findsOneWidget);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.byType(StopwatchAlertDialog), findsNothing);
      },
    );
  });
}
