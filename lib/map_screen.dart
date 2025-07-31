import 'package:flutter/material.dart';
import 'package:map_box_example/services/location_service.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;
  String style = MapboxStyles.STANDARD;

  // Riyadh coordinates
  final Point riyadhCenter = Point(
    coordinates: Position(46.6753, 24.7136), // Riyadh coordinates (lng, lat)
  );

  // Saudi Arabia center coordinates for country view
  final Point saudiArabiaCenter = Point(
    coordinates: Position(45.0792, 23.8859), // Saudi Arabia center (lng, lat)
  );

  Future<void> onChangeMapStyle() async {
    setState(() {
      style = style == MapboxStyles.STANDARD
          ? MapboxStyles.SATELLITE_STREETS
          : MapboxStyles.STANDARD;
    });
    if (mapboxMap != null) {
      await mapboxMap!.loadStyleURI(style);
    }
  }

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    _updateMapStyle();
    mapboxMap.location.updateSettings(LocationComponentSettings(enabled: true));

    // Start the animation sequence
    _performRiyadhAnimation();
  }

  Future<void> _performRiyadhAnimation() async {
    if (mapboxMap == null) return;

    try {
      // First, zoom into Riyadh city
      await mapboxMap!.easeTo(
        CameraOptions(
          center: riyadhCenter,
          zoom: 12.0, // City level zoom
        ),
        MapAnimationOptions(duration: 1500), // 1.5 seconds to zoom in
      );

      // Wait for 2 seconds while showing Riyadh
      await Future.delayed(const Duration(seconds: 2));

      // Then zoom out to show all of Saudi Arabia
      await mapboxMap!.easeTo(
        CameraOptions(
          center: saudiArabiaCenter,
          zoom: 5.5, // Country level zoom to show all Saudi Arabia
        ),
        MapAnimationOptions(duration: 2000), // 2 seconds to zoom out
      );
    } catch (e) {
      print('Error during Riyadh animation: $e');
    }
  }

  Future<void> _updateMapStyle() async {
    var configs = {
      "lightPreset": 'day',
      "theme": 'faded',
      "colorBuildingHighlight": 'red',
    };
    mapboxMap?.style.setStyleImportConfigProperties("basemap", configs);
  }

  void _zoomIn() {
    mapboxMap?.getCameraState().then((cameraState) {
      final currentZoom = cameraState.zoom;
      mapboxMap?.easeTo(
        CameraOptions(zoom: currentZoom + 1),
        MapAnimationOptions(duration: 300),
      );
    });
  }

  void _zoomOut() {
    mapboxMap?.getCameraState().then((cameraState) {
      final currentZoom = cameraState.zoom;
      mapboxMap?.easeTo(
        CameraOptions(zoom: currentZoom - 1),
        MapAnimationOptions(duration: 300),
      );
    });
  }

  Future<void> _zoomToCurrentLocation() async {
    LocationService locationService = LocationService();
    try {
      // Import geolocator Position as geoPosition to avoid conflict
      final geoPosition = await locationService.getCurrentLocation();
      // Convert geolocator Position to geotypes Position
      final mapPosition = Point(
        coordinates: Position(geoPosition.longitude, geoPosition.latitude),
      );
      mapboxMap?.easeTo(
        CameraOptions(center: mapPosition, zoom: 15.0),
        MapAnimationOptions(duration: 500),
      );
    } catch (e) {
      print('Error getting current location: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            onMapCreated: _onMapCreated,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(30.8025, 26.8206),
              ), // Initial position (will be animated)
              zoom: 5.0,
            ),
            styleUri: style,
            textureView: true,
          ),
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  onChangeMapStyle();
                },
                icon: Icon(Icons.layers, size: 30, color: Colors.red),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _zoomIn,
                    icon: Icon(Icons.add, size: 24, color: Colors.black87),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _zoomOut,
                    icon: Icon(Icons.remove, size: 24, color: Colors.black87),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _zoomToCurrentLocation,
                    icon: Icon(Icons.my_location, size: 24, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
