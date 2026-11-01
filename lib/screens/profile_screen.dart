import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../state/app_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF4FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      color: AppColors.primary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Village Indonesia',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Pencarian fasilitas kesehatan berbasis lokasi',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Lokasi & geofencing'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.my_location_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    controller.locationEnabled
                        ? 'Lokasi aktif'
                        : 'Lokasi belum aktif',
                  ),
                  subtitle: Text(
                    controller.locationMessage ?? 'Dipakai untuk menghitung jarak dan mendeteksi area fasilitas.',
                  ),
                  trailing: controller.locationEnabled
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.green,
                        )
                      : TextButton(
                          onPressed: controller.enableLocation,
                          child: const Text('Aktifkan'),
                        ),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.radar_rounded,
                    color: AppColors.purple,
                  ),
                  title: const Text('Geofencing saat aplikasi terbuka'),
                  subtitle: const Text('Radius masuk 200 m dan keluar 250 m.'),
                  value: controller.geofenceEnabled,
                  onChanged: controller.setGeofenceEnabled,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(
                    Icons.science_outlined,
                    color: AppColors.gold,
                  ),
                  title: const Text('Simulasikan notifikasi masuk'),
                  subtitle: const Text(
                    'Untuk demonstrasi saat penilaian praktikum.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: controller.simulateGeofence,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Tentang data'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sumber data',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Wilayah administratif: API Wilayah Indonesia (Emsifa).\n'
                    'Peta dan fasilitas: kontributor OpenStreetMap.',
                    style: TextStyle(color: AppColors.muted, height: 1.5),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Cakupan fasilitas mengikuti data yang telah dipetakan dan bukan direktori resmi nasional.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Versi 1.0.0 • Kuis Pemrograman Mobile',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
