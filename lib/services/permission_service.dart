import 'package:geolocator/geolocator.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location permission status
  Future<LocationPermission> getLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission from user
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Check if we have permission to access location
  Future<bool> hasLocationPermission() async {
    final permission = await getLocationPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Handle complete permission flow
  /// Returns true if permission is granted, false otherwise
  Future<bool> handleLocationPermission() async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        throw Exception(
          'Location services are disabled. Please enable location services in settings.',
        );
      }

      LocationPermission permission = await getLocationPermission();

      // If permission is denied, request it
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
      }

      // Handle different permission states
      switch (permission) {
        case LocationPermission.denied:
          throw Exception(
            'Location permission denied. Please grant location access to use this feature.',
          );

        case LocationPermission.deniedForever:
          throw Exception(
            'Location permission permanently denied. Please enable location access in app settings.',
          );

        case LocationPermission.whileInUse:
        case LocationPermission.always:
          return true;

        default:
          throw Exception('Unknown location permission state.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Open app settings (useful when permission is denied forever)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings (useful when location services are disabled)
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Get permission status as human readable string
  String getPermissionStatusText(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Location access denied';
      case LocationPermission.deniedForever:
        return 'Location access permanently denied';
      case LocationPermission.whileInUse:
        return 'Location access granted while app is in use';
      case LocationPermission.always:
        return 'Location access always granted';
      default:
        return 'Unknown permission status';
    }
  }
}
