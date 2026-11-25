class City {
  final String id;
  final String name;
  final String zipCode;

  City({required this.id, required this.name, required this.zipCode});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'].toString(),
      name: json['name'],
      zipCode: json['zip_code']?.toString() ?? '',
    );
  }

  String get fullName => name; // sebelumnya type + cityName → tidak ada lagi

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is City && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
