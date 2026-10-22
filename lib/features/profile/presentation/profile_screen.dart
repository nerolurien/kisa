import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/widgets/glassy_container.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../core/widgets/avatar_marker.dart';
import '../../../core/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/kisa_user.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../auth/presentation/widgets/update_status_sheet.dart';
import 'widgets/edit_profile_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  void _openEditProfileSheet(BuildContext context, WidgetRef ref, KisaUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(
        user: user,
        onSave: ({
          required String name,
          String? avatarUrl,
          String? bio,
          DateTime? anniversaryDate,
        }) async {
          return await ref.read(authProvider.notifier).updateProfile(
                name: name,
                avatarUrl: avatarUrl,
                bio: bio,
                anniversaryDate: anniversaryDate,
              );
        },
      ),
    );
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final partner = authState.partner;

    final daysTogether = user?.daysTogether ?? 280;

    return Scaffold(
      backgroundColor: KisaColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomHeader(
              title: 'Ruang Kita',
              subtitle: 'Pengaturan & Koneksi Cinta',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user != null)
                    BouncyButton.glass(
                      onTap: () => _openEditProfileSheet(context, ref, user),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_note_rounded, size: 16, color: KisaColors.primaryRose),
                          const SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: KisaTypography.caption.copyWith(
                              color: KisaColors.primaryRose,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  BouncyButton.glass(
                    onTap: () => _signOut(context, ref),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: KisaColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                children: [
                  // Symmetrical Couple Counter Card
                  GlassyContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                    borderRadius: 32,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AvatarMarker(
                              name: user?.name ?? 'Kip',
                              avatarUrl: user?.avatarUrl,
                              radius: 30,
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: KisaColors.primaryGradient,
                                boxShadow: KisaShadows.primaryGlow,
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            AvatarMarker(
                              name: partner?.name ?? 'Fexa',
                              avatarUrl: partner?.avatarUrl,
                              radius: 30,
                              isPartner: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        Text(
                          'BERSAMA SELAMA',
                          style: KisaTypography.caption.copyWith(
                            color: KisaColors.primaryRose,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$daysTogether',
                              style: KisaTypography.displayLarge.copyWith(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: KisaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'hari penuh cerita',
                              style: KisaTypography.titleMedium.copyWith(
                                color: KisaColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: KisaColors.backgroundWarm,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${user?.name ?? "Kip"} & ${partner?.name ?? "Fexa"} ❤️',
                            style: KisaTypography.labelSmall.copyWith(
                              color: KisaColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (user?.bio != null && user!.bio.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              '"${user.bio}"',
                              style: KisaTypography.bodyMedium.copyWith(
                                fontStyle: FontStyle.italic,
                                color: KisaColors.textSecondary,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Status Aktivitas Saat Ini Card
                  GlassyContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'STATUS AKTIVITAS SAAT INI',
                              style: KisaTypography.caption.copyWith(
                                color: KisaColors.primaryRose,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            BouncyButton.glass(
                              onTap: () => _openUpdateStatusSheet(
                                context,
                                ref,
                                user?.currentStatus ?? 'Lagi santai',
                                user?.statusEmoji ?? '✨',
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.edit_rounded, size: 14, color: KisaColors.primaryRose),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ubah',
                                    style: KisaTypography.caption.copyWith(
                                      color: KisaColors.primaryRose,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // My Status Row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: KisaColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: KisaColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Text(user?.statusEmoji ?? '✨', style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status Kamu',
                                      style: KisaTypography.caption.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      user?.currentStatus ?? 'Lagi santai ✨',
                                      style: KisaTypography.titleMedium.copyWith(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Partner Status Row
                        if (partner != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: KisaColors.blushSoft,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: KisaColors.primaryRose.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              children: [
                                Text(partner.statusEmoji, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Status ${partner.name}',
                                        style: KisaTypography.caption.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: KisaColors.primaryRose,
                                        ),
                                      ),
                                      Text(
                                        partner.currentStatus,
                                        style: KisaTypography.titleMedium.copyWith(
                                          fontSize: 15,
                                          color: KisaColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pairing Code & Info Card
                  GlassyContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KONEKSI AKUN',
                          style: KisaTypography.caption.copyWith(
                            color: KisaColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow(
                          icon: Icons.vpn_key_rounded,
                          title: 'Kode Pairing Kamu',
                          value: user?.pairingCode ?? 'KIP-749',
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: user?.pairingCode ?? 'KIP-749'));
                            showKisaToast(context, message: 'Kode berhasil disalin!');
                          },
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.person_pin_rounded,
                          title: 'Pasangan Terhubung',
                          value: partner != null ? '${partner.name} (${partner.pairingCode})' : 'Belum terhubung',
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.cloud_sync_rounded,
                          title: 'Status Supabase Sync',
                          value: KisaSupabaseClient().isLiveSupabase
                              ? 'Live Supabase Cloud Terhubung 🟢'
                              : 'Local Sync Engine Aktif 🟢',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: KisaColors.backgroundWarm,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: KisaColors.primaryRose),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: KisaTypography.caption.copyWith(color: KisaColors.textMuted),
                ),
                Text(
                  value,
                  style: KisaTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: KisaColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.copy_rounded,
              size: 16,
              color: KisaColors.textMuted,
            ),
        ],
      ),
    );
  }
}
