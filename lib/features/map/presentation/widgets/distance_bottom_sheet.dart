import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bouncy_button.dart';
import '../../../../core/widgets/glassy_container.dart';
import '../../../../core/widgets/avatar_marker.dart';
import '../../models/kisa_location.dart';

class DistanceBottomSheet extends StatelessWidget {
  final KisaLocation? partnerLocation;
  final String distanceText;
  final VoidCallback onSendLovePoke;
  final String? partnerStatus;
  final String? partnerEmoji;
  final bool isWithinProximity;
  final VoidCallback? onTestProximity;

  const DistanceBottomSheet({
    super.key,
    required this.partnerLocation,
    required this.distanceText,
    required this.onSendLovePoke,
    this.partnerStatus,
    this.partnerEmoji,
    this.isWithinProximity = false,
    this.onTestProximity,
  });

  String _formatUpdatedTime(DateTime? dt) {
    if (dt == null) return 'Baru saja';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    return '${diff.inHours} jam lalu';
  }

  @override
  Widget build(BuildContext context) {
    final partner = partnerLocation;
    final partnerName = partner?.userName ?? 'Fexa';

    return GlassyContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 30,
      shadows: KisaShadows.floating,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AvatarMarker(
                name: partnerName,
                avatarUrl: partner?.avatarUrl,
                radius: 22,
                isPartner: true,
                statusEmoji: partnerEmoji,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          partnerName,
                          style:
                              KisaTypography.titleMedium.copyWith(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: KisaColors.sageSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: KisaColors.sage,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Live GPS',
                                style: KisaTypography.caption.copyWith(
                                  color: KisaColors.sage,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Current Activity Status Badge
                    if (partnerStatus != null && partnerStatus!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(partnerEmoji ?? '✨',
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              partnerStatus!,
                              style: KisaTypography.caption.copyWith(
                                color: KisaColors.primaryRose,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      Text(
                        'Diperbarui ${_formatUpdatedTime(partner?.updatedAt)}',
                        style: KisaTypography.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Intimate Distance Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isWithinProximity
                  ? KisaColors.primaryRose.withValues(alpha: 0.12)
                  : KisaColors.blushSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isWithinProximity
                    ? KisaColors.primaryRose.withValues(alpha: 0.5)
                    : KisaColors.primaryRose.withValues(alpha: 0.18),
                width: isWithinProximity ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isWithinProximity
                      ? Icons.near_me_rounded
                      : Icons.favorite_rounded,
                  color: KisaColors.primaryRose,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isWithinProximity
                        ? '$distanceText ✨ (< 100m)'
                        : distanceText,
                    style: KisaTypography.bodyMedium.copyWith(
                      color: KisaColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onTestProximity != null)
                  GestureDetector(
                    onTap: onTestProximity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: KisaColors.primaryRose.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Tes 100m',
                        style: KisaTypography.caption.copyWith(
                          color: KisaColors.primaryRose,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Send Love Poke Button
          BouncyButton.primary(
            label: 'Kirim Pelukan Hangat ❤️',
            onTap: onSendLovePoke,
            height: 48,
          ),
        ],
      ),
    );
  }
}
