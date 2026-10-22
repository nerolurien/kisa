import 'package:flutter/foundation.dart';

@immutable
class KisaUser {
  final String id;
  final String email;
  final String name;
  final String? partnerId;
  final String? avatarUrl;
  final String pairingCode;
  final String currentStatus;
  final String statusEmoji;
  final DateTime? statusUpdatedAt;
  final String bio;
  final DateTime? anniversaryDate;
  final DateTime createdAt;

  const KisaUser({
    required this.id,
    required this.email,
    required this.name,
    this.partnerId,
    this.avatarUrl,
    required this.pairingCode,
    this.currentStatus = 'Lagi santai ✨',
    this.statusEmoji = '✨',
    this.statusUpdatedAt,
    this.bio = 'Menciptakan cerita indah berdua ✨',
    this.anniversaryDate,
    required this.createdAt,
  });

  bool get isPaired => partnerId != null && partnerId!.isNotEmpty;

  int get daysTogether {
    final start = anniversaryDate ?? createdAt;
    final diff = DateTime.now().difference(start).inDays;
    return diff < 0 ? 0 : diff + 1;
  }

  KisaUser copyWith({
    String? id,
    String? email,
    String? name,
    String? partnerId,
    String? avatarUrl,
    String? pairingCode,
    String? currentStatus,
    String? statusEmoji,
    DateTime? statusUpdatedAt,
    String? bio,
    DateTime? anniversaryDate,
    DateTime? createdAt,
  }) {
    return KisaUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      partnerId: partnerId ?? this.partnerId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      pairingCode: pairingCode ?? this.pairingCode,
      currentStatus: currentStatus ?? this.currentStatus,
      statusEmoji: statusEmoji ?? this.statusEmoji,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      bio: bio ?? this.bio,
      anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory KisaUser.fromJson(Map<String, dynamic> json) {
    return KisaUser(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'Kip',
      partnerId: json['partner_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      pairingCode: (json['pairing_code'] as String?) ?? 'KISA-01',
      currentStatus: (json['current_status'] as String?) ?? 'Lagi santai ✨',
      statusEmoji: (json['status_emoji'] as String?) ?? '✨',
      statusUpdatedAt: json['status_updated_at'] != null
          ? DateTime.tryParse(json['status_updated_at'] as String)
          : null,
      bio: (json['bio'] as String?) ?? 'Menciptakan cerita indah berdua ✨',
      anniversaryDate: json['anniversary_date'] != null
          ? DateTime.tryParse(json['anniversary_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'partner_id': partnerId,
      'avatar_url': avatarUrl,
      'pairing_code': pairingCode,
      'current_status': currentStatus,
      'status_emoji': statusEmoji,
      'status_updated_at': statusUpdatedAt?.toIso8601String(),
      'bio': bio,
      'anniversary_date': anniversaryDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KisaUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          partnerId == other.partnerId &&
          currentStatus == other.currentStatus &&
          statusEmoji == other.statusEmoji &&
          bio == other.bio &&
          anniversaryDate == other.anniversaryDate;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      partnerId.hashCode ^
      currentStatus.hashCode ^
      statusEmoji.hashCode ^
      bio.hashCode ^
      anniversaryDate.hashCode;

  @override
  String toString() => 'KisaUser(id: $id, name: $name, partnerId: $partnerId)';
}
