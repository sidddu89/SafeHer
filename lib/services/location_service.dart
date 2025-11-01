import 'dart:async';
import 'dart:io' show Platform;

import 'package:geolocator/geolocator.dart';

/// A GPS-focused location helper that works offline.
/// - On Android, forces the legacy LocationManager (GPS provider) via forceLocationManager.
/// - Uses high accuracy suitable for navigation.
/// - Provides sensible timeouts and utility methods for permissions/services.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Ensure location services are enabled (GPS on). Returns true if enabled.
  Future<bool> ensureServiceEnabled() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }

  /// Request location permission if not granted. Returns true if granted (WhileInUse or Always).
  Future<bool> ensurePermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final granted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    return granted;
  }

  /// Get a single high-accuracy GPS fix with a timeout.
  /// If services/permissions are missing, throws a descriptive exception.
  /// Enhanced for Samsung devices with power management optimizations.
  Future<Position> getCurrentPositionGpsOnly({
    Duration timeLimit = const Duration(seconds: 60),
  }) async {
    if (!await ensureServiceEnabled()) {
      throw StateError('Location services (GPS) are disabled. Please enable GPS.');
    }
    if (!await ensurePermissionGranted()) {
      throw StateError('Location permission not granted.');
    }

    final desiredAccuracy = LocationAccuracy.bestForNavigation;

    // Platform-specific settings optimized for Samsung and other Android devices
    final locationSettings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: desiredAccuracy,
            forceLocationManager: true, // Prefer GPS provider over fused/network
            intervalDuration: const Duration(milliseconds: 500), // Faster updates for Samsung
            distanceFilter: 0, // Accept any movement for emergency situations
          )
        : AppleSettings(
            accuracy: desiredAccuracy,
            activityType: ActivityType.otherNavigation,
            allowBackgroundLocationUpdates: false,
            pauseLocationUpdatesAutomatically: true,
          );

    // Try last known as a quick optimistic read first
    Position? last = await Geolocator.getLastKnownPosition();

    try {
      // Strategy 1: Try position stream (works better on Samsung devices)
      final live = await Geolocator
          .getPositionStream(locationSettings: locationSettings)
          .first
          .timeout(timeLimit);
      return live;
    } on TimeoutException {
      // Strategy 2: If stream times out, try direct getCurrentPosition with network assistance
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: (timeLimit.inSeconds * 0.7).round()), // Use 70% of remaining time
        );
        return position;
      } catch (e) {
        // Strategy 3: If direct call fails, return last known if available
        if (last != null) {
          return last;
        }
        rethrow;
      }
    } catch (e) {
      // Strategy 4: Fallback to basic getCurrentPosition without forcing GPS
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        );
        return position;
      } catch (e2) {
        // Strategy 5: Return last known position if all else fails
        if (last != null) {
          return last;
        }
        rethrow;
      }
    }
  }

  /// Stream of high-accuracy GPS positions. Caller should cancel subscription when done.
  Stream<Position> getPositionStreamGpsOnly({
    int distanceFilterMeters = 10,
  }) {
    final desiredAccuracy = LocationAccuracy.bestForNavigation;

    final locationSettings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: desiredAccuracy,
            forceLocationManager: true,
            distanceFilter: distanceFilterMeters,
            intervalDuration: const Duration(seconds: 2),
          )
        : AppleSettings(
            accuracy: desiredAccuracy,
            activityType: ActivityType.otherNavigation,
            pauseLocationUpdatesAutomatically: true,
            distanceFilter: distanceFilterMeters,
            allowBackgroundLocationUpdates: false,
          );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  /// Open the device's location settings screen.
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings to grant permissions.
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
