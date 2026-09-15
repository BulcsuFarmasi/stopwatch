import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';

class MockStopwatchNotifier extends AsyncNotifier<StopwatchState>
    with Mock
    implements StopwatchNotifier {}
