import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Haversine;
import '../../../core/services/location_service.dart';
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

  const MapState({
    required this.myLocation,
    this.hasRealGps = false,
    this.partnerLocation,
    this.distanceInKm,
    this.isTracking = false,
    this.isLoading = false,
    this.lastPokeMessage,
    this.lastPokeTime,
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
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  final LocationService _locationService;
  final KisaSupabaseClient _supabaseClient;
  StreamSubscription<KisaLocation?>? _partnerLocationSub;

  MapNotifier(this._locationService, this._supabaseClient)
      : super(const MapState(
          myLocation: LatLng(-6.2088, 106.8456), // Jakarta fallback until GPS loads
        )) {
    initMap();
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
    // so the couple distance & line are displayed in the user's actual neighborhood
    if (!_supabaseClient.isLiveSupabase && realGps) {
      partnerLoc = KisaLocation(
        id: 'loc_01',
        userId: 'usr_fexa_02',
        userName: 'Fexa',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
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

    if (_supabaseClient.isLiveSupabase && partnerLoc != null && partnerLoc.userId.isNotEmpty) {
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
          avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
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
    _partnerLocationSub = _supabaseClient.streamPartnerLocation(partnerId).listen((newLoc) {
      if (newLoc != null) {
        final dist = KisaHaversine.calculateDistanceKm(
          lat1: state.myLocation.latitude,
          lon1: state.myLocation.longitude,
          lat2: newLoc.latitude,
          lon2: newLoc.longitude,
        );
        state = state.copyWith(partnerLocation: newLoc, distanceInKm: dist);
      }
    });
  }

  void _startTracking() {
    _locationService.startLocationUpdates(
      onUpdate: (LatLng newPos, double speed) {
        var partnerLoc = state.partnerLocation;
        if (!_supabaseClient.isLiveSupabase && (!state.hasRealGps || partnerLoc == null)) {
          partnerLoc = KisaLocation(
            id: 'loc_01',
            userId: 'usr_fexa_02',
            userName: 'Fexa',
            avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
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
