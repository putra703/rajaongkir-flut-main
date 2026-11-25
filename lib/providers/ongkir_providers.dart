import 'package:flutter/material.dart';
import '../models/province.dart';
import '../models/city.dart';
import '../models/cost.dart';
import '../services/service_rajaongkir.dart';

class OngkirProvider with ChangeNotifier {
  final RajaOngkirService _service = RajaOngkirService();

  // ================================
  // DATA LISTS
  // ================================
  List<Province> _provinces = [];
  List<City> _originCities = [];
  List<City> _destinationCities = [];
  List<ShippingCost> _costs = [];

  // ================================
  // SELECTED VALUES
  // ================================
  Province? _selectedOriginProvince;
  City? _selectedOriginCity;
  Province? _selectedDestProvince;
  City? _selectedDestCity;
  Courier? _selectedCourier;
  int _weight = 1000;

  // Paket pengiriman terpilih
  ShippingCost? _selectedCost;

  // ================================
  // LOADING STATES
  // ================================
  bool _isLoadingProvinces = false;
  bool _isLoadingOriginCities = false;
  bool _isLoadingDestCities = false;
  bool _isLoadingCosts = false;

  // ================================
  // GETTERS
  // ================================
  List<Province> get provinces => _provinces;
  List<City> get originCities => _originCities;
  List<City> get destinationCities => _destinationCities;
  List<ShippingCost> get costs => _costs;

  Province? get selectedOriginProvince => _selectedOriginProvince;
  City? get selectedOriginCity => _selectedOriginCity;
  Province? get selectedDestProvince => _selectedDestProvince;
  City? get selectedDestCity => _selectedDestCity;
  Courier? get selectedCourier => _selectedCourier;
  int get weight => _weight;

  ShippingCost? get selectedCost => _selectedCost;

  bool get isLoadingProvinces => _isLoadingProvinces;
  bool get isLoadingOriginCities => _isLoadingOriginCities;
  bool get isLoadingDestCities => _isLoadingDestCities;
  bool get isLoadingCosts => _isLoadingCosts;

  // ================================
  // AVAILABLE COURIERS (UNTUK DROPDOWN)
  // ================================
  // Sesuaikan dengan daftar kurir yang didukung endpoint calculate cost.
  final List<Courier> couriers = [
    Courier(code: 'jne', name: 'JNE'),
    Courier(code: 'pos', name: 'POS Indonesia'),
    Courier(code: 'tiki', name: 'TIKI'),
    Courier(code: 'lion', name: 'Lion Parcel'),
    Courier(code: 'anteraja', name: 'AnterAja'),
    Courier(code: 'sicepat', name: 'SiCepat'),
    Courier(code: 'jnt', name: 'J&T'),
  ];

  // ================================
  // FETCH PROVINCES
  // ================================
  Future<void> fetchProvinces() async {
    _isLoadingProvinces = true;
    notifyListeners();

    try {
      _provinces = await _service.getProvinces();
    } catch (e) {
      print('Error fetching provinces: $e');
      _provinces = [];
    } finally {
      _isLoadingProvinces = false;
      notifyListeners();
    }
  }

  // ================================
  // FETCH ORIGIN CITIES
  // ================================
  Future<void> fetchOriginCities(String provinceId) async {
    _isLoadingOriginCities = true;
    notifyListeners();

    try {
      _originCities = await _service.getCities(provinceId);
    } catch (e) {
      print('Error fetching origin cities: $e');
      _originCities = [];
    } finally {
      _isLoadingOriginCities = false;
      notifyListeners();
    }
  }

  // ================================
  // FETCH DESTINATION CITIES
  // ================================
  Future<void> fetchDestinationCities(String provinceId) async {
    _isLoadingDestCities = true;
    notifyListeners();

    try {
      _destinationCities = await _service.getCities(provinceId);
    } catch (e) {
      print('Error fetching destination cities: $e');
      _destinationCities = [];
    } finally {
      _isLoadingDestCities = false;
      notifyListeners();
    }
  }

  // ================================
  // CHECK SHIPPING COST
  // ================================
  Future<String?> checkShippingCost() async {
    if (_selectedOriginCity == null ||
        _selectedDestCity == null ||
        _selectedCourier == null) {
      return 'Mohon lengkapi provinsi, kota asal, kota tujuan, dan kurir.';
    }

    _isLoadingCosts = true;
    _costs = [];
    _selectedCost = null;
    notifyListeners();

    try {
      _costs = await _service.checkCost(
        origin: _selectedOriginCity!.id, // id district asal
        destination: _selectedDestCity!.id, // id district tujuan
        weight: _weight,
        courier: _selectedCourier!.code,
      );

      if (_costs.isNotEmpty) {
        _selectedCost = _costs.first;
      }

      return null; // sukses, tidak ada error
    } catch (e) {
      print('Error checkShippingCost: $e');
      return 'Error: $e';
    } finally {
      _isLoadingCosts = false;
      notifyListeners();
    }
  }

  // ================================
  // SETTERS / UPDATERS
  // ================================
  void setOriginProvince(Province? province) {
    _selectedOriginProvince = province;
    _selectedOriginCity = null;
    _originCities = [];
    notifyListeners();

    if (province != null) {
      fetchOriginCities(province.provinceId);
    }
  }

  void setOriginCity(City? city) {
    _selectedOriginCity = city;
    notifyListeners();
  }

  void setDestProvince(Province? province) {
    _selectedDestProvince = province;
    _selectedDestCity = null;
    _destinationCities = [];
    notifyListeners();

    if (province != null) {
      fetchDestinationCities(province.provinceId);
    }
  }

  void setDestCity(City? city) {
    _selectedDestCity = city;
    notifyListeners();
  }

  void setCourier(Courier? courier) {
    _selectedCourier = courier;
    notifyListeners();
  }

  void setWeight(int weight) {
    // jaga-jaga kalau user isi 0 atau negatif
    _weight = weight <= 0 ? 1 : weight;
    notifyListeners();
  }

  void setSelectedCost(ShippingCost? cost) {
    _selectedCost = cost;
    notifyListeners();
  }

  // ================================
  // RESET SEMUA FORM
  // ================================
  void reset() {
    _selectedOriginProvince = null;
    _selectedOriginCity = null;
    _selectedDestProvince = null;
    _selectedDestCity = null;
    _selectedCourier = null;
    _selectedCost = null;

    _weight = 1000;
    _originCities = [];
    _destinationCities = [];
    _costs = [];

    notifyListeners();
  }
}
