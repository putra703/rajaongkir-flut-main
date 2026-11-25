class Province {
  final String provinceId;
  final String province;

  Province({required this.provinceId, required this.province});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      provinceId: json['id'].toString(), // <-- dari field "id"
      province: json['name'], // <-- dari field "name"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': provinceId, // kalau nanti perlu kirim balik ke API
      'name': province,
    };
  }

  @override
  String toString() => province;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Province &&
          runtimeType == other.runtimeType &&
          provinceId == other.provinceId;

  @override
  int get hashCode => provinceId.hashCode;
}
