import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';

void main() {
  group("Lap", () {
    Map<String, dynamic> lapJson({
      int number = 1,
      int total = 32,
      int split = 32,
    }) => {
      'number': number,
      'totalMicroseconds': total,
      'splitMicroseconds': split,
    };

    group('toJson', () {
      test('successfully converts Lap to json', () {
        expect(Lap.fromJson(lapJson()).toJson(), lapJson());
      });
    });

    group('fromJson', () {
      test('creates a zero duration lap', () {
        final Lap lap = Lap.fromJson(lapJson(total: 0, split: 0));
        expect(lap.total, Duration.zero);
        expect(lap.number, 1);
        expect(lap.split, Duration.zero);
      });

      test('creates lap with duration', () {
        final Lap lap = Lap.fromJson(lapJson());
        expect(lap.total, Duration(microseconds: 32));
        expect(lap.number, 1);
        expect(lap.split, Duration(microseconds: 32));
      });

      final invalidFields = <String, List<Object?>>{
        'number': [null, '1', 0, -1],
        'totalMicroseconds': [null, '32', -1],
        'splitMicroseconds': [null, '32', -1, 33],
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

    group("hashCode", () {
      test("returns with hash of the fields", () {
        final Lap lap = Lap.fromJson(lapJson());
        expect(lap.hashCode, Object.hash(lap.total, lap.split, lap.number));
      });
    });

    group("==", () {
      test("return with true if the lap is the same", () {
        final Lap lap = Lap.fromJson(lapJson());
        final Lap otherLap = Lap.fromJson(lapJson());
        expect(lap == otherLap, isTrue);
      });
      test("return with false if the other is not a lap", () {
        final Lap lap = Lap.fromJson(lapJson());
        // ignore: unrelated_type_equality_checks
        expect(lap == lapJson(), isFalse);
      });
      test("return with false if not have the same number", () {
        final Lap lap = Lap.fromJson(lapJson());
        final Lap otherLap = Lap.fromJson(lapJson(number: 2));
        expect(lap == otherLap, isFalse);
      });
      test("return with false if not have the same split", () {
        final Lap lap = Lap.fromJson(lapJson());
        final Lap otherLap = Lap.fromJson(lapJson(split: 16));
        expect(lap == otherLap, isFalse);
      });
      test("return with false if not have the same total", () {
        final Lap lap = Lap.fromJson(lapJson());
        final Lap otherLap = Lap.fromJson(lapJson(total: 128));
        expect(lap == otherLap, isFalse);
      });
    });
  });
}
