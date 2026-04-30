class Tour {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double advanceCash;
  final double miscAdvanceCash;

  Tour({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.advanceCash = 0.0,
    this.miscAdvanceCash = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'advanceCash': advanceCash,
      'miscAdvanceCash': miscAdvanceCash,
    };
  }

  factory Tour.fromMap(Map<String, dynamic> map) {
    return Tour(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      advanceCash: (map['advanceCash'] as num?)?.toDouble() ?? 0.0,
      miscAdvanceCash: (map['miscAdvanceCash'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
