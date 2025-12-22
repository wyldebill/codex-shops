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
    return MaterialApp(
      title: 'Shops Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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
  late GoogleMapController mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  final Set<Circle> circles = {};

  // Buffalo, Minnesota coordinates
  static const LatLng _buffalo = LatLng(44.88399, -93.29860);

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  void _addMarkers() {
    markers.add(
      Marker(
        markerId: const MarkerId('buffalo'),
        position: _buffalo,
        infoWindow: const InfoWindow(
          title: 'Buffalo',
          snippet: 'Buffalo, Minnesota',
        ),
        onTap: () {
          mapController.animateCamera(CameraUpdate.newLatLngZoom(_buffalo, 15));
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _zoomIn() {
    mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    mapController.animateCamera(CameraUpdate.zoomOut());
  }

  void _centerOnBuffalo() {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(_buffalo, 14));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buffalo, MN Map'), elevation: 0),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _buffalo, zoom: 14),
            markers: markers,
            polylines: polylines,
            circles: circles,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            trafficEnabled: false,
          ),
          // Custom control buttons
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: _zoomIn,
                  tooltip: 'Zoom In',
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _zoomOut,
                  tooltip: 'Zoom Out',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _centerOnBuffalo,
                  tooltip: 'Center on Buffalo',
                  child: const Icon(Icons.location_on),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
