class ShippingCost {
  final String courierName; // "Lion Parcel"
  final String courierCode; // "lion"
  final String service; // "JAGOPACK"
  final String description; // "Economy Service"
  final int cost; // 7000
  final String etd; // "1-4 day"

  ShippingCost({
    required this.courierName,
    required this.courierCode,
    required this.service,
    required this.description,
    required this.cost,
    required this.etd,
  });

  factory ShippingCost.fromJson(Map<String, dynamic> json) {
    return ShippingCost(
      courierName: json['name'] ?? '',
      courierCode: json['code'] ?? '',
      service: json['service'] ?? '',
      description: json['description'] ?? '',
      cost: (json['cost'] ?? 0) is int
          ? json['cost']
          : int.tryParse(json['cost'].toString()) ?? 0,
      etd: json['etd']?.toString() ?? '',
    );
  }

  String get formattedPrice {
    return 'Rp ${cost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String get label {
    final etdText = etd.isEmpty ? '-' : etd;
    return '$courierName - $service ($formattedPrice, $etdText)';
  }

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingCost &&
          runtimeType == other.runtimeType &&
          courierCode == other.courierCode &&
          service == other.service &&
          cost == other.cost;

  @override
  int get hashCode => courierCode.hashCode ^ service.hashCode ^ cost.hashCode;
}

// class CostDetail dihapus, tidak diperlukan lagi

class Courier {
  final String code;
  final String name;

  Courier({required this.code, required this.name});

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Courier &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
