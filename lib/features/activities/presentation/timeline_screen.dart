import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/widgets/glassy_container.dart';
import '../../../core/widgets/avatar_marker.dart';
import '../providers/activity_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/widgets/update_status_sheet.dart';
import 'widgets/scrapbook_card.dart';
import 'widgets/create_moment_sheet.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  void _openUpdateStatusSheet(
    BuildContext context,
    WidgetRef ref,
    String currentStatus,
    String currentEmoji,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpdateStatusSheet(
        currentStatus: currentStatus,
        currentEmoji: currentEmoji,
        onUpdate: ({required String status, required String emoji}) async {
          await ref.read(authProvider.notifier).updateStatus(status: status, emoji: emoji);
        },
      ),
    );
  }

  void _openCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateMomentSheet(
        onSave: ({
          required String content,
          String moodEmoji = '✨',
          String? photoUrl,
          String? locationTag,
        }) async {
          return await ref.read(activityProvider.notifier).createActivity(
                content: content,
                moodEmoji: moodEmoji,
                photoUrl: photoUrl,
                locationTag: locationTag,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityProvider);
    final authState = ref.watch(authProvider);
    final partner = authState.partner;
    final currentUser = authState.user;

    return Scaffold(
      backgroundColor: KisaColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Header with intimate partner mood
            CustomHeader(
              title: 'Scrapbook Cerita Kita',
              subtitle: partner != null
                  ? '${partner.name} • ${partner.statusEmoji} ${partner.currentStatus}'
                  : 'Ruang Privat Kita',
              leading: AvatarMarker(
                name: partner?.name ?? 'Fexa',
                avatarUrl: partner?.avatarUrl,
                radius: 19,
                isPartner: true,
                statusEmoji: partner?.statusEmoji,
              ),
              trailing: BouncyButton.glass(
                onTap: () => _openCreateSheet(context, ref),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: KisaColors.primaryRose,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Momen',
                      style: KisaTypography.labelSmall.copyWith(
                        color: KisaColors.primaryRose,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Live Couple Status Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
              child: GlassyContainer(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                borderRadius: 26,
                child: Row(
                  children: [
                    // Partner Status Pill
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: KisaColors.blushSoft,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              partner?.statusEmoji ?? '✨',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  partner?.name ?? 'Pasangan',
                                  style: KisaTypography.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: KisaColors.primaryRose,
                                  ),
                                ),
                                Text(
                                  partner?.currentStatus ?? 'Lagi santai',
                                  style: KisaTypography.bodyMedium.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: KisaColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 32,
                      color: KisaColors.borderSubtle,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),

                    // My Status & Quick Edit Button
                    BouncyButton.glass(
                      onTap: () => _openUpdateStatusSheet(
                        context,
                        ref,
                        currentUser?.currentStatus ?? 'Lagi santai',
                        currentUser?.statusEmoji ?? '✨',
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentUser?.statusEmoji ?? '✨',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 80),
                            child: Text(
                              currentUser?.currentStatus ?? 'Status',
                              style: KisaTypography.caption.copyWith(
                                color: KisaColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.edit_rounded,
                            size: 13,
                            color: KisaColors.primaryRose,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scrapbook Feed
            Expanded(
              child: RefreshIndicator(
                color: KisaColors.primaryRose,
                backgroundColor: KisaColors.surface,
                onRefresh: () => ref.read(activityProvider.notifier).loadActivities(),
                child: activityState.isLoading && activityState.activities.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: KisaColors.primaryRose,
                          strokeWidth: 2.2,
                        ),
                      )
                    : activityState.activities.isEmpty
                        ? _buildEmptyState(context, ref)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                            itemCount: activityState.activities.length,
                            itemBuilder: (context, index) {
                              final act = activityState.activities[index];
                              final isMine = act.userId == (currentUser?.id ?? 'usr_kip_01');
                              return ScrapbookCard(
                                key: ValueKey(act.id),
                                activity: act,
                                isMyPost: isMine,
                                onLike: () {
                                  ref.read(activityProvider.notifier).toggleLike(act.id);
                                },
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KisaColors.blushSoft,
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 44,
                color: KisaColors.primaryRose,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Belum Ada Catatan Scrapbook',
              style: KisaTypography.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Bagikan kabar harian, foto secangkir kopi, atau kabar rindu untuk pasanganmu.',
              style: KisaTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            BouncyButton.primary(
              label: 'Buat Momen Pertama',
              icon: Icons.favorite_border_rounded,
              onTap: () => _openCreateSheet(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
