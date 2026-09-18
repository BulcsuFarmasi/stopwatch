import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';

void main() {
  group("StopwatchService", () {
    late StopwatchService stopwatchService;
    const int elapsedMilliseconds = 32;
    setUp(() {
      stopwatchService = StopwatchService();
    });

    group("restoreElapsed", () {
      test("should add the given duration to the stopwatch time", () async {
        expect(stopwatchService.elapsedTime, Duration.zero);

        const int elapsedMilliseconds = 32;

        stopwatchService.restoreElapsed(
          Duration(milliseconds: elapsedMilliseconds),
        );

        expect(
          stopwatchService.elapsedTime,
          Duration(milliseconds: elapsedMilliseconds),
        );
      });
    });

    group("start", () {
      test(
        "should start the stopwatch and the elapsed time should grow",
        () async {
          expect(stopwatchService.elapsedTime, Duration.zero);

          stopwatchService.start();

          await Future.delayed(Duration(milliseconds: elapsedMilliseconds));

          expect(stopwatchService.elapsedTime, greaterThan(Duration.zero));

          stopwatchService.stop();
        },
      );
    });

    group("stop", () {
      test(
        "should pause the stopwatch and the elapsed time should freeze",
        () async {
          expect(stopwatchService.elapsedTime, Duration.zero);

          stopwatchService.start();

          await Future.delayed(Duration(milliseconds: elapsedMilliseconds));

          expect(stopwatchService.elapsedTime, greaterThan(Duration.zero));

          stopwatchService.stop();

          final Duration elapsedTime = stopwatchService.elapsedTime;

          await Future.delayed(Duration(milliseconds: elapsedMilliseconds));

          expect(elapsedTime, stopwatchService.elapsedTime);
        },
      );
    });

    group("reset", () {
      test(
        "should reset the stopwatch and the elapsed time should reset",
        () async {
          expect(stopwatchService.elapsedTime, Duration.zero);

          stopwatchService.start();

          await Future.delayed(Duration(milliseconds: elapsedMilliseconds));

          expect(stopwatchService.elapsedTime, greaterThan(Duration.zero));

          stopwatchService.reset();

          expect(stopwatchService.elapsedTime, Duration.zero);
          await Future<void>.delayed(
            const Duration(milliseconds: elapsedMilliseconds),
          );

          expect(stopwatchService.elapsedTime, Duration.zero);

          stopwatchService.stop();
        },
      );
    });
  });
}
