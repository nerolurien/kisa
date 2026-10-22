import 'package:flutter/foundation.dart';

@immutable
class KisaLocation {
  final String id;
  final String userId;
  final String userName;
  final String? avatarUrl;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const KisaLocation({
    required this.id,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  KisaLocation copyWith({
    String? id,
    String? userId,
    String? userName,
    String? avatarUrl,
    double? latitude,
    double? longitude,
    DateTime? updatedAt,
  }) {
    return KisaLocation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory KisaLocation.fromJson(Map<String, dynamic> json) {
    return KisaLocation(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      userName: (json['user_name'] as String?) ??
          (json['users'] != null ? json['users']['name'] as String? : null) ??
          'Partner',
      avatarUrl: (json['avatar_url'] as String?) ??
          (json['users'] != null
              ? json['users']['avatar_url'] as String?
              : null),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KisaLocation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode =>
      id.hashCode ^ userId.hashCode ^ latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() =>
      'KisaLocation(userId: $userId, lat: $latitude, lng: $longitude)';
}
