import 'package:latlong2/latlong.dart';

enum FacilityType { hospital, puskesmas, clinic }

extension FacilityTypeLabel on FacilityType {
  String get label => switch (this) {
    FacilityType.hospital => 'Rumah Sakit',
    FacilityType.puskesmas => 'Puskesmas',
    FacilityType.clinic => 'Klinik',
  };
}

class Facility {
  const Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.point,
    required this.address,
    required this.services,
    this.phone,
    this.website,
    this.openingHours,
    this.distanceMeters,
    this.isDemo = false,
  });

  final String id;
  final String name;
  final FacilityType type;
  final LatLng point;
  final String address;
  final List<String> services;
  final String? phone;
  final String? website;
  final String? openingHours;
  final double? distanceMeters;
  final bool isDemo;

  Facility copyWith({double? distanceMeters}) => Facility(
    id: id,
    name: name,
    type: type,
    point: point,
    address: address,
    services: services,
    phone: phone,
    website: website,
    openingHours: openingHours,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    isDemo: isDemo,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'lat': point.latitude,
    'lng': point.longitude,
    'address': address,
    'services': services,
    'phone': phone,
    'website': website,
    'openingHours': openingHours,
    'isDemo': isDemo,
  };

  factory Facility.fromJson(Map<String, dynamic> json) => Facility(
    id: json['id'].toString(),
    name: json['name']?.toString() ?? 'Fasilitas kesehatan',
    type: FacilityType.values.firstWhere(
      (value) => value.name == json['type'],
      orElse: () => FacilityType.clinic,
    ),
    point: LatLng(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    ),
    address: json['address']?.toString() ?? 'Alamat belum tersedia',
    services: List<String>.from(json['services'] as List? ?? const []),
    phone: json['phone']?.toString(),
    website: json['website']?.toString(),
    openingHours: json['openingHours']?.toString(),
    isDemo: json['isDemo'] == true,
  );
}
