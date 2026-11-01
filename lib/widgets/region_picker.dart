import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/region.dart';
import '../state/app_controller.dart';

Future<bool?> showRegionPicker(BuildContext context, AppController controller) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _RegionPicker(controller: controller),
  );
}

class _RegionPicker extends StatefulWidget {
  const _RegionPicker({required this.controller});
  final AppController controller;

  @override
  State<_RegionPicker> createState() => _RegionPickerState();
}

class _RegionPickerState extends State<_RegionPicker> {
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

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DEE7),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pilih wilayah',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text(
              'Pilih sampai desa atau kelurahan untuk mencari fasilitas di sekitarnya.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            _RegionDropdown(
              label: 'Provinsi',
              value: controller.selectedProvince,
              items: controller.provinces,
              onChanged: controller.selectProvince,
            ),
            const SizedBox(height: 12),
            _RegionDropdown(
              label: 'Kabupaten / kota',
              value: controller.selectedRegency,
              items: controller.regencies,
              onChanged: controller.selectedProvince == null
                  ? null
                  : controller.selectRegency,
            ),
            const SizedBox(height: 12),
            _RegionDropdown(
              label: 'Kecamatan',
              value: controller.selectedDistrict,
              items: controller.districts,
              onChanged: controller.selectedRegency == null
                  ? null
                  : controller.selectDistrict,
            ),
            const SizedBox(height: 12),
            _RegionDropdown(
              label: 'Desa / kelurahan',
              value: controller.selectedVillage,
              items: controller.villages,
              onChanged: controller.selectedDistrict == null
                  ? null
                  : controller.selectVillage,
            ),
            if (controller.loadingRegions) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(minHeight: 3),
            ],
            if (controller.regionError != null) ...[
              const SizedBox(height: 14),
              Text(
                controller.regionError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: controller.selectedVillage?.hasCoordinates == true
                  ? () async {
                      await controller.applySelectedVillage();
                      if (context.mounted) Navigator.pop(context, true);
                    }
                  : null,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Cari fasilitas di wilayah ini'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionDropdown extends StatelessWidget {
  const _RegionDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final Region? value;
  final List<Region> items;
  final ValueChanged<Region?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Region>(
      initialValue: items.any((item) => item.id == value?.id) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (region) => DropdownMenuItem(
              value: region,
              child: Text(region.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
