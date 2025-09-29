import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:map_box_example/services/location_service.dart';
import 'package:map_box_example/services/mapbox_service.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Services
  late final MapBoxService _mapBoxService;
  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    // Initialize services
    _mapBoxService = MapBoxService();
    _locationService = LocationService();
  }

  @override
  void dispose() {
    _mapBoxService.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    // Initialize MapBox service
    _mapBoxService.initializeMap(mapboxMap);

    // Update map style
    await _mapBoxService.updateMapStyle();

    // Enable location component
    await _mapBoxService.enableLocationComponent();

    // Initialize clusters with sample data
    await _initializeClusters();

    // Start the animation sequence
    await _performRiyadhAnimation();
  }

  Future<void> _initializeClusters() async {
    if (_mapBoxService.mapboxMap == null) return;

    try {
      // Sample cluster points data
      final samplePoints = [
        {
          'id': '1',
          'title': 'Riyadh',
          'coordinates': Position(46.6753, 24.7136),
        },
        {
          'id': '2',
          'title': 'Jeddah',
          'coordinates': Position(39.1925, 21.5433),
        },
        {
          'id': '3',
          'title': 'Mecca',
          'coordinates': Position(39.8579, 21.4225),
        },
        {
          'id': '4',
          'title': 'Medina',
          'coordinates': Position(39.6142, 24.4686),
        },
        {
          'id': '5',
          'title': 'Dammam',
          'coordinates': Position(50.0999, 26.4207),
        },
      ];

      await _mapBoxService.createClusterSource(
        samplePoints,
        sourceId: 'city-clusters',
        clusterRadius: 50,
        clusterMaxZoom: 14,
      );

      log('Clusters initialized successfully');
    } catch (e) {
      log('Error initializing clusters: $e');
    }
  }

  Future<void> _performRiyadhAnimation() async {
    try {
      // Create animation sequence
      final animations = [
        // First, zoom into Riyadh city
        CameraAnimation(
          center: PredefinedLocations.riyadhCenter,
          zoom: 12.0,
          duration: 1500,
          delayAfter: 2000, // Wait 2 seconds
        ),
        // Then zoom out to show all of Saudi Arabia
        CameraAnimation(
          center: PredefinedLocations.saudiArabiaCenter,
          zoom: 5.5,
          duration: 2000,
        ),
      ];

      await _mapBoxService.performAnimationSequence(animations);
    } catch (e) {
      log('Error during Riyadh animation: $e');
    }
  }

  Future<void> _onChangeMapStyle() async {
    try {
      await _mapBoxService.toggleMapStyle();

      // Re-initialize clusters after style change
      await Future.delayed(const Duration(milliseconds: 500));
      await _initializeClusters();

      setState(() {}); // Refresh UI
    } catch (e) {
      _showError('Failed to change map style');
    }
  }

  Future<void> _zoomIn() async {
    try {
      await _mapBoxService.zoomIn();
    } catch (e) {
      _showError('Failed to zoom in');
    }
  }

  Future<void> _zoomOut() async {
    try {
      await _mapBoxService.zoomOut();
    } catch (e) {
      _showError('Failed to zoom out');
    }
  }

  Future<void> _zoomToCurrentLocation() async {
    try {
      // Get current location
      final geoPosition = await _locationService.getCurrentLocation();

      // Convert to MapBox Point
      final mapPosition = Point(
        coordinates: Position(geoPosition.longitude, geoPosition.latitude),
      );

      // Animate to location
      await _mapBoxService.animateToPosition(
        center: mapPosition,
        zoom: 15.0,
        duration: 500,
      );
    } catch (e) {
      _showError('Failed to get current location: ${e.toString()}');
    }
  }

  Future<void> _flyToRiyadh() async {
    try {
      await _mapBoxService.flyTo(
        center: PredefinedLocations.riyadhCenter,
        zoom: 12.0,
        duration: 2000,
      );
    } catch (e) {
      _showError('Failed to fly to Riyadh');
    }
  }

  Future<void> _resetMap() async {
    try {
      await _mapBoxService.resetMap(
        initialCenter: PredefinedLocations.saudiArabiaCenter,
        initialZoom: 5.5,
      );
    } catch (e) {
      _showError('Failed to reset map');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MapBox Widget
          MapWidget(
            onMapCreated: _onMapCreated,
            cameraOptions: CameraOptions(
              center: PredefinedLocations.riyadhCenter,
              zoom: 5.0,
            ),
            styleUri: _mapBoxService.currentStyle,
            textureView: true,
          ),

          // Map Style Toggle Button (Top Right)
          _buildMapStyleButton(),

          // Zoom and Location Controls (Top Left)
          _buildMapControls(),

          // Additional Controls (Bottom Right)
          _buildAdditionalControls(),
        ],
      ),
    );
  }

  Widget _buildMapStyleButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: _onChangeMapStyle,
          icon: const Icon(Icons.layers, size: 30, color: Colors.red),
          tooltip: 'Change Map Style',
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 50,
      left: 20,
      child: Column(
        children: [
          // Zoom In Button
          _buildControlButton(
            icon: Icons.add,
            onPressed: _zoomIn,
            tooltip: 'Zoom In',
          ),
          const SizedBox(height: 8),

          // Zoom Out Button
          _buildControlButton(
            icon: Icons.remove,
            onPressed: _zoomOut,
            tooltip: 'Zoom Out',
          ),
          const SizedBox(height: 8),

          // Current Location Button
          _buildControlButton(
            icon: Icons.my_location,
            onPressed: _zoomToCurrentLocation,
            iconColor: Colors.blue,
            tooltip: 'My Location',
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalControls() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fly to Riyadh Button
          _buildControlButton(
            icon: Icons.flight,
            onPressed: _flyToRiyadh,
            iconColor: Colors.green,
            tooltip: 'Fly to Riyadh',
          ),
          const SizedBox(height: 8),

          // Reset Map Button
          _buildControlButton(
            icon: Icons.restart_alt,
            onPressed: _resetMap,
            iconColor: Colors.orange,
            tooltip: 'Reset Map',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.black87,
    String? tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 24, color: iconColor),
        tooltip: tooltip,
      ),
    );
  }
}
