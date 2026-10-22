import 'package:flutter/foundation.dart';

@immutable
class KisaActivity {
  final String id;
  final String userId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String moodEmoji;
  final String? photoUrl;
  final String? locationTag;
  final int likesCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  const KisaActivity({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.moodEmoji = '✨',
    this.photoUrl,
    this.locationTag,
    this.likesCount = 0,
    this.isLikedByMe = false,
    required this.createdAt,
  });

  KisaActivity copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? authorAvatar,
    String? content,
    String? moodEmoji,
    String? photoUrl,
    String? locationTag,
    int? likesCount,
    bool? isLikedByMe,
    DateTime? createdAt,
  }) {
    return KisaActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      moodEmoji: moodEmoji ?? this.moodEmoji,
      photoUrl: photoUrl ?? this.photoUrl,
      locationTag: locationTag ?? this.locationTag,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory KisaActivity.fromJson(Map<String, dynamic> json,
      {String? currentUserId}) {
    final dynamic likesData = json['likes'];
    final List<dynamic> likes = likesData is List ? likesData : [];
    final bool isLiked = currentUserId != null && likes.contains(currentUserId);

    return KisaActivity(
      id: json['id'] as String,
      userId: (json['user_id'] as String?) ?? '',
      authorName: (json['author_name'] as String?) ??
          (json['users'] != null ? json['users']['name'] as String? : null) ??
          'Kip',
      authorAvatar: (json['author_avatar'] as String?) ??
          (json['users'] != null
              ? json['users']['avatar_url'] as String?
              : null),
      content: (json['content'] as String?) ?? '',
      moodEmoji: (json['mood_emoji'] as String?) ?? '✨',
      photoUrl: json['photo_url'] as String?,
      locationTag: json['location_tag'] as String?,
      likesCount: (json['likes_count'] as int?) ?? likes.length,
      isLikedByMe: (json['is_liked_by_me'] as bool?) ?? isLiked,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'mood_emoji': moodEmoji,
      'photo_url': photoUrl,
      'location_tag': locationTag,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KisaActivity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          content == other.content &&
          moodEmoji == other.moodEmoji &&
          likesCount == other.likesCount &&
          isLikedByMe == other.isLikedByMe;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      content.hashCode ^
      moodEmoji.hashCode ^
      likesCount.hashCode ^
      isLikedByMe.hashCode;

  @override
  String toString() =>
      'KisaActivity(id: $id, author: $authorName, likes: $likesCount)';
}
