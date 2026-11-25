import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/province.dart';
import '../models/city.dart';
import '../models/cost.dart';

class RajaOngkirService {
  static const String _apiKey = 'API_KEY';
  static const String _baseUrl =
      'https://rajaongkir.komerce.id/api/v1/destination';

  // Get all provinces
  Future<List<Province>> getProvinces() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/province'),
        headers: {'key': _apiKey},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;

        final results = decoded['data'] as List<dynamic>; // <-- pakai "data"

        return results
            .map((item) => Province.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load provinces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get cities by province
  Future<List<City>> getCities(String provinceId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/city/$provinceId'),
        headers: {'key': _apiKey},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final results = decoded['data'] as List<dynamic>;

        return results
            .map((json) => City.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Check shipping cost
  static const String _costUrl =
      'https://rajaongkir.komerce.id/api/v1/calculate/district/domestic-cost';

  Future<List<ShippingCost>> checkCost({
    required String origin,
    required String destination,
    required int weight,
    required String courier,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_costUrl),
        headers: {
          'key': _apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'origin': origin,
          'destination': destination,
          'weight': weight.toString(),
          // di docs bisa kirim banyak kurir pakai ":".
          // kirim satu kurir yang dipilih user.
          'courier': courier,
          // atau "lowest" untuk permintaan hanya harga terendah per kurir.
          'price': 'lowest', // atau 'lowest' sesuai kebutuhanmu
        },
      );

      print('Status code (cost): ${response.statusCode}');
      print('Body (cost): ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final results = decoded['data'] as List<dynamic>;

        // Filter supaya hanya opsi dari kurir yang dipilih
        final options = results
            .map((e) => ShippingCost.fromJson(e as Map<String, dynamic>))
            .where((opt) => opt.courierCode == courier)
            .toList();

        return options;
      } else {
        throw Exception('Failed to check cost: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
