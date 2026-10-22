import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_constants.dart';

/// Service managing device location permissions and real-time updates
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  final ValueNotifier<LatLng?> currentLocationNotifier =
      ValueNotifier<LatLng?>(null);
  final ValueNotifier<bool> isTrackingNotifier = ValueNotifier<bool>(false);

  /// Request permissions and initialize location tracking
  Future<bool> requestPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[LocationService] Location services are disabled.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('[LocationService] Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint(
          '[LocationService] Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  /// Get current single position with fast lastKnown cache and high-accuracy fix
  Future<LatLng?> getCurrentPosition() async {
    try {
      final bool hasPerm = await requestPermission();
      if (!hasPerm) {
        debugPrint('[LocationService] Location permissions not granted.');
        return null;
      }

      // Fast path: get last known position immediately (< 50ms)
      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final LatLng latLng = LatLng(lastKnown.latitude, lastKnown.longitude);
        currentLocationNotifier.value = latLng;
      }

      // Accurate path: obtain fresh satellite/network GPS fix
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: AppConstants.gpsTimeout,
        ),
      );
      final LatLng latLng = LatLng(position.latitude, position.longitude);
      currentLocationNotifier.value = latLng;
      return latLng;
    } catch (e) {
      debugPrint('[LocationService] Error fetching location: $e');
      try {
        final Position? lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          final LatLng latLng = LatLng(lastKnown.latitude, lastKnown.longitude);
          currentLocationNotifier.value = latLng;
          return latLng;
        }
      } catch (_) {}
    }
    return currentLocationNotifier.value;
  }

  /// Start continuous background / foreground position streaming
  Future<void> startLocationUpdates({
    required void Function(LatLng position, double speed) onUpdate,
  }) async {
    final bool hasPerm = await requestPermission();
    if (!hasPerm) {
      debugPrint('[LocationService] Cannot start tracking without permission');
      return;
    }

    await _positionSubscription?.cancel();
    isTrackingNotifier.value = true;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: AppConstants.gpsDistanceFilterMeters,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        final LatLng latLng = LatLng(position.latitude, position.longitude);
        currentLocationNotifier.value = latLng;
        onUpdate(latLng, position.speed);
      },
      onError: (Object e) {
        debugPrint('[LocationService] Stream error: $e');
      },
    );
  }

  /// Stop listening to updates
  Future<void> stopLocationUpdates() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    isTrackingNotifier.value = false;
  }
}
