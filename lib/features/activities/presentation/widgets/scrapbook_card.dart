import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/avatar_marker.dart';
import '../../../../core/widgets/glassy_container.dart';
import '../../models/kisa_activity.dart';

class ScrapbookCard extends StatefulWidget {
  final KisaActivity activity;
  final bool isMyPost;
  final VoidCallback onLike;

  const ScrapbookCard({
    super.key,
    required this.activity,
    required this.isMyPost,
    required this.onLike,
  });

  @override
  State<ScrapbookCard> createState() => _ScrapbookCardState();
}

class _ScrapbookCardState extends State<ScrapbookCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _burstController;
  late Animation<double> _burstScale;
  late Animation<double> _burstOpacity;
  bool _showBurstHeart = false;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _burstScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_burstController);

    _burstOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
    ]).animate(_burstController);

    _burstController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showBurstHeart = false);
      }
    });
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  void _triggerDoubleTapLove() {
    HapticFeedback.mediumImpact();
    setState(() => _showBurstHeart = true);
    _burstController.forward(from: 0.0);
    widget.onLike();
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}j yang lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}h yang lalu';
    }
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final isMine = widget.isMyPost;

    // Asymmetrical Scrapbook styling per PRD 3.C
    final rotation = isMine ? -0.008 : 0.008;
    final margin = isMine
        ? const EdgeInsets.only(right: 18, left: 6, bottom: 20)
        : const EdgeInsets.only(left: 18, right: 6, bottom: 20);

    return Transform.rotate(
      angle: rotation,
      child: Padding(
        padding: margin,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GlassyContainer(
              padding: EdgeInsets.zero,
              borderRadius: 28,
              onDoubleTap: _triggerDoubleTapLove,
              color: isMine
                  ? KisaColors.surfaceGlass.withValues(alpha: 0.92)
                  : KisaColors.backgroundWarm.withValues(alpha: 0.92),
              border: Border.all(
                color: isMine
                    ? KisaColors.borderSubtle
                    : KisaColors.blushMedium.withValues(alpha: 0.4),
                width: 1.2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Author Row with Mood Sticker
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        AvatarMarker(
                          name: activity.authorName,
                          avatarUrl: activity.authorAvatar,
                          radius: 18,
                          isPartner: !isMine,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.authorName,
                                style: KisaTypography.titleMedium
                                    .copyWith(fontSize: 14.5),
                              ),
                              Text(
                                _formatTime(activity.createdAt),
                                style: KisaTypography.caption
                                    .copyWith(color: KisaColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        // Mood Emoji Sticker
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isMine
                                ? KisaColors.blushSoft
                                : KisaColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: KisaShadows.subtle,
                          ),
                          child: Text(
                            activity.moodEmoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Photo Memory if present
                  if (activity.photoUrl != null &&
                      activity.photoUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: AspectRatio(
                          aspectRatio: 1.35,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                activity.photoUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    color: KisaColors.backgroundWarm,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: KisaColors.primaryRose,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: KisaColors.blushSoft,
                                  child: const Center(
                                    child: Icon(
                                        Icons.image_not_supported_rounded,
                                        color: KisaColors.primaryRose),
                                  ),
                                ),
                              ),
                              // Location tag overlay on photo
                              if (activity.locationTag != null &&
                                  activity.locationTag!.isNotEmpty)
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on_rounded,
                                            size: 12, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          activity.locationTag!,
                                          style:
                                              KisaTypography.caption.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Content Body
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.content,
                          style: KisaTypography.bodyLarge.copyWith(
                            color: KisaColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bottom Actions: Love reaction button & location (if no photo)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onLike();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: activity.isLikedByMe
                                      ? KisaColors.blushSoft
                                      : KisaColors.backgroundWarm,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      activity.isLikedByMe
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 16,
                                      color: activity.isLikedByMe
                                          ? KisaColors.primaryRose
                                          : KisaColors.textMuted,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${activity.likesCount}',
                                      style: KisaTypography.labelSmall.copyWith(
                                        color: activity.isLikedByMe
                                            ? KisaColors.primaryRose
                                            : KisaColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (activity.locationTag != null &&
                                (activity.photoUrl == null ||
                                    activity.photoUrl!.isEmpty))
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 13, color: KisaColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    activity.locationTag!,
                                    style: KisaTypography.caption
                                        .copyWith(color: KisaColors.textMuted),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Double Tap Heart Burst Animation (PRD 3.C)
            if (_showBurstHeart)
              AnimatedBuilder(
                animation: _burstController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _burstOpacity.value,
                    child: Transform.scale(
                      scale: _burstScale.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: KisaColors.surface.withValues(alpha: 0.90),
                          boxShadow: KisaShadows.floating,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 64,
                          color: KisaColors.primaryRose,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
