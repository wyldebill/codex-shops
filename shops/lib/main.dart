import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shops/config/app_secrets.dart';

void main() async {
  // Initialize secure configuration (loads .env file)
  await AppSecrets.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF2F9B4A);

    return MaterialApp(
      title: 'Shops Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F5F7),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.black54),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  int _selectedIndex = 1;

  static const LatLng _minneapolis = LatLng(44.9778, -93.2650);

  static const List<FavoriteLocation> favoriteLocations = [
    FavoriteLocation(
      name: 'Cafe Luna',
      address: '123 Elm St., St. Paul, MN',
      icon: Icons.coffee,
      iconColor: Color(0xFF10A653),
      position: LatLng(44.9537, -93.0899),
    ),
    FavoriteLocation(
      name: 'Café Luna',
      address: '123 Elm St., St. Paul, MN',
      icon: Icons.local_cafe,
      iconColor: Color(0xFFFF9D2B),
      position: LatLng(44.9483, -93.1093),
    ),
    FavoriteLocation(
      name: 'Target',
      address: 'Mall of America, Bloomington, MN',
      icon: Icons.shopping_bag,
      iconColor: Color(0xFF10A653),
      position: LatLng(44.8549, -93.2422),
    ),
    FavoriteLocation(
      name: 'Work',
      address: '450 Cedar Ave., Minneapolis, MN',
      icon: Icons.work,
      iconColor: Color(0xFF0069D9),
      position: LatLng(44.9681, -93.2472),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  void _addMarkers() {
    for (var location in favoriteLocations) {
      markers.add(
        Marker(
          markerId: MarkerId(location.name),
          position: location.position,
          infoWindow: InfoWindow(title: location.name, snippet: location.address),
          icon: BitmapDescriptor.defaultMarkerWithHue(location.iconHue),
          onTap: () => _animateTo(location.position, zoom: 14.5),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _animateTo(LatLng target, {double zoom = 13.5}) {
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition:
                        const CameraPosition(target: _minneapolis, zoom: 12.5),
                    markers: markers,
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    trafficEnabled: false,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.menu,
                          onPressed: () {},
                          backgroundColor: Colors.white,
                          iconColor: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(28),
                            child: Container(
                              height: 52,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search for a place...',
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.favorite,
                                      color: theme.colorScheme.primary),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 94,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Minneapolis',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _CircleIconButton(
                          icon: Icons.add,
                          onPressed: _zoomIn,
                          backgroundColor: Colors.white,
                          iconColor: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        _CircleIconButton(
                          icon: Icons.remove,
                          onPressed: _zoomOut,
                          backgroundColor: Colors.white,
                          iconColor: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _animateTo(_minneapolis),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.my_location),
                          label: const Text('Locate'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Favorite Locations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${favoriteLocations.length} Places Found',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        Icon(Icons.tune, color: theme.colorScheme.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favoriteLocations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final location = favoriteLocations[index];
                      return _LocationTile(
                        location: location,
                        onTap: () => _animateTo(location.position, zoom: 14.5),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Recents'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}

class FavoriteLocation {
  final String name;
  final String address;
  final IconData icon;
  final Color iconColor;
  final LatLng position;

  const FavoriteLocation({
    required this.name,
    required this.address,
    required this.icon,
    required this.iconColor,
    required this.position,
  });

  double get iconHue => HSVColor.fromColor(iconColor).hue;
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({required this.location, required this.onTap});

  final FavoriteLocation location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: const Color(0xFFF8FAFB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: location.iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(location.icon, color: location.iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.address,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: iconColor ?? Colors.black87),
        ),
      ),
    );
  }
}
