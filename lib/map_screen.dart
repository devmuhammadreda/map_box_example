import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;
  String style = MapboxStyles.STANDARD;
  void onChangeMapStyle() {
    setState(() {
      style = style == MapboxStyles.STANDARD
          ? MapboxStyles.SATELLITE_STREETS
          : MapboxStyles.STANDARD;
    });
    // Update the map style immediately after state change
    if (mapboxMap != null) {
      mapboxMap!.loadStyleURI(style);
    }
  }

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    _updateMapStyle();
    mapboxMap.location.updateSettings(LocationComponentSettings(enabled: true));
  }

  void _updateMapStyle() {
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
    bool serviceEnabled;
    geo.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions.',
          ),
        ),
      );
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      mapboxMap?.easeTo(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 15.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
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
              center: Point(coordinates: Position(30.8025, 26.8206)),
              zoom: 5.0,
            ),
            styleUri: style,
            textureView: true,
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              onPressed: () {
                onChangeMapStyle();
              },
              icon: Icon(Icons.layers, size: 30, color: Colors.red),
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
