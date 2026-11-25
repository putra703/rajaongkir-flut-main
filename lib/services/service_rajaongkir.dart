import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/province.dart';
import '../models/city.dart';
import '../models/cost.dart';

class RajaOngkirService {
  static const String _apiKey = String.fromEnvironment('RAJAONGKIR_API_KEY');
  static const String _apiBaseUrl = 'https://rajaongkir.komerce.id/api/v1';

  Uri _uri(String path) => kIsWeb
      ? Uri.parse('http://localhost:8080/api/$path')
      : Uri.parse('$_apiBaseUrl/$path');

  Map<String, String> get _headers => kIsWeb
      ? const {}
      : {'key': _requireApiKey()};

  // Get all provinces
  Future<List<Province>> getProvinces() async {
    try {
      final response = await http.get(
        _uri('destination/province'),
        headers: _headers,
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
        _uri('destination/city/$provinceId'),
        headers: _headers,
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

  // Get districts by city. The district ID is required by the cost endpoint.
  Future<List<City>> getDistricts(String cityId) async {
    try {
      final response = await http.get(
        _uri('destination/district/$cityId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final results = decoded['data'] as List<dynamic>;
        return results
            .map((item) => City.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Gagal memuat kecamatan: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Check shipping cost
  Future<List<ShippingCost>> checkCost({
    required String origin,
    required String destination,
    required int weight,
    required String courier,
  }) async {
    try {
      final response = await http.post(
        _uri('calculate/district/domestic-cost'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          ..._headers,
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
        throw Exception(
          'Gagal mengecek ongkir (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  String _requireApiKey() {
    if (_apiKey.isEmpty || _apiKey == 'API_KEY') {
      throw Exception(
        'API key belum diatur. Jalankan dengan --dart-define=RAJAONGKIR_API_KEY=API_KEY_ANDA.',
      );
    }
    return _apiKey;
  }
}
