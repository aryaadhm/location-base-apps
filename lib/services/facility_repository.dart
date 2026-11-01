import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/facility.dart';

class FacilitySearchResult {
  const FacilitySearchResult({
    required this.facilities,
    required this.fromCache,
  });
  final List<Facility> facilities;
  final bool fromCache;
}

class FacilityRepository {
  FacilityRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<FacilitySearchResult> nearby({
    required LatLng center,
    required int radiusMeters,
  }) async {
    final cacheKey =
        'facilities:${center.latitude.toStringAsFixed(2)}:${center.longitude.toStringAsFixed(2)}:$radiusMeters';
    final prefs = await SharedPreferences.getInstance();
    final query =
        '''
[out:json][timeout:25];
(
  nwr(around:$radiusMeters,${center.latitude},${center.longitude})["amenity"~"^(hospital|clinic|doctors)\$"];
  nwr(around:$radiusMeters,${center.latitude},${center.longitude})["healthcare"~"^(hospital|clinic|centre|health_post|doctor)\$"];
);
out center tags;
''';

    try {
      final response = await _client
          .post(
            Uri.parse('https://overpass-api.de/api/interpreter'),
            headers: const {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'data': query},
          )
          .timeout(const Duration(seconds: 35));
      if (response.statusCode != 200) {
        throw Exception(
          'Pencarian fasilitas merespons ${response.statusCode}.',
        );
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final facilities = <Facility>[];
      final seen = <String>{};
      for (final raw in decoded['elements'] as List? ?? const []) {
        final element = raw as Map<String, dynamic>;
        final facility = _fromOverpass(element);
        if (facility != null && seen.add(facility.id)) facilities.add(facility);
      }
      await prefs.setString(
        cacheKey,
        jsonEncode(facilities.map((item) => item.toJson()).toList()),
      );
      return FacilitySearchResult(facilities: facilities, fromCache: false);
    } catch (_) {
      final cached = prefs.getString(cacheKey);
      if (cached == null) rethrow;
      final facilities = (jsonDecode(cached) as List)
          .map((item) => Facility.fromJson(item as Map<String, dynamic>))
          .toList();
      return FacilitySearchResult(facilities: facilities, fromCache: true);
    }
  }

  Facility? _fromOverpass(Map<String, dynamic> element) {
    final tags = Map<String, dynamic>.from(
      element['tags'] as Map? ?? const <String, dynamic>{},
    );
    final center = element['center'] as Map?;
    final latitude =
        (element['lat'] as num?)?.toDouble() ??
        (center?['lat'] as num?)?.toDouble();
    final longitude =
        (element['lon'] as num?)?.toDouble() ??
        (center?['lon'] as num?)?.toDouble();
    if (latitude == null || longitude == null) return null;

    final name = tags['name']?.toString().trim();
    if (name == null || name.isEmpty) return null;
    final normalized = name.toLowerCase();
    final healthcare = tags['healthcare']?.toString().toLowerCase();
    final amenity = tags['amenity']?.toString().toLowerCase();
    final type =
        normalized.contains('puskesmas') ||
            normalized.contains('pustu') ||
            normalized.contains('poskesdes') ||
            healthcare == 'health_post'
        ? FacilityType.puskesmas
        : amenity == 'hospital' || healthcare == 'hospital'
        ? FacilityType.hospital
        : FacilityType.clinic;

    final addressParts = <String>[
      if (tags['addr:street'] != null) tags['addr:street'].toString(),
      if (tags['addr:housenumber'] != null) tags['addr:housenumber'].toString(),
      if (tags['addr:village'] != null) tags['addr:village'].toString(),
      if (tags['addr:city'] != null) tags['addr:city'].toString(),
    ];
    final services = <String>{
      if (tags['emergency'] == 'yes') 'IGD',
      if (tags['beds'] != null) 'Rawat inap',
      if (tags['dispensing'] == 'yes') 'Farmasi',
      ...?tags['healthcare:speciality']
          ?.toString()
          .split(';')
          .map((value) => _titleCase(value.replaceAll('_', ' '))),
    }.toList();

    return Facility(
      id: '${element['type']}-${element['id']}',
      name: name,
      type: type,
      point: LatLng(latitude, longitude),
      address: addressParts.isEmpty
          ? 'Alamat belum tersedia di OpenStreetMap'
          : addressParts.join(', '),
      services: services,
      phone: tags['phone']?.toString() ?? tags['contact:phone']?.toString(),
      website:
          tags['website']?.toString() ?? tags['contact:website']?.toString(),
      openingHours: tags['opening_hours']?.toString(),
    );
  }

  String _titleCase(String value) => value
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
