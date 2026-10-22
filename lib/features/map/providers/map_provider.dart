import '../../../core/constants/app_constants.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Haversine;
import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/supabase_client.dart';
import '../../../core/utils/haversine.dart';
import '../models/kisa_location.dart';

class MapState {
  final LatLng myLocation;
  final bool hasRealGps;
  final KisaLocation? partnerLocation;
  final double? distanceInKm;
  final bool isTracking;
  final bool isLoading;
  final String? lastPokeMessage;
  final DateTime? lastPokeTime;
  final bool isWithinProximity; // true if within 100 meters
  final bool showProximityBanner; // controls in-app top banner
  final int? proximityMeters; // exact distance in meters when close

  const MapState({
    required this.myLocation,
    this.hasRealGps = false,
    this.partnerLocation,
    this.distanceInKm,
    this.isTracking = false,
    this.isLoading = false,
    this.lastPokeMessage,
    this.lastPokeTime,
    this.isWithinProximity = false,
    this.showProximityBanner = false,
    this.proximityMeters,
  });

  String get distanceText {
    final partnerName = partnerLocation?.userName ?? 'Fexa';
    return KisaHaversine.formatPartnerDistance(distanceInKm, partnerName);
  }

  MapState copyWith({
    LatLng? myLocation,
    bool? hasRealGps,
    KisaLocation? partnerLocation,
    double? distanceInKm,
    bool? isTracking,
    bool? isLoading,
    String? lastPokeMessage,
    DateTime? lastPokeTime,
    bool? isWithinProximity,
    bool? showProximityBanner,
    int? proximityMeters,
  }) {
    return MapState(
      myLocation: myLocation ?? this.myLocation,
      hasRealGps: hasRealGps ?? this.hasRealGps,
      partnerLocation: partnerLocation ?? this.partnerLocation,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      isTracking: isTracking ?? this.isTracking,
      isLoading: isLoading ?? this.isLoading,
      lastPokeMessage: lastPokeMessage ?? this.lastPokeMessage,
      lastPokeTime: lastPokeTime ?? this.lastPokeTime,
      isWithinProximity: isWithinProximity ?? this.isWithinProximity,
      showProximityBanner: showProximityBanner ?? this.showProximityBanner,
      proximityMeters: proximityMeters ?? this.proximityMeters,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  final LocationService _locationService;
  final KisaSupabaseClient _supabaseClient;
  StreamSubscription<KisaLocation?>? _partnerLocationSub;

  DateTime? _lastProximityAlertTime;
  bool _hasAlertedForCurrentEncounter = false;

  MapNotifier(this._locationService, this._supabaseClient)
      : super(const MapState(
          myLocation:
              LatLng(-6.2088, 106.8456), // Jakarta fallback until GPS loads
        )) {
    initMap();
  }

  void _evaluateProximity(double? distKm, String partnerName) {
    if (distKm == null) return;
    final meters = (distKm * 1000).round();
    final now = DateTime.now();

    // Trigger proximity alert if within 100 meters
    if (meters <= AppConstants.proximityThresholdMeters) {
      final bool shouldAlert = !_hasAlertedForCurrentEncounter ||
          _lastProximityAlertTime == null ||
          now.difference(_lastProximityAlertTime!) >
              AppConstants.proximityCooldown;

      if (shouldAlert) {
        _hasAlertedForCurrentEncounter = true;
        _lastProximityAlertTime = now;
        HapticFeedback.heavyImpact();
        NotificationService().showProximityAlert(
          partnerName: partnerName,
          distanceMeters: meters,
        );
        state = state.copyWith(
          isWithinProximity: true,
          showProximityBanner: true,
          proximityMeters: meters,
        );
      } else {
        state = state.copyWith(
          isWithinProximity: true,
          proximityMeters: meters,
        );
      }
    } else if (meters > AppConstants.proximityResetMeters) {
      // Reset trigger once partner moves past 200m away
      _hasAlertedForCurrentEncounter = false;
      if (state.isWithinProximity || state.showProximityBanner) {
        state = state.copyWith(
          isWithinProximity: false,
          showProximityBanner: false,
          proximityMeters: null,
        );
      }
    }
  }

  void dismissProximityBanner() {
    state = state.copyWith(showProximityBanner: false);
  }

  /// Simulate proximity (< 100m) for instant user testing
  void simulateProximityForTesting({int meters = 45}) {
    final partnerName = state.partnerLocation?.userName ?? 'Fexa';
    _hasAlertedForCurrentEncounter = true;
    _lastProximityAlertTime = DateTime.now();
    HapticFeedback.heavyImpact();
    NotificationService().showProximityAlert(
      partnerName: partnerName,
      distanceMeters: meters,
    );
    state = state.copyWith(
      distanceInKm: meters / 1000.0,
      isWithinProximity: true,
      showProximityBanner: true,
      proximityMeters: meters,
    );
  }

  Future<void> initMap() async {
    state = state.copyWith(isLoading: true);
    final myPos = await _locationService.getCurrentPosition();
    var partnerLoc = await _supabaseClient.getPartnerLocation();

    LatLng userLoc = state.myLocation;
    bool realGps = state.hasRealGps;

    if (myPos != null) {
      userLoc = myPos;
      realGps = true;
    }

    // In demo mode, if we have the user's real GPS, place simulated Fexa nearby (~1.2 km away)
    if (!_supabaseClient.isLiveSupabase && realGps) {
      partnerLoc = KisaLocation(
        id: 'loc_01',
        userId: 'usr_fexa_02',
        userName: 'Fexa',
        avatarUrl:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
        latitude: userLoc.latitude + 0.0082,
        longitude: userLoc.longitude + 0.0076,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      );
    }

    double? dist;
    if (partnerLoc != null) {
      dist = KisaHaversine.calculateDistanceKm(
        lat1: userLoc.latitude,
        lon1: userLoc.longitude,
        lat2: partnerLoc.latitude,
        lon2: partnerLoc.longitude,
      );
    }

    state = state.copyWith(
      myLocation: userLoc,
      hasRealGps: realGps,
      partnerLocation: partnerLoc,
      distanceInKm: dist,
      isLoading: false,
    );

    final partnerName = partnerLoc?.userName ?? 'Fexa';
    _evaluateProximity(dist, partnerName);

    if (_supabaseClient.isLiveSupabase &&
        partnerLoc != null &&
        partnerLoc.userId.isNotEmpty) {
      _subscribeToPartnerLocation(partnerLoc.userId);
    }

    // Start background & live location tracking stream
    _startTracking();
  }

  Future<void> refreshLocation() async {
    state = state.copyWith(isLoading: true);
    final myPos = await _locationService.getCurrentPosition();
    if (myPos != null) {
      var partnerLoc = state.partnerLocation;
      if (!_supabaseClient.isLiveSupabase) {
        partnerLoc = KisaLocation(
          id: 'loc_01',
          userId: 'usr_fexa_02',
          userName: 'Fexa',
          avatarUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
          latitude: myPos.latitude + 0.0082,
          longitude: myPos.longitude + 0.0076,
          updatedAt: DateTime.now(),
        );
      }
      double? dist;
      if (partnerLoc != null) {
        dist = KisaHaversine.calculateDistanceKm(
          lat1: myPos.latitude,
          lon1: myPos.longitude,
          lat2: partnerLoc.latitude,
          lon2: partnerLoc.longitude,
        );
      }
      state = state.copyWith(
        myLocation: myPos,
        hasRealGps: true,
        partnerLocation: partnerLoc,
        distanceInKm: dist,
        isLoading: false,
      );

      final partnerName = partnerLoc?.userName ?? 'Fexa';
      _evaluateProximity(dist, partnerName);

      if (_supabaseClient.isLiveSupabase) {
        await _supabaseClient.updateMyLocation(
          latitude: myPos.latitude,
          longitude: myPos.longitude,
        );
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void _subscribeToPartnerLocation(String partnerId) {
    _partnerLocationSub?.cancel();
    _partnerLocationSub =
        _supabaseClient.streamPartnerLocation(partnerId).listen((newLoc) {
      if (newLoc != null) {
        final dist = KisaHaversine.calculateDistanceKm(
          lat1: state.myLocation.latitude,
          lon1: state.myLocation.longitude,
          lat2: newLoc.latitude,
          lon2: newLoc.longitude,
        );
        state = state.copyWith(partnerLocation: newLoc, distanceInKm: dist);
        final partnerName = newLoc.userName;
        _evaluateProximity(dist, partnerName);
      }
    });
  }

  void _startTracking() {
    _locationService.startLocationUpdates(
      onUpdate: (LatLng newPos, double speed) {
        var partnerLoc = state.partnerLocation;
        if (!_supabaseClient.isLiveSupabase &&
            (!state.hasRealGps || partnerLoc == null)) {
          partnerLoc = KisaLocation(
            id: 'loc_01',
            userId: 'usr_fexa_02',
            userName: 'Fexa',
            avatarUrl:
                'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
            latitude: newPos.latitude + 0.0082,
            longitude: newPos.longitude + 0.0076,
            updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
          );
        }

        double? dist;
        if (partnerLoc != null) {
          dist = KisaHaversine.calculateDistanceKm(
            lat1: newPos.latitude,
            lon1: newPos.longitude,
            lat2: partnerLoc.latitude,
            lon2: partnerLoc.longitude,
          );
        }

        state = state.copyWith(
          myLocation: newPos,
          hasRealGps: true,
          partnerLocation: partnerLoc,
          distanceInKm: dist,
          isTracking: true,
        );

        final partnerName = partnerLoc?.userName ?? 'Fexa';
        _evaluateProximity(dist, partnerName);

        if (_supabaseClient.isLiveSupabase) {
          _supabaseClient.updateMyLocation(
            latitude: newPos.latitude,
            longitude: newPos.longitude,
          );
        }
      },
    );
  }

  void sendLovePoke() {
    final name = state.partnerLocation?.userName ?? 'Fexa';
    state = state.copyWith(
      lastPokeMessage: 'Mengirim pelukan hangat ke $name ❤️',
      lastPokeTime: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _partnerLocationSub?.cancel();
    _locationService.stopLocationUpdates();
    super.dispose();
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier(LocationService(), KisaSupabaseClient());
});
