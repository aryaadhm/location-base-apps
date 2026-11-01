import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'models/facility.dart';
import 'screens/facility_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'state/app_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartVillageApp());
}

class SmartVillageApp extends StatelessWidget {
  const SmartVillageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Village Indonesia',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  final AppController _controller = AppController();
  int _index = 0;
  String? _shownGeofenceMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_controllerChanged);
    _controller.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_controllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.setForegroundActive(state == AppLifecycleState.resumed);
  }

  void _controllerChanged() {
    if (!mounted) return;
    setState(() {});
    final message = _controller.geofenceMessage;
    if (message != null && message != _shownGeofenceMessage) {
      _shownGeofenceMessage = message;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Lihat peta',
                onPressed: () => setState(() => _index = 1),
              ),
            ),
          );
      });
    }
  }

  void _openFacilities(FacilityType? type, {String query = ''}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FacilityListScreen(
          key: ValueKey(type),
          controller: _controller,
          initialType: type,
          initialQuery: query,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        controller: _controller,
        onOpenList: _openFacilities,
        onOpenMap: () => setState(() => _index = 1),
        onSearch: (query) => _openFacilities(null, query: query),
      ),
      MapScreen(controller: _controller),
      ProfileScreen(controller: _controller),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE3F1FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Peta',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
