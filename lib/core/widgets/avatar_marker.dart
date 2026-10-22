import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Custom marker on the map
class AvatarMarker extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isPartner;
  final double radius;
  final String? statusText;
  final String? statusEmoji;

  const AvatarMarker({
    super.key,
    required this.name,
    this.avatarUrl,
    this.isPartner = false,
    this.radius = 24.0,
    this.statusText,
    this.statusEmoji,
  });

  String get _initials {
    if (name.trim().isEmpty) return '?';
    return name.trim().substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Live Activity Speech Bubble (if set)
        if (statusText != null && statusText!.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 3),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color:
                  isPartner ? KisaColors.primaryRose : const Color(0xFF334155),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${statusEmoji ?? '✨'} $statusText',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],

        // Name pill tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: KisaColors.surfaceGlass,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (isPartner
                        ? KisaColors.primaryRose
                        : KisaColors.textPrimary)
                    .withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: isPartner ? KisaColors.primaryRose : KisaColors.sage,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: KisaTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: KisaColors.textPrimary,
                  fontSize: 10,
                ),
              ),
              if (statusEmoji != null && statusText == null) ...[
                const SizedBox(width: 3),
                Text(statusEmoji!, style: const TextStyle(fontSize: 10)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 3),

        // Glowing Avatar Ring
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isPartner
                ? KisaColors.loveGradient
                : KisaColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: (isPartner ? KisaColors.primaryRose : KisaColors.sage)
                    .withValues(alpha: 0.35),
                blurRadius: 14,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: KisaColors.surface,
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackInitials(),
                    )
                  : _buildFallbackInitials(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackInitials() {
    return Container(
      color: isPartner ? KisaColors.blushMedium : KisaColors.backgroundWarm,
      child: Center(
        child: Text(
          _initials,
          style: KisaTypography.titleMedium.copyWith(
            color: isPartner ? KisaColors.primaryRose : KisaColors.sage,
            fontWeight: FontWeight.w800,
            fontSize: radius * 0.75,
          ),
        ),
      ),
    );
  }
}
