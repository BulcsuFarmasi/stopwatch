class Lap {
  final Duration total;
  final Duration split;
  final int number;

  const new({required this.total, required this.split, required this.number});

  Map<String, dynamic> toJson() => {
    "totalMicroseconds": total.inMicroseconds,
    "splitMicroseconds": split.inMicroseconds,
    "number": number,
  };

  factory fromJson(Map<String, dynamic> json) {
    final Object? totalMicroseconds = json['totalMicroseconds'];
    final Object? splitMicroseconds = json['splitMicroseconds'];
    final Object? number = json['number'];

    if (totalMicroseconds is! int || totalMicroseconds < 0) {
      throw const FormatException("Total time must be a non-negative integer");
    }

    if (splitMicroseconds is! int || splitMicroseconds < 0) {
      throw const FormatException("Split time must be a non-negative integer");
    }

    if (splitMicroseconds > totalMicroseconds) {
      throw const FormatException("Split cannot be larger than the total");
    }

    if (number is! int || number < 1) {
      throw const FormatException("Number must be a positive integer");
    }

    return Lap(
      total: Duration(microseconds: totalMicroseconds),
      split: Duration(microseconds: splitMicroseconds),
      number: number,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Lap &&
            total == other.total &&
            split == other.split &&
            number == other.number;
  }

  @override
  int get hashCode => Object.hash(total, split, number);
}
