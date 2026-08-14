import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';

void main() {
  group("StopwatchService", () {
    late StopwatchService stopwatchService;
    const int elapsedMilliseconds = 32;
    setUp(() {
      stopwatchService = StopwatchService();
    });

    test(
      "start should start the stopwatch and the elapsed time should grow",
      () async {
        expect(stopwatchService.elapsedTime, Duration.zero);

        stopwatchService.start();

        await Future.delayed(Duration(milliseconds: elapsedMilliseconds));

        expect(stopwatchService.elapsedTime, greaterThan(Duration.zero));

        stopwatchService.stop();
      },
    );

    test(
      "stop should pause the stopwatch and the elapsed time should freeze",
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

    test(
      "reset should reset the stopwatch and the elapsed time should reset",
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
}
