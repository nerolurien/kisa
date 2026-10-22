import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/security_sanitizer.dart';
import '../../../../core/widgets/bouncy_button.dart';
import '../../../../core/widgets/custom_toast.dart';
import '../../../auth/models/kisa_user.dart';

class EditProfileSheet extends StatefulWidget {
  final KisaUser user;
  final Future<bool> Function({
    required String name,
    String? avatarUrl,
    String? bio,
    DateTime? anniversaryDate,
  }) onSave;

  const EditProfileSheet({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _customAvatarUrlController;
  late String _selectedAvatarUrl;
  DateTime? _selectedAnniversaryDate;
  bool _isSaving = false;

  final List<String> _sampleAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=400&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio);
    _selectedAvatarUrl = widget.user.avatarUrl ?? _sampleAvatars.first;
    _customAvatarUrlController =
        TextEditingController(text: widget.user.avatarUrl ?? '');
    _selectedAnniversaryDate = widget.user.anniversaryDate ??
        DateTime.now().subtract(const Duration(days: 280));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _customAvatarUrlController.dispose();
    super.dispose();
  }

  void _pickAnniversaryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedAnniversaryDate ?? now.subtract(const Duration(days: 280)),
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: KisaColors.primaryRose,
              onPrimary: Colors.white,
              onSurface: KisaColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedAnniversaryDate = picked);
    }
  }

  void _handleSave() async {
    final name = KisaSecurity.sanitize(_nameController.text, maxLength: 30);
    final bio = KisaSecurity.sanitize(_bioController.text, maxLength: 120);

    final nameErr = KisaSecurity.validateName(name);
    if (nameErr != null) {
      showKisaToast(
        context,
        message: nameErr,
        icon: Icons.person_outline_rounded,
        iconColor: KisaColors.peach,
      );
      return;
    }

    setState(() => _isSaving = true);
    final success = await widget.onSave(
      name: name,
      avatarUrl: _selectedAvatarUrl,
      bio: bio.isNotEmpty ? bio : null,
      anniversaryDate: _selectedAnniversaryDate,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
      showKisaToast(
        context,
        message: 'Profil berhasil diperbarui! ✨',
        icon: Icons.check_circle_rounded,
        iconColor: KisaColors.primaryRose,
      );
    } else {
      showKisaToast(
        context,
        message: 'Gagal memperbarui profil. Coba lagi!',
        icon: Icons.error_outline_rounded,
        iconColor: Colors.redAccent,
      );
    }
  }

  static const _indonesianMonths = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  String _formatDate(DateTime dt) {
    try {
      return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      final m = dt.month >= 1 && dt.month <= 12
          ? _indonesianMonths[dt.month]
          : '${dt.month}';
      return '${dt.day} $m ${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final dateFormatted = _selectedAnniversaryDate != null
        ? _formatDate(_selectedAnniversaryDate!)
        : 'Pilih Tanggal';

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: EdgeInsets.fromLTRB(22, 12, 22, 24 + keyboardHeight),
        decoration: BoxDecoration(
          color: KisaColors.surfaceGlass.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          boxShadow: KisaShadows.floating,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Indicator
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: KisaColors.borderSubtle,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profil Pribadi',
                    style: KisaTypography.titleLarge,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: KisaColors.blushSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.user.pairingCode,
                      style: KisaTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: KisaColors.primaryRose,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Avatar Preview & Selector
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: KisaColors.loveGradient,
                    boxShadow: KisaShadows.primaryGlow,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipOval(
                    child: Image.network(
                      _selectedAvatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: KisaColors.blushMedium,
                        child: Center(
                          child: Text(
                            widget.user.name.isNotEmpty
                                ? widget.user.name[0]
                                : 'K',
                            style: KisaTypography.displayMedium
                                .copyWith(color: KisaColors.primaryRose),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Sample Avatar List
              Text(
                'PILIH FOTO PROFIL',
                style: KisaTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: KisaColors.textLight,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 54,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleAvatars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final url = _sampleAvatars[idx];
                    final isSelected = _selectedAvatarUrl == url;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatarUrl = url),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? KisaColors.primaryRose
                                : KisaColors.borderSubtle,
                            width: isSelected ? 2.5 : 1.2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(url, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Name Input
              Text(
                'NAMA PANGGILAN',
                style: KisaTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: KisaColors.textLight,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: KisaColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: KisaColors.borderSubtle, width: 1.2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _nameController,
                  style: KisaTypography.bodyLarge
                      .copyWith(color: KisaColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nama panggilanmu...',
                    hintStyle: KisaTypography.bodyMedium
                        .copyWith(color: KisaColors.textLight),
                    icon: const Icon(Icons.person_outline_rounded,
                        size: 20, color: KisaColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Bio Input
              Text(
                'BIO / PESAN CINTA',
                style: KisaTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: KisaColors.textLight,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: KisaColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: KisaColors.borderSubtle, width: 1.2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _bioController,
                  maxLines: 2,
                  style: KisaTypography.bodyLarge
                      .copyWith(color: KisaColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Catatan kecil untuk pasangan kita...',
                    hintStyle: KisaTypography.bodyMedium
                        .copyWith(color: KisaColors.textLight),
                    icon: const Icon(Icons.auto_awesome_rounded,
                        size: 20, color: KisaColors.peach),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Anniversary Date Picker Row
              Text(
                'HARI JADIAN / TANGGAL MULAI BERSAMA',
                style: KisaTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: KisaColors.textLight,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickAnniversaryDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: KisaColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border:
                        Border.all(color: KisaColors.borderSubtle, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          size: 20, color: KisaColors.primaryRose),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateFormatted,
                          style: KisaTypography.bodyLarge.copyWith(
                            color: KisaColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'Pilih Tanggal',
                        style: KisaTypography.caption.copyWith(
                          color: KisaColors.primaryRose,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              BouncyButton.primary(
                label: 'Simpan Perubahan',
                isLoading: _isSaving,
                onTap: _handleSave,
                height: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
