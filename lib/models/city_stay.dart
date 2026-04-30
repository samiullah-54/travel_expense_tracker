class CityStay {
  final String id;
  final String tourId;
  final String cityName;
  final DateTime arrivalDate;
  final DateTime departureDate;

  CityStay({
    required this.id,
    required this.tourId,
    required this.cityName,
    required this.arrivalDate,
    required this.departureDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tourId': tourId,
      'cityName': cityName,
      'arrivalDate': arrivalDate.toIso8601String(),
      'departureDate': departureDate.toIso8601String(),
    };
  }

  factory CityStay.fromMap(Map<String, dynamic> map) {
    return CityStay(
      id: map['id'],
      tourId: map['tourId'],
      cityName: map['cityName'],
      arrivalDate: DateTime.parse(map['arrivalDate']),
      departureDate: DateTime.parse(map['departureDate']),
    );
  }
}
