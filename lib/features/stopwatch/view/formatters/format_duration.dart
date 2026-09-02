String formatDuration(Duration duration) {
  final DurationParts durationParts = splitDuration(duration);

  return '${durationParts.minutes.toString().padLeft(2, '0')}:'
      '${durationParts.seconds.toString().padLeft(2, '0')}.'
      '${durationParts.milliseconds.toString().padLeft(3, '0')}';
}

DurationParts splitDuration(Duration duration) {
  return (
    minutes: duration.inMinutes,
    seconds: duration.inSeconds.remainder(60),
    milliseconds: duration.inMilliseconds.remainder(1000),
  );
}

typedef DurationParts = ({int minutes, int seconds, int milliseconds});
