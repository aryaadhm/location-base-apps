import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/facility.dart';
import '../models/region.dart';
import '../services/facility_repository.dart';
import '../services/region_repository.dart';

class AppController extends ChangeNotifier {
  AppController({
    RegionRepository? regionRepository,
    FacilityRepository? facilityRepository,
  }) : _regions = regionRepository ?? RegionRepository(),
       _facilities = facilityRepository ?? FacilityRepository();

  static const defaultCenter = LatLng(-6.9175, 107.6191);
  final RegionRepository _regions;
  final FacilityRepository _facilities;
  StreamSubscription<Position>? _positionSubscription;
  final Map<String, bool> _geofenceStates = {};

  List<Region> provinces = [];
  List<Region> regencies = [];
  List<Region> districts = [];
  List<Region> villages = [];
  Region? selectedProvince;
  Region? selectedRegency;
  Region? selectedDistrict;
  Region? selectedVillage;
  List<Facility> facilities = [];
  Position? currentPosition;
  LatLng searchCenter = defaultCenter;
  int searchRadiusMeters = 10000;
  bool loadingRegions = false;
  bool loadingFacilities = false;
  bool locationEnabled = false;
  bool usingCachedFacilities = false;
  bool geofenceEnabled = true;
  String? regionError;
  String? facilityError;
  String? locationMessage;
  String? geofenceMessage;

  String get locationLabel {
    if (selectedVillage != null) {
      return '${selectedVillage!.name}, ${selectedRegency?.name ?? ''}';
    }
    if (currentPosition != null) return 'Lokasi saya';
    return 'Sekitar Kota Bandung';
  }

  Future<void> initialize() async {
    await Future.wait([loadProvinces(), _restoreSettings(), enableLocation()]);
    await searchFacilities();
  }

  Future<void> _restoreSettings() async {
    final prefs = await SharedPreferences.getInstance();
    geofenceEnabled = prefs.getBool('geofenceEnabled') ?? true;
    searchRadiusMeters = prefs.getInt('searchRadiusMeters') ?? 10000;
  }

  Future<void> loadProvinces() async {
    loadingRegions = true;
    regionError = null;
    notifyListeners();
    try {
      provinces = await _regions.provinces();
    } catch (_) {
      regionError =
          'Daftar wilayah belum dapat dimuat. Periksa koneksi internet.';
    } finally {
      loadingRegions = false;
      notifyListeners();
    }
  }

  Future<void> selectProvince(Region? value) async {
    selectedProvince = value;
    selectedRegency = null;
    selectedDistrict = null;
    selectedVillage = null;
    regencies = [];
    districts = [];
    villages = [];
    if (value == null) return notifyListeners();
    await _loadRegions(
      () => _regions.regencies(value.id),
      (items) => regencies = items,
    );
  }

  Future<void> selectRegency(Region? value) async {
    selectedRegency = value;
    selectedDistrict = null;
    selectedVillage = null;
    districts = [];
    villages = [];
    if (value == null) return notifyListeners();
    await _loadRegions(
      () => _regions.districts(value.id),
      (items) => districts = items,
    );
  }

  Future<void> selectDistrict(Region? value) async {
    selectedDistrict = value;
    selectedVillage = null;
    villages = [];
    if (value == null) return notifyListeners();
    await _loadRegions(
      () => _regions.villages(value.id),
      (items) => villages = items,
    );
  }

  Future<void> selectVillage(Region? value) async {
    selectedVillage = value;
    if (value?.hasCoordinates == true) {
      searchCenter = LatLng(value!.latitude!, value.longitude!);
    }
    notifyListeners();
  }

  Future<void> _loadRegions(
    Future<List<Region>> Function() request,
    void Function(List<Region>) assign,
  ) async {
    loadingRegions = true;
    regionError = null;
    notifyListeners();
    try {
      assign(await request());
    } catch (_) {
      regionError = 'Wilayah berikutnya belum dapat dimuat.';
    } finally {
      loadingRegions = false;
      notifyListeners();
    }
  }

  Future<void> applySelectedVillage() async {
    final village = selectedVillage;
    if (village == null) return;
    if (!village.hasCoordinates) {
      regionError =
          'Koordinat desa ini belum tersedia. Gunakan lokasi perangkat.';
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastVillageName', village.name);
    await searchFacilities();
  }

  Future<void> setRadius(int meters) async {
    searchRadiusMeters = meters;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('searchRadiusMeters', meters);
    notifyListeners();
    await searchFacilities();
  }

  Future<void> searchFacilities() async {
    loadingFacilities = true;
    facilityError = null;
    usingCachedFacilities = false;
    notifyListeners();
    try {
      final result = await _facilities.nearby(
        center: searchCenter,
        radiusMeters: searchRadiusMeters,
      );
      facilities = _withDistances(result.facilities);
      usingCachedFacilities = result.fromCache;
      _geofenceStates.clear();
      if (facilities.isEmpty) {
        facilityError =
            'Belum ada fasilitas yang dipetakan dalam radius ${searchRadiusMeters ~/ 1000} km.';
      }
    } catch (_) {
      facilities = _withDistances(_demoFacilities);
      facilityError = 'Layanan publik sedang tidak tersedia. Menampilkan data demo Bandung.';
    } finally {
      loadingFacilities = false;
      notifyListeners();
    }
  }

  List<Facility> _withDistances(List<Facility> items) {
    final origin = currentPosition == null
        ? searchCenter
        : LatLng(currentPosition!.latitude, currentPosition!.longitude);
    final result = items
        .map(
          (item) => item.copyWith(
            distanceMeters: Geolocator.distanceBetween(
              origin.latitude,
              origin.longitude,
              item.point.latitude,
              item.point.longitude,
            ),
          ),
        )
        .toList();
    result.sort(
      (a, b) => (a.distanceMeters ?? double.infinity).compareTo(
        b.distanceMeters ?? double.infinity,
      ),
    );
    return result;
  }

  Future<void> enableLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        locationMessage =
            'Aktifkan layanan lokasi untuk melihat jarak dari posisi Anda.';
        notifyListeners();
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        locationMessage =
            'Izin lokasi ditolak. Pencarian wilayah tetap dapat digunakan.';
        notifyListeners();
        return;
      }
      locationEnabled = true;
      final position = await Geolocator.getCurrentPosition();
      _onPosition(position, recenter: selectedVillage == null);
      await _positionSubscription?.cancel();
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 25,
        ),
      ).listen(_onPosition);
    } catch (_) {
      locationMessage = 'Lokasi perangkat belum dapat dibaca.';
      notifyListeners();
    }
  }

  void _onPosition(Position position, {bool recenter = false}) {
    currentPosition = position;
    if (recenter) searchCenter = LatLng(position.latitude, position.longitude);
    facilities = _withDistances(facilities);
    if (geofenceEnabled) _evaluateGeofences(position);
    notifyListeners();
  }

  void _evaluateGeofences(Position position) {
    for (final facility in facilities.take(30)) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        facility.point.latitude,
        facility.point.longitude,
      );
      final previous = _geofenceStates[facility.id];
      final inside = previous == true ? distance <= 250 : distance <= 200;
      if (previous != null && previous != inside) {
        geofenceMessage = inside
            ? 'Anda memasuki area ${facility.name}.'
            : 'Anda meninggalkan area ${facility.name}.';
      }
      _geofenceStates[facility.id] = inside;
    }
  }

  Future<void> setGeofenceEnabled(bool value) async {
    geofenceEnabled = value;
    if (!value) _geofenceStates.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('geofenceEnabled', value);
    notifyListeners();
  }

  void simulateGeofence() {
    geofenceMessage =
        'Simulasi: Anda memasuki area fasilitas kesehatan terdekat.';
    notifyListeners();
  }

  void clearGeofenceMessage() => geofenceMessage = null;

  Future<void> setForegroundActive(bool active) async {
    if (!active) {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
    } else if (locationEnabled && _positionSubscription == null) {
      await enableLocation();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  static const _demoFacilities = [
    Facility(
      id: 'demo-rsud-bandung',
      name: 'RSUD Kota Bandung',
      type: FacilityType.hospital,
      point: LatLng(-6.9334, 107.7019),
      address: 'Jl. Rumah Sakit No. 22, Ujungberung, Bandung',
      services: ['IGD', 'Rawat inap'],
      phone: '(022) 7811794',
      isDemo: true,
    ),
    Facility(
      id: 'demo-puskesmas',
      name: 'Puskesmas Sukajadi',
      type: FacilityType.puskesmas,
      point: LatLng(-6.8897, 107.5948),
      address: 'Jl. Sukagalih No. 26, Kota Bandung',
      services: ['Layanan umum'],
      isDemo: true,
    ),
    Facility(
      id: 'demo-klinik',
      name: 'Klinik Pratama Sehat',
      type: FacilityType.clinic,
      point: LatLng(-6.9121, 107.6176),
      address: 'Data demonstrasi untuk pratinjau aplikasi',
      services: ['Layanan umum'],
      isDemo: true,
    ),
  ];
}
