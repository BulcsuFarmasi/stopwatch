import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/shared/widgets/app_lifecycle_observer.dart';

void main() {
  group("AppLifeCycleObserver", () {
    Future<void> buildWidget({
      required WidgetTester tester,
      VoidCallback? onVisible,
      VoidCallback? onHidden,
    }) async {
      await tester.pumpWidget(
        AppLifecycleObserver(
          onVisible: onVisible ?? () {},
          onHidden: onHidden ?? () {},
          child: SizedBox(),
        ),
      );
    }

    group("visible", () {
      testWidgets("should be triggered by resumed event", (
        WidgetTester tester,
      ) async {
        bool visibleTrigged = false;

        await buildWidget(
          tester: tester,
          onVisible: () {
            visibleTrigged = true;
          },
        );

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );

        expect(visibleTrigged, true);
      });

      testWidgets("should be triggered by inactive event", (
        WidgetTester tester,
      ) async {
        bool visibleTrigged = false;

        await buildWidget(
          tester: tester,
          onVisible: () {
            visibleTrigged = true;
          },
        );

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );

        expect(visibleTrigged, true);
      });
    });

    group("hidden", () {
      testWidgets("should be triggered by hidden event", (
        WidgetTester tester,
      ) async {
        bool hiddenTrigged = false;

        await buildWidget(
          tester: tester,
          onHidden: () {
            hiddenTrigged = true;
          },
        );

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);

        expect(hiddenTrigged, true);
      });

      testWidgets("should be triggered by paused event", (
        WidgetTester tester,
      ) async {
        bool hiddenTrigged = false;

        await buildWidget(
          tester: tester,
          onHidden: () {
            hiddenTrigged = true;
          },
        );

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

        expect(hiddenTrigged, true);
      });

      testWidgets("should be triggered by detached event", (
        WidgetTester tester,
      ) async {
        bool hiddenTrigged = false;

        await buildWidget(
          tester: tester,
          onHidden: () {
            hiddenTrigged = true;
          },
        );

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.detached,
        );

        expect(hiddenTrigged, true);
      });
    });
  });
}
