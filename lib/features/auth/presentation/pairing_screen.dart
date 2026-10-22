import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/security_sanitizer.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/widgets/glassy_container.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../core/widgets/avatar_marker.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import '../../navigation/presentation/main_navigation_scaffold.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePair() async {
    final rawCode = _codeController.text;
    final code = KisaSecurity.sanitize(rawCode, maxLength: 12).toUpperCase();
    if (code.isEmpty) {
      showKisaToast(
        context,
        message: 'Masukkan kode pairing pasanganmu 🔑',
        icon: Icons.key_rounded,
        iconColor: KisaColors.peach,
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).pairWithPartner(code);
    if (!mounted) return;

    if (success) {
      showKisaToast(
        context,
        message: 'Berhasil terhubung dengan pasanganmu! Selamat datang di Kisa ❤️',
        icon: Icons.favorite_rounded,
        iconColor: KisaColors.primaryRose,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScaffold()),
      );
    } else {
      final error = ref.read(authProvider).errorMessage;
      showKisaToast(
        context,
        message: error ?? 'Kode tidak valid. Coba periksa kembali!',
        icon: Icons.heart_broken_rounded,
        iconColor: Colors.redAccent,
      );
    }
  }

  void _showBackToLoginAlert() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: GlassyContainer(
            padding: const EdgeInsets.all(26),
            borderRadius: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: KisaColors.blushSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: KisaColors.primaryRose,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Kembali ke Halaman Masuk?',
                  style: KisaTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Kamu akan keluar dari akun ini dan kembali ke menu masuk/daftar. Kode pairing kamu tetap aman tersimpan.',
                  style: KisaTypography.bodyMedium.copyWith(color: KisaColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: BouncyButton.glass(
                        onTap: () => Navigator.of(ctx).pop(),
                        height: 48,
                        child: Text(
                          'Batal',
                          style: KisaTypography.bodyLarge.copyWith(
                            color: KisaColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BouncyButton.primary(
                        label: 'Ya, Keluar',
                        height: 48,
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          await ref.read(authProvider.notifier).signOut();
                          if (!mounted) return;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const AuthScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Protected Route Guards
    if (authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      });
      return const Scaffold(backgroundColor: KisaColors.background);
    }

    if (authState.isPaired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScaffold()),
          (route) => false,
        );
      });
      return const Scaffold(backgroundColor: KisaColors.background);
    }

    final myCode = authState.user?.pairingCode ?? 'KIP-749';

    return Scaffold(
      backgroundColor: KisaColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar with Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BouncyButton.glass(
                    onTap: _showBackToLoginAlert,
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: KisaColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Hubungkan Akun',
                    style: KisaTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: KisaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),

              // Symmetrical Couple Avatars with Pulsing Heart
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AvatarMarker(
                    name: authState.user?.name ?? 'Kip',
                    avatarUrl: authState.user?.avatarUrl,
                    radius: 34,
                  ),
                  const SizedBox(width: 16),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: KisaColors.blushSoft,
                        shape: BoxShape.circle,
                        boxShadow: KisaShadows.primaryGlow,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 26,
                        color: KisaColors.primaryRose,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: KisaColors.primaryRose.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      color: KisaColors.surface,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_add_rounded,
                        size: 28,
                        color: KisaColors.peach,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                'Hubungkan Dua Hati',
                style: KisaTypography.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Bagikan kodemu ke pasangan atau masukkan kodenya di bawah untuk menyatukan ruang privat kalian.',
                style: KisaTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Your Code Card
              GlassyContainer(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Text(
                      'KODE PAIRING KAMU',
                      style: KisaTypography.caption.copyWith(
                        color: KisaColors.primaryRose,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: KisaColors.backgroundWarm,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: KisaColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            myCode,
                            style: KisaTypography.displayMedium.copyWith(
                              letterSpacing: 3.5,
                              color: KisaColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 14),
                          BouncyButton.glass(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: myCode));
                              showKisaToast(
                                context,
                                message: 'Kode pairing disalin ke clipboard!',
                                icon: Icons.copy_rounded,
                              );
                            },
                            padding: const EdgeInsets.all(10),
                            child: const Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: KisaColors.primaryRose,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Enter Partner's Code Card
              GlassyContainer(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Text(
                      'MASUKKAN KODE PASANGAN',
                      style: KisaTypography.caption.copyWith(
                        color: KisaColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: KisaColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: KisaColors.borderSubtle, width: 1.2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
                        style: KisaTypography.titleLarge.copyWith(
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'MISAL: PIP-882',
                          hintStyle: KisaTypography.bodyLarge.copyWith(
                            color: KisaColors.textLight,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    BouncyButton.primary(
                      label: 'Hubungkan Akun Kita',
                      isLoading: authState.isLoading,
                      onTap: _handlePair,
                      height: 52,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        _codeController.text = 'FEX-882';
                        _handlePair();
                      },
                      child: Text(
                        'Isi Otomatis Kode Fexa (FEX-882)',
                        style: KisaTypography.labelSmall.copyWith(
                          color: KisaColors.primaryRose,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Secondary Back to Login Button
              TextButton.icon(
                onPressed: _showBackToLoginAlert,
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 16,
                  color: KisaColors.textMuted,
                ),
                label: Text(
                  'Ganti Akun / Kembali ke Halaman Masuk',
                  style: KisaTypography.bodyMedium.copyWith(
                    color: KisaColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
