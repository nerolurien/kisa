import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../core/widgets/avatar_marker.dart';
import '../providers/map_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/distance_bottom_sheet.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen> {
  final MapController _mapController = MapController();
  bool _hasInitialCentered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapState = ref.read(mapProvider);
      if (mapState.hasRealGps) {
        _hasInitialCentered = true;
        final partnerPos = mapState.partnerLocation != null
            ? LatLng(mapState.partnerLocation!.latitude,
                mapState.partnerLocation!.longitude)
            : null;
        _centerOnCouple(mapState.myLocation, partnerPos);
      }
    });
  }

  void _centerOnCouple(LatLng myPos, LatLng? partnerPos) {
    if (partnerPos != null) {
      final centerLat = (myPos.latitude + partnerPos.latitude) / 2;
      final centerLng = (myPos.longitude + partnerPos.longitude) / 2;
      _mapController.move(LatLng(centerLat, centerLng), 14.0);
    } else {
      _mapController.move(myPos, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MapState>(mapProvider, (prev, next) {
      if (!_hasInitialCentered && next.hasRealGps) {
        _hasInitialCentered = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final partnerPos = next.partnerLocation != null
              ? LatLng(next.partnerLocation!.latitude,
                  next.partnerLocation!.longitude)
              : null;
          _centerOnCouple(next.myLocation, partnerPos);
        });
      }
    });

    final mapState = ref.watch(mapProvider);
    final authState = ref.watch(authProvider);

    final myLocation = mapState.myLocation;
    final partnerLocation = mapState.partnerLocation != null
        ? LatLng(mapState.partnerLocation!.latitude,
            mapState.partnerLocation!.longitude)
        : null;

    final myName = authState.user?.name ?? 'Kip';
    final partnerName = mapState.partnerLocation?.userName ?? 'Fexa';

    return Scaffold(
      backgroundColor: KisaColors.background,
      body: Stack(
        children: [
          // FlutterMap with CartoDB Positron pastel clean tiles (no POI clutter per PRD 3.D)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: myLocation,
              initialZoom: 14.0,
              minZoom: 4,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.kipit_apk',
                maxZoom: 19,
              ),
              // Dashed connecting line between Kip & Pipit
              if (partnerLocation != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [myLocation, partnerLocation],
                      strokeWidth: 3.0,
                      color: KisaColors.primaryRose.withValues(alpha: 0.7),
                      pattern: StrokePattern.dashed(segments: const [9, 6]),
                    ),
                  ],
                ),
              // Custom Markers (Avatar/Inisial per PRD 3.D)
              MarkerLayer(
                markers: [
                  Marker(
                    point: myLocation,
                    width: 110,
                    height: 96,
                    alignment: Alignment.topCenter,
                    child: AvatarMarker(
                      name: myName,
                      avatarUrl: authState.user?.avatarUrl,
                      radius: 24,
                      statusText: authState.user?.currentStatus,
                      statusEmoji: authState.user?.statusEmoji,
                    ),
                  ),
                  if (partnerLocation != null)
                    Marker(
                      point: partnerLocation,
                      width: 110,
                      height: 96,
                      alignment: Alignment.topCenter,
                      child: AvatarMarker(
                        name: partnerName,
                        avatarUrl: mapState.partnerLocation?.avatarUrl,
                        radius: 24,
                        isPartner: true,
                        statusText: authState.partner?.currentStatus,
                        statusEmoji: authState.partner?.statusEmoji,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Floating Top Header
          SafeArea(
            child: Column(
              children: [
                CustomHeader(
                  title: 'Lokasi Kita',
                  subtitle: mapState.hasRealGps
                      ? (mapState.isTracking
                          ? 'GPS Real-time Aktif ⚡'
                          : 'Lokasi Akurat 📍')
                      : (mapState.isLoading
                          ? 'Mencari sinyal GPS...'
                          : 'Peace of Mind GPS'),
                  trailing: BouncyButton.glass(
                    onTap: () {
                      ref.read(mapProvider.notifier).refreshLocation();
                      _centerOnCouple(myLocation, partnerLocation);
                      showKisaToast(
                        context,
                        message: 'Lokasi disinkronkan ke GPS sekarang 📍',
                        icon: Icons.gps_fixed_rounded,
                      );
                    },
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      mapState.isLoading
                          ? Icons.sync_rounded
                          : Icons.my_location_rounded,
                      size: 20,
                      color: KisaColors.primaryRose,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Haversine Distance Bottom Sheet (PRD 3.D)
          Positioned(
            left: 24,
            right: 24,
            bottom: 120,
            child: DistanceBottomSheet(
              partnerLocation: mapState.partnerLocation,
              distanceText: mapState.distanceText,
              partnerStatus: authState.partner?.currentStatus,
              partnerEmoji: authState.partner?.statusEmoji,
              isWithinProximity: mapState.isWithinProximity,
              onTestProximity: () {
                ref
                    .read(mapProvider.notifier)
                    .simulateProximityForTesting(meters: 45);
                showKisaToast(
                  context,
                  message: 'Simulasi: $partnerName berada 45m didekatmu! 🔔',
                  icon: Icons.notifications_active_rounded,
                );
              },
              onSendLovePoke: () {
                ref.read(mapProvider.notifier).sendLovePoke();
                showKisaToast(
                  context,
                  message: 'Pelukan cinta terkirim ke $partnerName ❤️',
                  icon: Icons.favorite_rounded,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
