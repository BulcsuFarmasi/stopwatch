import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_refresh_scheduler.dart';

void main() {
  group("StopwatchRefreshScheduler", () {
    late StopwatchRefreshScheduler stopwatchRefreshScheduler;

    setUp(() {
      stopwatchRefreshScheduler = StopwatchRefreshScheduler();
    });

    group("startTimer", () {
      test("should start a timer when refresh is active", () {
        fakeAsync((FakeAsync async) {
          bool callbackCalled = false;
          stopwatchRefreshScheduler.startRefresh();

          stopwatchRefreshScheduler.startTimer(() {
            callbackCalled = true;
          });

          async.elapse(Duration(milliseconds: 16));

          expect(callbackCalled, true);
        });
      });

      test("should not start a timer when refresh is not active", () {
        fakeAsync((FakeAsync async) {
          bool callbackCalled = false;
          stopwatchRefreshScheduler.stopRefresh();

          stopwatchRefreshScheduler.startTimer(() {
            callbackCalled = true;
          });

          async.elapse(Duration(milliseconds: 16));

          expect(callbackCalled, false);
        });
      });

      test("should not start a timer when another time is active", () {
        fakeAsync((FakeAsync async) {
          bool firstCallbackCalled = false;
          bool secondCallBackCalled = false;

          stopwatchRefreshScheduler.startRefresh();

          stopwatchRefreshScheduler.startTimer(() {
            firstCallbackCalled = true;
          });

          stopwatchRefreshScheduler.startTimer(() {
            secondCallBackCalled = true;
          });

          async.elapse(Duration(milliseconds: 16));

          expect(firstCallbackCalled, true);
          expect(secondCallBackCalled, false);
        });
      });

      test("should not start a timer when another time is active and refresh is disabled", () {
        fakeAsync((FakeAsync async) {
          bool firstCallbackCalled = false;
          bool secondCallBackCalled = false;

          stopwatchRefreshScheduler.startRefresh();

          stopwatchRefreshScheduler.startTimer(() {
            firstCallbackCalled = true;
          });

          stopwatchRefreshScheduler.stopRefresh();

          stopwatchRefreshScheduler.startTimer(() {
            secondCallBackCalled = true;
          });

          async.elapse(Duration(milliseconds: 16));

          expect(firstCallbackCalled, true);
          expect(secondCallBackCalled, false);
        });
      });
    });

    group('stopTimer', () {
      test('cancels the timer', () {
        fakeAsync((FakeAsync async) {
          int tickCount = 0;
          stopwatchRefreshScheduler.startRefresh();
          stopwatchRefreshScheduler.startTimer(() => tickCount++);

          async.elapse(const Duration(milliseconds: 16));
          expect(tickCount, 1);

          stopwatchRefreshScheduler.stopTimer();
          async.elapse(const Duration(milliseconds: 16));
          expect(tickCount, 1);
        });
      });
    });
  });
}
