import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_village/app_theme.dart';
import 'package:smart_village/main.dart';
import 'package:smart_village/models/facility.dart';
import 'package:smart_village/screens/facility_detail_screen.dart';
import 'package:smart_village/screens/facility_list_screen.dart';
import 'package:smart_village/screens/map_screen.dart';
import 'package:smart_village/state/app_controller.dart';

bool _fontsLoaded = false;

Future<void> _loadFonts() async {
  if (_fontsLoaded) return;
  final roboto = FontLoader('Roboto')
    ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Roboto-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('assets/fonts/MaterialIcons-Regular.otf'));
  await Future.wait([roboto.load(), icons.load()]);
  _fontsLoaded = true;
}

Future<void> _prepare(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await _loadFonts();
  await tester.binding.setSurfaceSize(const Size(393, 852));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _screen(Widget child) => MaterialApp(theme: buildTheme(), home: child);

const _facilities = [
  Facility(
    id: 'rs-1',
    name: 'RSUD Kabupaten Bandung',
    type: FacilityType.hospital,
    point: LatLng(-6.931, 107.701),
    address: 'Jl. Rumah Sakit No. 22, Bandung',
    services: ['IGD', 'Poliklinik', 'Rawat inap'],
    distanceMeters: 1200,
    phone: '(022) 7811794',
  ),
  Facility(
    id: 'pkm-1',
    name: 'Puskesmas Sukajadi',
    type: FacilityType.puskesmas,
    point: LatLng(-6.902, 107.615),
    address: 'Jl. Sukajadi, Kota Bandung',
    services: ['Layanan umum', 'Farmasi'],
    distanceMeters: 2800,
  ),
  Facility(
    id: 'klinik-1',
    name: 'Klinik Sehat Mandiri',
    type: FacilityType.clinic,
    point: LatLng(-6.915, 107.626),
    address: 'Jl. Merdeka, Kota Bandung',
    services: ['Layanan umum'],
    distanceMeters: 4100,
  ),
];

void main() {
  testWidgets('capture home screen at phone viewport', (tester) async {
    await _prepare(tester);
    await tester.pumpWidget(const SmartVillageApp());
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/images/smart_village_hero.png'),
        tester.element(find.byType(MainShell)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));

    await expectLater(
      find.byType(MainShell),
      matchesGoldenFile('goldens/home-screen.png'),
    );
  });

  testWidgets('capture facility list at phone viewport', (tester) async {
    await _prepare(tester);
    final controller = AppController()..facilities = _facilities;
    await tester.pumpWidget(
      _screen(FacilityListScreen(controller: controller)),
    );
    await tester.pump();

    await expectLater(
      find.byType(FacilityListScreen),
      matchesGoldenFile('goldens/facility-list-screen.png'),
    );
    controller.dispose();
  });

  testWidgets('capture map layout at phone viewport', (tester) async {
    await _prepare(tester);
    final controller = AppController()..facilities = _facilities;
    await tester.pumpWidget(
      _screen(MapScreen(controller: controller, showBaseMap: false)),
    );
    await tester.pump();

    await expectLater(
      find.byType(MapScreen),
      matchesGoldenFile('goldens/map-screen.png'),
    );
    controller.dispose();
  });

  testWidgets('capture facility detail at phone viewport', (tester) async {
    await _prepare(tester);
    await tester.pumpWidget(
      _screen(FacilityDetailScreen(facility: _facilities[0])),
    );
    await tester.pump();

    await expectLater(
      find.byType(FacilityDetailScreen),
      matchesGoldenFile('goldens/facility-detail-screen.png'),
    );
  });
}
