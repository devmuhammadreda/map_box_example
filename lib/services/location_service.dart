import 'package:geolocator/geolocator.dart';
import 'permission_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final PermissionService _permissionService = PermissionService();

  /// Get current location with default settings
  Future<Position> getCurrentLocation() async {
    try {
      // Check permissions first
      final hasPermission = await _permissionService.handleLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission required');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      return position;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current location with custom settings
  Future<Position> getCurrentLocationWithSettings({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    try {
      // Check permissions first
      final hasPermission = await _permissionService.handleLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission required');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeLimit,
        ),
      );

      return position;
    } catch (e) {
      rethrow;
    }
  }

  /// Get last known location (faster but might be outdated)
  Future<Position?> getLastKnownLocation() async {
    try {
      final hasPermission = await _permissionService.hasLocationPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  /// Listen to location changes (real-time tracking)
  Stream<Position> getLocationStream({LocationSettings? locationSettings}) {
    final settings =
        locationSettings ??
        const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        );

    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// Listen to location changes with permission check
  Stream<Position> getLocationStreamWithPermissionCheck({
    LocationSettings? locationSettings,
  }) async* {
    try {
      final hasPermission = await _permissionService.handleLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission required');
      }

      yield* getLocationStream(locationSettings: locationSettings);
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate distance between two positions in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate bearing between two positions
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Format position as readable string
  String formatPosition(Position position) {
    return 'Lat: ${position.latitude.toStringAsFixed(6)}, '
        'Lng: ${position.longitude.toStringAsFixed(6)}, '
        'Accuracy: ${position.accuracy.toStringAsFixed(2)}m';
  }

  /// Get location accuracy description
  String getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return 'Lowest accuracy (~500m)';
      case LocationAccuracy.low:
        return 'Low accuracy (~500m)';
      case LocationAccuracy.medium:
        return 'Medium accuracy (~100-500m)';
      case LocationAccuracy.high:
        return 'High accuracy (~0-100m)';
      case LocationAccuracy.best:
        return 'Best accuracy (~0-100m)';
      case LocationAccuracy.bestForNavigation:
        return 'Best for navigation (~0-100m)';
      default:
        return 'Unknown accuracy';
    }
  }

  /// Check if position is within a certain radius of another position
  bool isWithinRadius(Position center, Position target, double radiusInMeters) {
    final distance = calculateDistance(
      center.latitude,
      center.longitude,
      target.latitude,
      target.longitude,
    );
    return distance <= radiusInMeters;
  }
}
