class Expense {
  final String id;
  final String cityStayId;
  final double amount;
  final String category; // e.g. "Fuel", "Tolls", "Hotel", "Food", "Ironing", "Other"
  final String description;
  final DateTime date;
  final String? imagePath;
  final String? deductedFrom; // 'advance', 'misc', or null

  Expense({
    required this.id,
    required this.cityStayId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.imagePath,
    this.deductedFrom,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityStayId': cityStayId,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
      'deductedFrom': deductedFrom,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      cityStayId: map['cityStayId'],
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      imagePath: map['imagePath'],
      deductedFrom: map['deductedFrom'],
    );
  }
}
