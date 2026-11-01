import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/facility.dart';

Color facilityColor(FacilityType type) => switch (type) {
  FacilityType.hospital => AppColors.primary,
  FacilityType.puskesmas => AppColors.green,
  FacilityType.clinic => AppColors.purple,
};

IconData facilityIcon(FacilityType type) => switch (type) {
  FacilityType.hospital => Icons.local_hospital_rounded,
  FacilityType.puskesmas => Icons.home_work_rounded,
  FacilityType.clinic => Icons.health_and_safety_rounded,
};

String formatDistance(double? meters) {
  if (meters == null) return 'Jarak belum tersedia';
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

class FacilityAvatar extends StatelessWidget {
  const FacilityAvatar({super.key, required this.type, this.size = 64});
  final FacilityType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = facilityColor(type);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(facilityIcon(type), color: color, size: size * 0.48),
    );
  }
}

class ServiceChip extends StatelessWidget {
  const ServiceChip(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
