import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';
import '../models/facility.dart';
import '../state/app_controller.dart';
import '../widgets/facility_ui.dart';
import '../widgets/region_picker.dart';
import 'facility_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.controller,
    this.showBaseMap = true,
  });
  final AppController controller;
  final bool showBaseMap;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _map = MapController();
  FacilityType? _filter;

  List<Facility> get _visible => widget.controller.facilities
      .where((item) => _filter == null || item.type == _filter)
      .toList();

  void _moveToSearchCenter() {
    _map.move(widget.controller.searchCenter, 13.5);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final current = controller.currentPosition;
    final currentPoint = current == null
        ? null
        : LatLng(current.latitude, current.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Lokasi'),
        actions: [
          IconButton(
            tooltip: 'Pilih wilayah',
            onPressed: () async {
              final changed = await showRegionPicker(context, controller);
              if (changed == true) _moveToSearchCenter();
            },
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: controller.searchCenter,
              initialZoom: 13.2,
              minZoom: 4,
              maxZoom: 18,
            ),
            children: [
              if (widget.showBaseMap)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'id.smartvillage.smart_village',
                ),
              if (controller.geofenceEnabled)
                CircleLayer(
                  circles: _visible
                      .take(30)
                      .map(
                        (facility) => CircleMarker(
                          point: facility.point,
                          radius: 200,
                          useRadiusInMeter: true,
                          color: facilityColor(facility.type)
                              .withValues(alpha: 0.08),
                          borderColor: facilityColor(facility.type)
                              .withValues(alpha: 0.35),
                          borderStrokeWidth: 1.5,
                        ),
                      )
                      .toList(),
                ),
              MarkerLayer(
                markers: [
                  ..._visible.map(
                    (facility) => Marker(
                      point: facility.point,
                      width: 52,
                      height: 64,
                      child: GestureDetector(
                        onTap: () => _showFacility(context, facility),
                        child: _FacilityMarker(type: facility.type),
                      ),
                    ),
                  ),
                  if (currentPoint != null)
                    Marker(
                      point: currentPoint,
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(color: Color(0x33000000), blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              SimpleAttributionWidget(
                source: const Text('OpenStreetMap contributors'),
                onTap: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                ),
              ),
            ],
          ),
          Positioned(
            left: 14,
            right: 14,
            top: 12,
            child: Material(
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.muted),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        controller.locationLabel,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${_visible.length} lokasi',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 22,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MapFilter(
                      label: 'Semua',
                      icon: Icons.layers_rounded,
                      color: AppColors.primary,
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    ...FacilityType.values.map(
                      (type) => _MapFilter(
                        label: type == FacilityType.hospital
                            ? 'RS'
                            : type == FacilityType.puskesmas
                            ? 'Puskesmas'
                            : 'Klinik',
                        icon: facilityIcon(type),
                        color: facilityColor(type),
                        selected: _filter == type,
                        onTap: () => setState(() => _filter = type),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: 'Pusatkan peta',
                      onPressed: _moveToSearchCenter,
                      icon: const Icon(Icons.my_location_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFacility(BuildContext context, Facility facility) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FacilityAvatar(type: facility.type),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDistance(facility.distanceMeters)} • ${facility.type.label}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FacilityDetailScreen(facility: facility),
                        ),
                      );
                    },
                    child: const Text('Lihat detail'),
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

class _FacilityMarker extends StatelessWidget {
  const _FacilityMarker({required this.type});
  final FacilityType type;

  @override
  Widget build(BuildContext context) {
    final color = facilityColor(type);
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0x44000000), blurRadius: 8),
            ],
          ),
          child: Icon(facilityIcon(type), color: Colors.white, size: 21),
        ),
        Icon(Icons.arrow_drop_down, color: color, size: 20),
      ],
    );
  }
}

class _MapFilter extends StatelessWidget {
  const _MapFilter({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? color : AppColors.muted, size: 21),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppColors.muted,
                fontSize: 9,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
