import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

void main() async {
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
  MapLibreMapController? mapController;
  final List<Symbol> _symbols = [];
  final TextEditingController _searchController = TextEditingController();
  StoreLocation? _selectedLocation;
  String _searchQuery = '';
  List<StoreLocation> _searchResults = [];
  int _selectedIndex = 1;

  // Track marker state separately to avoid rebuilding on every UI change
  bool _markersDirty = true;

  // Slpy style URL - API key should be configured via platform-specific methods
  static const String _styleUrl = 'https://tiles.slpy.com/styles/slpy-maptiles/style.json';
  
  static const LatLng _buffaloDowntown = LatLng(45.1718, -93.8746);

  static const List<StoreLocation> storeLocations = [
    StoreLocation(
      name: 'Biggs & Company',
      address: '15 Central Ave, Buffalo, MN',
      icon: Icons.storefront,
      iconColor: Color(0xFF10A653),
      isOpen: true,
      position: LatLng(45.1721, -93.8748),
    ),
    StoreLocation(
      name: "Evelyn's Wine Bar",
      address: '14 Central Ave, Buffalo, MN',
      icon: Icons.wine_bar,
      iconColor: Color(0xFFE85D75),
      isOpen: true,
      position: LatLng(45.1718, -93.8745),
    ),
    StoreLocation(
      name: 'Buffalo Books & Coffee',
      address: '6 Division St E, Buffalo, MN',
      icon: Icons.local_cafe,
      iconColor: Color(0xFF0069D9),
      isOpen: false,
      position: LatLng(45.1716, -93.8755),
    ),
    StoreLocation(
      name: "BJ's Deli",
      address: '15 Division St E, Buffalo, MN',
      icon: Icons.lunch_dining,
      iconColor: Color(0xFFFF9D2B),
      isOpen: true,
      position: LatLng(45.1723, -93.8751),
    ),
    StoreLocation(
      name: 'The Porch on Buffalo',
      address: '3 Division St E, Buffalo, MN',
      icon: Icons.chair,
      iconColor: Color(0xFF7B5DBA),
      isOpen: false,
      position: LatLng(45.1713, -93.8739),
    ),
    StoreLocation(
      name: 'Tangled Salon & Spa',
      address: '2 Central Ave, Buffalo, MN',
      icon: Icons.spa,
      iconColor: Color(0xFF10A653),
      isOpen: true,
      position: LatLng(45.1726, -93.8740),
    ),
    StoreLocation(
      name: 'Thrifty White Pharmacy',
      address: '12 Division St E, Buffalo, MN',
      icon: Icons.local_pharmacy,
      iconColor: Color(0xFF0069D9),
      isOpen: true,
      position: LatLng(45.1709, -93.8744),
    ),
    StoreLocation(
      name: 'Rustic Arbor',
      address: '16 Division St W, Buffalo, MN',
      icon: Icons.park,
      iconColor: Color(0xFF7B5DBA),
      isOpen: false,
      position: LatLng(45.1719, -93.8758),
    ),
    StoreLocation(
      name: 'Lillians of Buffalo',
      address: '3 Central Ave, Buffalo, MN',
      icon: Icons.shopping_bag,
      iconColor: Color(0xFFE85D75),
      isOpen: true,
      position: LatLng(45.1710, -93.8738),
    ),
    StoreLocation(
      name: 'Sunrise Nutrition',
      address: '8 Division St W, Buffalo, MN',
      icon: Icons.emoji_food_beverage,
      iconColor: Color(0xFFFF9D2B),
      isOpen: false,
      position: LatLng(45.1720, -93.8736),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = storeLocations.firstWhere(
      (location) => location.name == 'Biggs & Company',
      orElse: () => storeLocations.first,
    );
  }

  void _refreshMarkers() async {
    // Only rebuild markers if needed and controller is ready
    if (!_markersDirty || mapController == null) return;

    // Clear existing symbols
    if (_symbols.isNotEmpty) {
      await mapController!.removeSymbols(_symbols);
      _symbols.clear();
    }

    // Add symbols for each location
    for (var location in storeLocations) {
      final isSelected = _selectedLocation?.name == location.name;
      
      final symbol = await mapController!.addSymbol(
        SymbolOptions(
          geometry: location.position,
          iconImage: 'marker-15',
          iconSize: isSelected ? 1.5 : 1.0,
          textField: location.name,
          textOffset: const Offset(0, 1.5),
          textSize: 10,
          textColor: '#000000',
        ),
      );
      _symbols.add(symbol);
    }

    _markersDirty = false;
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    _refreshMarkers();
  }

  void _zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _selectLocation(StoreLocation location) {
    setState(() {
      _selectedLocation = location;
      _markersDirty = true; // Mark that markers need refresh
    });

    _animateTo(location.position, zoom: 16);
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _searchResults = value.isEmpty
          ? []
          : storeLocations
                .where(
                  (location) =>
                      location.name.toLowerCase().contains(value.toLowerCase()),
                )
                .toList();
      // Don't refresh markers on search - only when location is selected
    });
  }

  void _handleSearchSelection(StoreLocation location) {
    _searchController.text = location.name;
    FocusScope.of(context).unfocus();
    setState(() {
      _searchQuery = location.name;
      _searchResults = [];
      // Don't refresh markers here - let _selectLocation handle it
    });
    _selectLocation(location); // This will mark markers dirty
  }

  void _animateTo(LatLng target, {double zoom = 13.5}) {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, zoom),
    );
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
                  MapLibreMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation?.position ?? _buffaloDowntown,
                      zoom: 15.5,
                    ),
                    styleString: _styleUrl,
                    myLocationEnabled: true,
                    myLocationTrackingMode: MyLocationTrackingMode.none,
                    compassEnabled: false,
                    onStyleLoadedCallback: _refreshMarkers,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        Row(
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: _handleSearchChanged,
                                          decoration: const InputDecoration(
                                            hintText: 'Search for a place...',
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.favorite,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_searchResults.isNotEmpty &&
                            _searchQuery.isNotEmpty)
                          const SizedBox(height: 8),
                        if (_searchResults.isNotEmpty &&
                            _searchQuery.isNotEmpty)
                          Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxHeight: 240),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  return ListTile(
                                    title: Text(result.name),
                                    subtitle: Text(result.address),
                                    trailing: Icon(
                                      result.isOpen
                                          ? Icons.circle
                                          : Icons.circle_outlined,
                                      size: 12,
                                      color: result.isOpen
                                          ? theme.colorScheme.primary
                                          : Colors.grey,
                                    ),
                                    onTap: () => _handleSearchSelection(result),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
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
                          onPressed: () => _animateTo(
                            _selectedLocation?.position ?? _buffaloDowntown,
                          ),
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
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
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
                                '${storeLocations.length} Places Found',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                          Icon(Icons.tune, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: storeLocations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final location = storeLocations[index];
                          final isSelected =
                              _selectedLocation?.name == location.name;
                          return _LocationTile(
                            location: location,
                            isSelected: isSelected,
                            onTap: () => _selectLocation(location),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
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
    _searchController.dispose();
    super.dispose();
  }
}

class StoreLocation {
  final String name;
  final String address;
  final IconData icon;
  final Color iconColor;
  final LatLng position;
  final bool isOpen;

  const StoreLocation({
    required this.name,
    required this.address,
    required this.icon,
    required this.iconColor,
    required this.position,
    required this.isOpen,
  });

  double get iconHue => HSVColor.fromColor(iconColor).hue;

  String get statusLabel => isOpen ? 'Open now' : 'Closed';
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.location,
    required this.isSelected,
    required this.onTap,
  });

  final StoreLocation location;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF8FAFB),
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
                    const SizedBox(height: 4),
                    Text(
                      location.statusLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: location.isOpen
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
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
