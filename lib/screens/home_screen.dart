import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/facility.dart';
import '../state/app_controller.dart';
import '../widgets/region_picker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.onOpenList,
    required this.onOpenMap,
    required this.onSearch,
  });

  final AppController controller;
  final ValueChanged<FacilityType?> onOpenList;
  final VoidCallback onOpenMap;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Hero(controller: controller)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          sliver: SliverList.list(
            children: [
              TextField(
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  final query = value.trim();
                  if (query.isNotEmpty) onSearch(query);
                },
                decoration: const InputDecoration(
                  hintText: 'Cari nama fasilitas kesehatan...',
                  prefixIcon: Icon(Icons.search_rounded),
                  suffixIcon: Icon(Icons.arrow_forward_rounded),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final changed = await showRegionPicker(context, controller);
                  if (changed == true && context.mounted) onOpenList(null);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5EAF2)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFEAF4FF),
                        foregroundColor: AppColors.primary,
                        child: Icon(Icons.location_on_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi pencarian',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.locationLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_right_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Cari berdasarkan kategori',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _CategoryCard(
                    label: 'Rumah Sakit',
                    icon: Icons.local_hospital_rounded,
                    color: AppColors.primary,
                    background: const Color(0xFFE1F2FF),
                    onTap: () => onOpenList(FacilityType.hospital),
                  ),
                  _CategoryCard(
                    label: 'Puskesmas',
                    icon: Icons.home_work_rounded,
                    color: AppColors.green,
                    background: const Color(0xFFE2F8E9),
                    onTap: () => onOpenList(FacilityType.puskesmas),
                  ),
                  _CategoryCard(
                    label: 'Klinik',
                    icon: Icons.health_and_safety_rounded,
                    color: AppColors.purple,
                    background: const Color(0xFFEDE5FA),
                    onTap: () => onOpenList(FacilityType.clinic),
                  ),
                  _CategoryCard(
                    label: 'Peta Lokasi',
                    icon: Icons.map_rounded,
                    color: AppColors.gold,
                    background: const Color(0xFFFFF1CF),
                    onTap: onOpenMap,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _NearbySummary(
                controller: controller,
                onTap: () => onOpenList(null),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 275,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/smart_village_hero.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Village',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Sehat bersama desa maju',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const SizedBox(
                    width: 260,
                    child: Text(
                      'Cari klinik, puskesmas, dan rumah sakit terdekat di seluruh Indonesia.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbySummary extends StatelessWidget {
  const _NearbySummary({required this.controller, required this.onTap});
  final AppController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEAF4FF),
                foregroundColor: AppColors.primary,
                child: Icon(Icons.near_me_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.loadingFacilities
                          ? 'Mencari fasilitas...'
                          : '${controller.facilities.length} fasilitas ditemukan',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Dalam radius ${controller.searchRadiusMeters ~/ 1000} km',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
