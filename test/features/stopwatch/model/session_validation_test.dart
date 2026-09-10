import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/model/stored_stopwatch_session.dart';

Map<String, dynamic> lapJson({
  int number = 1,
  int total = 50,
  int split = 50,
}) => {
  'number': number,
  'totalMicroseconds': total,
  'splitMicroseconds': split,
};

Map<String, dynamic> sessionJson() => {
  'elapsedMicroseconds': 100,
  'savedAtMicroseconds': 1000,
  'status': 'paused',
  'schemaVersion': currentSchemaVersion,
  'laps': [
    lapJson(number: 3, total: 100, split: 0),
    lapJson(number: 2, total: 100, split: 50),
    lapJson(),
  ],
};

void main() {
  group('Lap validation', () {
    test('accepts a zero-duration lap', () {
      final Lap lap = Lap.fromJson(lapJson(total: 0, split: 0));
      expect(lap.total, Duration.zero);
      expect(lap.number, 1);
    });

    final invalidFields = <String, List<Object?>>{
      'number': [null, '1', 0, -1],
      'totalMicroseconds': [null, '50', -1],
      'splitMicroseconds': [null, '50', -1, 51],
    };
    for (final field in invalidFields.entries) {
      for (final value in field.value) {
        test('rejects ${field.key}=$value', () {
          final json = lapJson()..[field.key] = value;
          expect(() => Lap.fromJson(json), throwsFormatException);
        });
      }
    }
  });

  group('Session validation', () {
    test('round-trips valid laps including equal consecutive totals', () {
      final json = sessionJson();
      expect(StoredStopwatchSession.fromJson(json).toJson(), json);
    });

    test('accepts a running session with no laps after clearing', () {
      final json = sessionJson()
        ..['status'] = 'running'
        ..['laps'] = <Object?>[];
      expect(StoredStopwatchSession.fromJson(json).laps, isEmpty);
    });

    test('accepts a zero-duration initial session', () {
      final json = sessionJson()
        ..['status'] = 'initial'
        ..['elapsedMicroseconds'] = 0
        ..['laps'] = <Object?>[];
      expect(StoredStopwatchSession.fromJson(json).elapsed, Duration.zero);
    });

    final invalidFields = <String, List<Object?>>{
      'elapsedMicroseconds': [null, '100', -1, 99],
      'savedAtMicroseconds': [null, '1000', -1, 8640000000000000001],
      'status': [null, 1, 'unknown', 'initial'],
      'schemaVersion': [null, '1', 0, -1],
      'laps': [
        null,
        {},
        [null],
        ['lap'],
      ],
    };
    for (final field in invalidFields.entries) {
      for (final value in field.value) {
        test('rejects ${field.key}=$value', () {
          final json = sessionJson()..[field.key] = value;
          expect(
            () => StoredStopwatchSession.fromJson(json),
            throwsFormatException,
          );
        });
      }
    }

    final invalidLaps = <String, List<Map<String, dynamic>>>{
      'nonconsecutive numbering': [lapJson(number: 2)],
      'ascending totals': [lapJson(number: 2, total: 40, split: 0), lapJson()],
      'incorrect split': [lapJson(number: 2, total: 100, split: 40), lapJson()],
      'incorrect first split': [lapJson(split: 40)],
    };
    for (final entry in invalidLaps.entries) {
      test('rejects ${entry.key}', () {
        final json = sessionJson()..['laps'] = entry.value;
        expect(
          () => StoredStopwatchSession.fromJson(json),
          throwsFormatException,
        );
      });
    }
  });
}
