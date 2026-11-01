import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/region.dart';

class RegionRepository {
  RegionRepository({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://www.emsifa.com/api-wilayah-indonesia/v2';
  final http.Client _client;

  Future<List<Region>> provinces() => _fetch('provinces.json');

  Future<List<Region>> regencies(String provinceId) =>
      _fetch('regencies/$provinceId.json');

  Future<List<Region>> districts(String regencyId) =>
      _fetch('districts/$regencyId.json');

  Future<List<Region>> villages(String districtId) =>
      _fetch('villages/$districtId.json');

  Future<List<Region>> _fetch(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'region:$path';
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/$path'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Layanan wilayah merespons ${response.statusCode}.');
      }
      final decoded = jsonDecode(response.body);
      final raw = decoded is Map<String, dynamic> ? decoded['data'] : decoded;
      final list = (raw as List)
          .map((item) => Region.fromJson(item as Map<String, dynamic>))
          .toList();
      await prefs.setString(key, response.body);
      return list;
    } catch (_) {
      final cached = prefs.getString(key);
      if (cached == null) rethrow;
      final decoded = jsonDecode(cached);
      final raw = decoded is Map<String, dynamic> ? decoded['data'] : decoded;
      return (raw as List)
          .map((item) => Region.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }
}
