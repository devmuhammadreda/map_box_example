import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Service class to handle all MapBox map operations, including clustering
class MapBoxService {
  MapboxMap? _mapboxMap;
  String _currentStyle = MapboxStyles.STANDARD;

  // Getters
  MapboxMap? get mapboxMap => _mapboxMap;
  String get currentStyle => _currentStyle;

  /// Initialize the map instance
  void initializeMap(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
  }

  /// Update map style configuration (theme, lighting, etc.)
  Future<void> updateMapStyle({
    String lightPreset = 'day',
    String theme = 'faded',
    String colorBuildingHighlight = 'red',
  }) async {
    if (_mapboxMap == null) return;

    try {
      final configs = {
        "lightPreset": lightPreset,
        "theme": theme,
        "colorBuildingHighlight": colorBuildingHighlight,
      };
      await _mapboxMap!.style.setStyleImportConfigProperties(
        "basemap",
        configs,
      );
    } catch (e) {
      log('Error updating map style: $e');
      rethrow;
    }
  }

  /// Toggle between standard and satellite map styles
  Future<void> toggleMapStyle() async {
    if (_mapboxMap == null) return;

    try {
      _currentStyle = _currentStyle == MapboxStyles.STANDARD
          ? MapboxStyles.SATELLITE_STREETS
          : MapboxStyles.STANDARD;
      await _mapboxMap!.loadStyleURI(_currentStyle);
    } catch (e) {
      log('Error toggling map style: $e');
      rethrow;
    }
  }

  /// Change to a specific map style
  Future<void> changeMapStyle(String styleUri) async {
    if (_mapboxMap == null) return;

    try {
      _currentStyle = styleUri;
      await _mapboxMap!.loadStyleURI(styleUri);
    } catch (e) {
      log('Error changing map style: $e');
      rethrow;
    }
  }

  /// Enable location component on the map
  Future<void> enableLocationComponent() async {
    if (_mapboxMap == null) return;

    try {
      await _mapboxMap!.location.updateSettings(
        LocationComponentSettings(enabled: true),
      );
    } catch (e) {
      log('Error enabling location component: $e');
      rethrow;
    }
  }

  /// Animate camera to a specific position
  Future<void> animateToPosition({
    required Point center,
    required double zoom,
    int duration = 1500,
    double? bearing,
    double? pitch,
  }) async {
    if (_mapboxMap == null) return;

    try {
      await _mapboxMap!.easeTo(
        CameraOptions(
          center: center,
          zoom: zoom,
          bearing: bearing,
          pitch: pitch,
        ),
        MapAnimationOptions(duration: duration),
      );
    } catch (e) {
      log('Error animating to position: $e');
      rethrow;
    }
  }

  /// Perform zoom in animation
  Future<void> zoomIn({int duration = 300}) async {
    if (_mapboxMap == null) return;

    try {
      final cameraState = await _mapboxMap!.getCameraState();
      final currentZoom = cameraState.zoom;
      await _mapboxMap!.easeTo(
        CameraOptions(zoom: currentZoom + 1),
        MapAnimationOptions(duration: duration),
      );
    } catch (e) {
      log('Error zooming in: $e');
      rethrow;
    }
  }

  /// Perform zoom out animation
  Future<void> zoomOut({int duration = 300}) async {
    if (_mapboxMap == null) return;

    try {
      final cameraState = await _mapboxMap!.getCameraState();
      final currentZoom = cameraState.zoom;
      await _mapboxMap!.easeTo(
        CameraOptions(zoom: currentZoom - 1),
        MapAnimationOptions(duration: duration),
      );
    } catch (e) {
      log('Error zooming out: $e');
      rethrow;
    }
  }

  /// Set zoom level to a specific value
  Future<void> setZoom(double zoom, {int duration = 300}) async {
    if (_mapboxMap == null) return;

    try {
      await _mapboxMap!.easeTo(
        CameraOptions(zoom: zoom),
        MapAnimationOptions(duration: duration),
      );
    } catch (e) {
      log('Error setting zoom: $e');
      rethrow;
    }
  }

  /// Get current camera state
  Future<CameraState?> getCameraState() async {
    if (_mapboxMap == null) return null;

    try {
      return await _mapboxMap!.getCameraState();
    } catch (e) {
      log('Error getting camera state: $e');
      return null;
    }
  }

  /// Animate camera with a sequence of positions
  Future<void> performAnimationSequence(
    List<CameraAnimation> animations,
  ) async {
    if (_mapboxMap == null) return;

    try {
      for (final animation in animations) {
        await _mapboxMap!.easeTo(
          CameraOptions(
            center: animation.center,
            zoom: animation.zoom,
            bearing: animation.bearing,
            pitch: animation.pitch,
          ),
          MapAnimationOptions(duration: animation.duration),
        );

        if (animation.delayAfter > 0) {
          await Future.delayed(Duration(milliseconds: animation.delayAfter));
        }
      }
    } catch (e) {
      log('Error performing animation sequence: $e');
      rethrow;
    }
  }

  /// Fly to a location with smooth animation
  Future<void> flyTo({
    required Point center,
    required double zoom,
    int duration = 2000,
    double? bearing,
    double? pitch,
  }) async {
    if (_mapboxMap == null) return;

    try {
      await _mapboxMap!.flyTo(
        CameraOptions(
          center: center,
          zoom: zoom,
          bearing: bearing,
          pitch: pitch,
        ),
        MapAnimationOptions(duration: duration),
      );
    } catch (e) {
      log('Error flying to location: $e');
      rethrow;
    }
  }

  /// Set map bounds to fit specific coordinates
  Future<void> fitBounds({
    required Point southwest,
    required Point northeast,
    int duration = 1000,
    MbxEdgeInsets? padding,
  }) async {
    if (_mapboxMap == null) return;

    try {
      final bounds = CoordinateBounds(
        southwest: southwest,
        northeast: northeast,
        infiniteBounds: false,
      );

      final cameraOptions = await _mapboxMap!.cameraForCoordinateBounds(
        bounds,
        padding ?? MbxEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
        null,
        null,
        null,
        null,
      );

      await _mapboxMap!.easeTo(
        cameraOptions,
        MapAnimationOptions(duration: duration),
      );
    } catch (e) {
      log('Error fitting bounds: $e');
      rethrow;
    }
  }

  /// Add a marker/annotation to the map
  Future<void> addAnnotation({
    required Point position,
    String? title,
    Map<String, dynamic>? properties,
  }) async {
    if (_mapboxMap == null) return;

    try {
      final pointAnnotationManager = await _mapboxMap!.annotations
          .createPointAnnotationManager();

      final annotation = PointAnnotationOptions(
        geometry: position,
        textField: title,
        textOffset: [0.0, -2.0],
        textColor: Colors.black.toARGB32(),
        iconSize: 1.5,
      );

      await pointAnnotationManager.create(annotation);
    } catch (e) {
      log('Error adding annotation: $e');
      rethrow;
    }
  }

  /// Reset map to initial state
  Future<void> resetMap({
    required Point initialCenter,
    required double initialZoom,
  }) async {
    if (_mapboxMap == null) return;

    try {
      await animateToPosition(
        center: initialCenter,
        zoom: initialZoom,
        duration: 1000,
      );
    } catch (e) {
      log('Error resetting map: $e');
      rethrow;
    }
  }

  /// Create GeoJSON source for clustering with dynamic points
  Future<void> createClusterSource(
    List<Map<String, dynamic>> points, {
    String sourceId = 'cluster-source',
    double clusterRadius = 50,
    double clusterMaxZoom = 14,
  }) async {
    if (_mapboxMap == null) return;

    try {
      // Validate points format
      if (points.isEmpty) {
        log('No points provided for clustering');
        return;
      }

      // Create GeoJSON data for points
      final features = points.map((point) {
        if (point['coordinates'] is! Position ||
            point['id'] == null ||
            point['title'] == null) {
          throw FormatException('Invalid point format: $point');
        }
        return {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [point['coordinates'].lng, point['coordinates'].lat],
          },
          'properties': {'id': point['id'], 'title': point['title']},
        };
      }).toList();

      final geoJson = {'type': 'FeatureCollection', 'features': features};

      // Add GeoJSON source to the map
      await _mapboxMap!.style.addSource(
        GeoJsonSource(
          id: sourceId,
          data: jsonEncode(geoJson),
          cluster: true,
          clusterMaxZoom: clusterMaxZoom,
          clusterRadius: clusterRadius,
        ),
      );

      // Add unclustered point layer
      final unclusteredLayer = CircleLayer(
        id: 'unclustered-point',
        sourceId: sourceId,
      );
      unclusteredLayer.filter = [
        '!',
        ['has', 'point_count'],
      ];
      await _mapboxMap!.style.addLayer(unclusteredLayer);

      // Add cluster layer
      final clusterLayer = CircleLayer(id: 'clusters', sourceId: sourceId);
      clusterLayer.filter = ['has', 'point_count'];
      await _mapboxMap!.style.addLayer(clusterLayer);

      // Add cluster count layer
      final clusterCountLayer = SymbolLayer(
        id: 'cluster-count',
        sourceId: sourceId,
      );
      clusterCountLayer.filter = ['has', 'point_count'];
      await _mapboxMap!.style.addLayer(clusterCountLayer);

      log('Cluster layers added successfully for source: $sourceId');
    } catch (e) {
      log('Error creating cluster source: $e');
      rethrow;
    }
  }

  /// Handle cluster click
  Future<void> onClusterClick(ScreenCoordinate screenCoordinate) async {
    if (_mapboxMap == null) return;

    try {
      // Get current camera state and zoom in
      final currentCamera = await _mapboxMap!.getCameraState();
      final newZoom = (currentCamera.zoom + 2).clamp(0.0, 20.0);

      await _mapboxMap!.easeTo(
        CameraOptions(zoom: newZoom),
        MapAnimationOptions(duration: 500),
      );

      log('Cluster clicked, zoomed in to $newZoom');
    } catch (e) {
      log('Error handling cluster click: $e');
      rethrow;
    }
  }

  /// Handle single point click
void onPointClick(ScreenCoordinate screenCoordinate) async {
  final features = await _mapboxMap?.queryRenderedFeatures(screenCoordinate, ['unclustered-point']);
  if (features != null && features.isNotEmpty) {
    final title = features.first.properties?['title'] ?? 'Unknown';
    log('Point clicked: $title at ${screenCoordinate.x}, ${screenCoordinate.y}');
    // Optionally, show a popup or dialog with the title
  }
}

  /// Dispose resources
  void dispose() {
    _mapboxMap = null;
  }
}

/// Model class for camera animations
class CameraAnimation {
  final Point? center;
  final double? zoom;
  final double? bearing;
  final double? pitch;
  final int duration;
  final int delayAfter;

  CameraAnimation({
    this.center,
    this.zoom,
    this.bearing,
    this.pitch,
    required this.duration,
    this.delayAfter = 0,
  });
}

/// Predefined camera positions for common locations
class PredefinedLocations {
  // Riyadh coordinates
  static final Point riyadhCenter = Point(
    coordinates: Position(46.6753, 24.7136),
  );

  // Saudi Arabia center coordinates
  static final Point saudiArabiaCenter = Point(
    coordinates: Position(45.0792, 23.8859),
  );

  // Jeddah coordinates
  static final Point jeddahCenter = Point(
    coordinates: Position(39.1925, 21.5433),
  );

  // Mecca coordinates
  static final Point meccaCenter = Point(
    coordinates: Position(39.8579, 21.4225),
  );

  // Medina coordinates
  static final Point medinaCenter = Point(
    coordinates: Position(39.6142, 24.4686),
  );

  // Dammam coordinates
  static final Point dammamCenter = Point(
    coordinates: Position(50.0999, 26.4207),
  );
}
