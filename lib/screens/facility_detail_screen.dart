import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';
import '../models/facility.dart';
import '../widgets/facility_ui.dart';

class FacilityDetailScreen extends StatelessWidget {
  const FacilityDetailScreen({super.key, required this.facility});
  final Facility facility;

  Future<void> _launchDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${facility.point.latitude},${facility.point.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final color = facilityColor(facility.type);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Fasilitas'),
        actions: [
          IconButton(
            tooltip: 'Bagikan',
            onPressed: () => SharePlus.instance.share(
              ShareParams(
                text:
                    '${facility.name}\n${facility.address}\nhttps://www.google.com/maps/search/?api=1&query=${facility.point.latitude},${facility.point.longitude}',
              ),
            ),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                Container(
                  height: 210,
                  color: color.withValues(alpha: 0.12),
                  child: Center(
                    child: FacilityAvatar(type: facility.type, size: 110),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          facility.type.label,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _DetailRow(
                        icon: Icons.location_on_outlined,
                        title: formatDistance(facility.distanceMeters),
                        subtitle: facility.address,
                      ),
                      if (facility.phone != null)
                        _DetailRow(
                          icon: Icons.phone_outlined,
                          title: facility.phone!,
                          subtitle: 'Telepon',
                          onTap: () =>
                              launchUrl(Uri.parse('tel:${facility.phone}')),
                        ),
                      if (facility.openingHours != null)
                        _DetailRow(
                          icon: Icons.schedule_rounded,
                          title: facility.openingHours!,
                          subtitle: 'Jam operasional dari OpenStreetMap',
                        ),
                      const SizedBox(height: 12),
                      Text(
                        'Jenis Pelayanan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if (facility.services.isEmpty)
                        const Text(
                          'Informasi layanan belum tersedia.',
                          style: TextStyle(color: AppColors.muted),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: facility.services
                              .map(ServiceChip.new)
                              .toList(),
                        ),
                      if (facility.isDemo) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Fasilitas ini merupakan data demonstrasi dan bukan direktori resmi.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: FilledButton.icon(
                onPressed: _launchDirections,
                icon: const Icon(Icons.navigation_rounded),
                label: const Text('Lihat di Peta'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: AppColors.primary, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
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
    );
  }
}
