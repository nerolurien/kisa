import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/security_sanitizer.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/widgets/glassy_container.dart';
import '../../../core/widgets/custom_toast.dart';
import '../providers/auth_provider.dart';
import 'pairing_screen.dart';
import '../../navigation/presentation/main_navigation_scaffold.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  final ClientRateLimiter _rateLimiter = ClientRateLimiter();
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _startLockoutCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = _rateLimiter.remainingLockoutSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _rateLimiter.remainingLockoutSeconds;
      setState(() => _secondsRemaining = remaining);
      if (remaining <= 0) {
        timer.cancel();
      }
    });
  }

  void _handleSubmit() async {
    // 1. Client-side Rate Limit check
    if (_rateLimiter.isLockedOut) {
      final secs = _rateLimiter.remainingLockoutSeconds;
      showKisaToast(
        context,
        message:
            'Terlalu banyak percobaan. Silakan tunggu $secs detik demi keamanan 🔒',
        icon: Icons.shield_rounded,
        iconColor: Colors.orangeAccent,
      );
      return;
    }

    // 2. Retrieve & Sanitize user inputs
    final email = KisaSecurity.sanitize(_emailController.text, maxLength: 100);
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = KisaSecurity.sanitize(_nameController.text, maxLength: 30);

    // 3. Robust input validation
    if (_isSignUp) {
      final nameErr = KisaSecurity.validateName(name);
      if (nameErr != null) {
        showKisaToast(
          context,
          message: nameErr,
          icon: Icons.person_rounded,
          iconColor: KisaColors.peach,
        );
        return;
      }
    }

    if (!KisaSecurity.isValidEmail(email)) {
      showKisaToast(
        context,
        message: 'Format email tidak valid (contoh: kamu@domain.com) ✉️',
        icon: Icons.alternate_email_rounded,
        iconColor: KisaColors.peach,
      );
      return;
    }

    final passErr = KisaSecurity.validatePassword(password);
    if (passErr != null) {
      showKisaToast(
        context,
        message: passErr,
        icon: Icons.lock_outline_rounded,
        iconColor: KisaColors.peach,
      );
      return;
    }

    if (_isSignUp) {
      if (confirmPassword.isEmpty) {
        showKisaToast(
          context,
          message: 'Silakan ulangi kata sandi untuk konfirmasi 🔒',
          icon: Icons.lock_reset_rounded,
          iconColor: KisaColors.peach,
        );
        return;
      }
      if (password != confirmPassword) {
        showKisaToast(
          context,
          message:
              'Konfirmasi kata sandi tidak cocok. Pastikan keduanya sama ya ❤️',
          icon: Icons.error_outline_rounded,
          iconColor: Colors.redAccent,
        );
        return;
      }
    }

    // 4. Submit to Auth Provider
    bool success;
    if (_isSignUp) {
      success =
          await ref.read(authProvider.notifier).signUp(email, password, name);
    } else {
      success = await ref.read(authProvider.notifier).signIn(email, password);
    }

    if (!mounted) return;

    if (!success) {
      _rateLimiter.recordFailure();
      if (_rateLimiter.isLockedOut) {
        _startLockoutCountdown();
      }
      final authState = ref.read(authProvider);
      if (authState.errorMessage != null) {
        showKisaToast(
          context,
          message: authState.errorMessage!,
          icon: Icons.error_outline_rounded,
          iconColor: Colors.redAccent,
        );
      }
    } else {
      _rateLimiter.reset();
      final authState = ref.read(authProvider);
      if (authState.isPaired) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScaffold()),
        );
      } else {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PairingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: KisaColors.background,
      body: Stack(
        children: [
          // Ambient cozy lighting orbs
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KisaColors.blushMedium.withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KisaColors.peachSoft.withValues(alpha: 0.6),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: const SizedBox.expand(),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color:
                                KisaColors.primaryRose.withValues(alpha: 0.16),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // App Title & Intimate Subtitle
                    Text(
                      'Kisa',
                      style: KisaTypography.displayLarge.copyWith(
                        letterSpacing: -1.2,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ruang Privat Eksklusif Dua Hati',
                      style: KisaTypography.bodyLarge.copyWith(
                        color: KisaColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Frosted Auth Card
                    GlassyContainer(
                      padding: const EdgeInsets.all(26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tab switcher between Masuk & Daftar
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: KisaColors.backgroundWarm
                                  .withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isSignUp = false),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: !_isSignUp
                                            ? KisaColors.surface
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: !_isSignUp
                                            ? KisaShadows.subtle
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Masuk',
                                        style:
                                            KisaTypography.titleMedium.copyWith(
                                          fontSize: 14,
                                          color: !_isSignUp
                                              ? KisaColors.textPrimary
                                              : KisaColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isSignUp = true),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _isSignUp
                                            ? KisaColors.surface
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: _isSignUp
                                            ? KisaShadows.subtle
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Daftar Baru',
                                        style:
                                            KisaTypography.titleMedium.copyWith(
                                          fontSize: 14,
                                          color: _isSignUp
                                              ? KisaColors.textPrimary
                                              : KisaColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Full Name for Sign Up
                          if (_isSignUp) ...[
                            _buildInputField(
                              controller: _nameController,
                              hint: 'Nama Panggilanmu (contoh: Fexa / Rafid)',
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Email
                          _buildInputField(
                            controller: _emailController,
                            hint: 'Alamat Email',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),

                          // Password
                          _buildInputField(
                            controller: _passwordController,
                            hint: 'Kata Sandi',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: KisaColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),

                          // Confirm Password for Sign Up
                          if (_isSignUp) ...[
                            const SizedBox(height: 14),
                            _buildInputField(
                              controller: _confirmPasswordController,
                              hint: 'Ulangi Kata Sandi',
                              icon: Icons.lock_reset_rounded,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: KisaColors.textMuted,
                                  size: 20,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Rate Limit Lockout Banner
                          if (_secondsRemaining > 0) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    Colors.orangeAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.orangeAccent
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.shield_rounded,
                                      color: Colors.orangeAccent, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Percobaan terkunci sementara demi keamanan. Tunggu $_secondsRemaining detik.',
                                      style: KisaTypography.bodyMedium.copyWith(
                                        color: Colors.orangeAccent,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ]
                          // Explicit Error Message Banner
                          else if (authState.errorMessage != null &&
                              authState.errorMessage!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.redAccent
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline_rounded,
                                      color: Colors.redAccent, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authState.errorMessage!,
                                      style: KisaTypography.bodyMedium.copyWith(
                                        color: Colors.redAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ] else ...[
                            const SizedBox(height: 8),
                          ],
                          BouncyButton.primary(
                            label: _secondsRemaining > 0
                                ? 'Terkunci ($_secondsRemaining dtk)'
                                : (_isSignUp
                                    ? 'Mulai Cerita Kita'
                                    : 'Masuk ke Kisa'),
                            isLoading: authState.isLoading,
                            onTap:
                                _secondsRemaining > 0 ? () {} : _handleSubmit,
                            height: 52,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    BouncyButton.glass(
                      onTap: () {
                        ref.read(authProvider.notifier).loginWithDemoMode();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const MainNavigationScaffold()),
                        );
                      },
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: KisaColors.primaryRose,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Jelajahi Demo (Kip & Fexa)',
                            style: KisaTypography.labelSmall.copyWith(
                              color: KisaColors.primaryRose,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: KisaColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KisaColors.borderSubtle, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: KisaTypography.bodyLarge.copyWith(color: KisaColors.textPrimary),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle:
              KisaTypography.bodyMedium.copyWith(color: KisaColors.textMuted),
          icon: Icon(icon, size: 20, color: KisaColors.textMuted),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
