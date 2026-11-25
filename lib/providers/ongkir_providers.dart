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
  List<City> _originDistricts = [];
  List<City> _destinationCities = [];
  List<City> _destinationDistricts = [];
  List<ShippingCost> _costs = [];

  // ================================
  // SELECTED VALUES
  // ================================
  Province? _selectedOriginProvince;
  City? _selectedOriginCity;
  City? _selectedOriginDistrict;
  Province? _selectedDestProvince;
  City? _selectedDestCity;
  City? _selectedDestDistrict;
  Courier? _selectedCourier;
  int _weight = 1000;

  // Paket pengiriman terpilih
  ShippingCost? _selectedCost;

  // ================================
  // LOADING STATES
  // ================================
  bool _isLoadingProvinces = false;
  bool _isLoadingOriginCities = false;
  bool _isLoadingOriginDistricts = false;
  bool _isLoadingDestCities = false;
  bool _isLoadingDestDistricts = false;
  bool _isLoadingCosts = false;
  String? _errorMessage;

  // ================================
  // GETTERS
  // ================================
  List<Province> get provinces => _provinces;
  List<City> get originCities => _originCities;
  List<City> get originDistricts => _originDistricts;
  List<City> get destinationCities => _destinationCities;
  List<City> get destinationDistricts => _destinationDistricts;
  List<ShippingCost> get costs => _costs;

  Province? get selectedOriginProvince => _selectedOriginProvince;
  City? get selectedOriginCity => _selectedOriginCity;
  City? get selectedOriginDistrict => _selectedOriginDistrict;
  Province? get selectedDestProvince => _selectedDestProvince;
  City? get selectedDestCity => _selectedDestCity;
  City? get selectedDestDistrict => _selectedDestDistrict;
  Courier? get selectedCourier => _selectedCourier;
  int get weight => _weight;

  ShippingCost? get selectedCost => _selectedCost;

  bool get isLoadingProvinces => _isLoadingProvinces;
  bool get isLoadingOriginCities => _isLoadingOriginCities;
  bool get isLoadingOriginDistricts => _isLoadingOriginDistricts;
  bool get isLoadingDestCities => _isLoadingDestCities;
  bool get isLoadingDestDistricts => _isLoadingDestDistricts;
  bool get isLoadingCosts => _isLoadingCosts;
  String? get errorMessage => _errorMessage;

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
      _errorMessage = null;
      _provinces = await _service.getProvinces();
    } catch (e) {
      print('Error fetching provinces: $e');
      _errorMessage = e.toString();
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
      _errorMessage = null;
      _originCities = await _service.getCities(provinceId);
    } catch (e) {
      print('Error fetching origin cities: $e');
      _errorMessage = e.toString();
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
      _errorMessage = null;
      _destinationCities = await _service.getCities(provinceId);
    } catch (e) {
      print('Error fetching destination cities: $e');
      _errorMessage = e.toString();
      _destinationCities = [];
    } finally {
      _isLoadingDestCities = false;
      notifyListeners();
    }
  }

  Future<void> fetchOriginDistricts(String cityId) async {
    _isLoadingOriginDistricts = true;
    notifyListeners();
    try {
      _errorMessage = null;
      _originDistricts = await _service.getDistricts(cityId);
    } catch (e) {
      print('Error fetching origin districts: $e');
      _errorMessage = e.toString();
      _originDistricts = [];
    } finally {
      _isLoadingOriginDistricts = false;
      notifyListeners();
    }
  }

  Future<void> fetchDestinationDistricts(String cityId) async {
    _isLoadingDestDistricts = true;
    notifyListeners();
    try {
      _errorMessage = null;
      _destinationDistricts = await _service.getDistricts(cityId);
    } catch (e) {
      print('Error fetching destination districts: $e');
      _errorMessage = e.toString();
      _destinationDistricts = [];
    } finally {
      _isLoadingDestDistricts = false;
      notifyListeners();
    }
  }

  // ================================
  // CHECK SHIPPING COST
  // ================================
  Future<String?> checkShippingCost() async {
    if (_selectedOriginDistrict == null ||
        _selectedDestDistrict == null ||
        _selectedCourier == null) {
      return 'Mohon lengkapi provinsi, kota, kecamatan asal dan tujuan, serta kurir.';
    }

    _isLoadingCosts = true;
    _costs = [];
    _selectedCost = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _costs = await _service.checkCost(
        origin: _selectedOriginDistrict!.id,
        destination: _selectedDestDistrict!.id,
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
    _selectedOriginDistrict = null;
    _originCities = [];
    _originDistricts = [];
    notifyListeners();

    if (province != null) {
      fetchOriginCities(province.provinceId);
    }
  }

  void setOriginCity(City? city) {
    _selectedOriginCity = city;
    _selectedOriginDistrict = null;
    _originDistricts = [];
    notifyListeners();
    if (city != null) fetchOriginDistricts(city.id);
  }

  void setDestProvince(Province? province) {
    _selectedDestProvince = province;
    _selectedDestCity = null;
    _selectedDestDistrict = null;
    _destinationCities = [];
    _destinationDistricts = [];
    notifyListeners();

    if (province != null) {
      fetchDestinationCities(province.provinceId);
    }
  }

  void setDestCity(City? city) {
    _selectedDestCity = city;
    _selectedDestDistrict = null;
    _destinationDistricts = [];
    notifyListeners();
    if (city != null) fetchDestinationDistricts(city.id);
  }

  void setOriginDistrict(City? district) {
    _selectedOriginDistrict = district;
    notifyListeners();
  }

  void setDestDistrict(City? district) {
    _selectedDestDistrict = district;
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
    _selectedOriginDistrict = null;
    _selectedDestProvince = null;
    _selectedDestCity = null;
    _selectedDestDistrict = null;
    _selectedCourier = null;
    _selectedCost = null;

    _weight = 1000;
    _originCities = [];
    _originDistricts = [];
    _destinationCities = [];
    _destinationDistricts = [];
    _costs = [];

    notifyListeners();
  }
}
