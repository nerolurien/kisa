import 'dart:math' as math;

/// Haversine spherical distance calculation between two GPS coordinates
class KisaHaversine {
  static const double earthRadiusKm = 6371.0;

  /// Calculate distance between two lat/lng points in kilometers
  static double calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rLat1) * math.cos(rLat2) * math.sin(dLon / 2) * math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Formatted string as specified in PRD 3.D
  /// e.g. "Pipit berjarak 4.2 km dari lokasimu"
  static String formatPartnerDistance(double? distanceKm, String partnerName) {
    if (distanceKm == null) {
      return 'Menghubungkan lokasi $partnerName...';
    }
    if (distanceKm < 0.05) {
      return '$partnerName ada di sampingmu right now ❤️';
    }
    if (distanceKm < 1.0) {
      final meters = (distanceKm * 1000).round();
      return '$partnerName berjarak $meters meter dari lokasimu';
    }
    return '$partnerName berjarak ${distanceKm.toStringAsFixed(1)} km dari lokasimu';
  }

  static double _toRadians(double degree) {
    return degree * math.pi / 180.0;
  }
}
