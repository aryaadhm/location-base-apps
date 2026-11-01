import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/facility.dart';
import '../state/app_controller.dart';
import '../widgets/facility_ui.dart';
import '../widgets/region_picker.dart';
import 'facility_detail_screen.dart';

class FacilityListScreen extends StatefulWidget {
  const FacilityListScreen({
    super.key,
    required this.controller,
    this.initialType,
    this.initialQuery = '',
  });
  final AppController controller;
  final FacilityType? initialType;
  final String initialQuery;

  @override
  State<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends State<FacilityListScreen> {
  late FacilityType? _selectedType = widget.initialType;
  late String _query = widget.initialQuery;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<Facility> get _filtered => widget.controller.facilities.where((item) {
    final typeMatches = _selectedType == null || item.type == _selectedType;
    final queryMatches = item.name.toLowerCase().contains(_query.toLowerCase());
    return typeMatches && queryMatches;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fasilitas Kesehatan'),
        actions: [
          IconButton(
            tooltip: 'Pilih wilayah',
            onPressed: () => showRegionPicker(context, controller),
            icon: const Icon(Icons.location_on_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.searchFacilities,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: _query,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        hintText: 'Cari nama fasilitas kesehatan...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            label: 'Semua',
                            selected: _selectedType == null,
                            onTap: () => setState(() => _selectedType = null),
                          ),
                          ...FacilityType.values.map(
                            (type) => _FilterChip(
                              label: type.label,
                              selected: _selectedType == type,
                              onTap: () => setState(() => _selectedType = type),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 17,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            controller.locationLabel,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        PopupMenuButton<int>(
                          tooltip: 'Atur radius pencarian',
                          onSelected: controller.setRadius,
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 10000,
                              child: Text('Radius 10 km'),
                            ),
                            PopupMenuItem(
                              value: 25000,
                              child: Text('Radius 25 km'),
                            ),
                            PopupMenuItem(
                              value: 50000,
                              child: Text('Radius 50 km'),
                            ),
                          ],
                          child: Text(
                            '${controller.searchRadiusMeters ~/ 1000} km',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (controller.loadingFacilities) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(minHeight: 3),
                    ],
                    if (controller.facilityError != null) ...[
                      const SizedBox(height: 12),
                      _StatusBanner(message: controller.facilityError!),
                    ] else if (controller.usingCachedFacilities) ...[
                      const SizedBox(height: 12),
                      const _StatusBanner(
                        message: 'Menampilkan hasil tersimpan karena jaringan tidak tersedia.',
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (_filtered.isEmpty && !controller.loadingFacilities)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyResults(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
                sliver: SliverList.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _FacilityCard(
                    facility: _filtered[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FacilityDetailScreen(facility: _filtered[index]),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.navy,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        side: BorderSide(
          color: selected ? AppColors.primary : const Color(0xFFE2E7EF),
        ),
        showCheckmark: false,
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({required this.facility, required this.onTap});
  final Facility facility;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FacilityAvatar(type: facility.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            facility.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDistance(facility.distanceMeters)} • ${facility.type.label}',
                      style: TextStyle(
                        color: facilityColor(facility.type),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (facility.services.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: facility.services
                            .take(3)
                            .map(ServiceChip.new)
                            .toList(),
                      ),
                    ],
                    if (facility.isDemo) ...[
                      const SizedBox(height: 7),
                      const Text(
                        'Data demo',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.gold,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 52, color: AppColors.muted),
            SizedBox(height: 12),
            Text(
              'Tidak ada fasilitas yang cocok.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
