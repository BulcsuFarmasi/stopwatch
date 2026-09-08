// typedef Lap = ({Duration total, Duration split, int number});

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

  factory fromJson(Map<String, dynamic> json) => Lap(
    total: Duration(microseconds: json["totalMicroseconds"]),
    split: Duration(microseconds: json["splitMicroseconds"]),
    number: json["number"],
  );

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
