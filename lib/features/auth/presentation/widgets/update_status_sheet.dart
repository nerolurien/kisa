import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/security_sanitizer.dart';
import '../../../../core/widgets/bouncy_button.dart';
import '../../../../core/widgets/custom_toast.dart';

class StatusPreset {
  final String emoji;
  final String label;

  const StatusPreset({required this.emoji, required this.label});
}

class UpdateStatusSheet extends StatefulWidget {
  final String currentStatus;
  final String currentEmoji;
  final Future<void> Function({required String status, required String emoji}) onUpdate;

  const UpdateStatusSheet({
    super.key,
    required this.currentStatus,
    required this.currentEmoji,
    required this.onUpdate,
  });

  @override
  State<UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends State<UpdateStatusSheet> {
  late String _selectedEmoji;
  late TextEditingController _customController;
  bool _isSaving = false;

  final List<StatusPreset> _presets = const [
    StatusPreset(emoji: '💼', label: 'Sedang Kerja'),
    StatusPreset(emoji: '🍜', label: 'Lagi Makan'),
    StatusPreset(emoji: '😴', label: 'Istirahat / Bobo'),
    StatusPreset(emoji: '🚗', label: 'Di Jalan / OTW'),
    StatusPreset(emoji: '☕', label: 'Ngopi Santai'),
    StatusPreset(emoji: '🎮', label: 'Main Game'),
    StatusPreset(emoji: '📚', label: 'Lagi Belajar'),
    StatusPreset(emoji: '🏃', label: 'Olahraga / Gym'),
    StatusPreset(emoji: '🍿', label: 'Nonton Film'),
    StatusPreset(emoji: '🛍️', label: 'Lagi Belanja'),
    StatusPreset(emoji: '💌', label: 'Kangen Kamu Banget'),
    StatusPreset(emoji: '✨', label: 'Lagi Santai'),
  ];

  final List<String> _customEmojis = const [
    '✨', '💖', '🥰', '🌧️', '🎧', '🛋️', '🍕', '💻', '🧘', '🚲', '🎨', '🔥',
  ];

  @override
  void initState() {
    super.initState();
    _selectedEmoji = widget.currentEmoji;
    _customController = TextEditingController(text: widget.currentStatus);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _handlePresetSelect(StatusPreset preset) {
    setState(() {
      _selectedEmoji = preset.emoji;
      _customController.text = preset.label;
    });
  }

  void _handleSubmit() async {
    final status = KisaSecurity.sanitize(_customController.text, maxLength: 80);
    if (status.isEmpty) {
      showKisaToast(
        context,
        message: 'Tulis aktivitasmu terlebih dahulu ✏️',
        icon: Icons.edit_note_rounded,
        iconColor: KisaColors.peach,
      );
      return;
    }

    setState(() => _isSaving = true);
    await widget.onUpdate(status: status, emoji: _selectedEmoji);
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop();

    showKisaToast(
      context,
      message: 'Statusmu berhasil dibagikan ke pasangan! $_selectedEmoji',
      icon: Icons.check_circle_rounded,
      iconColor: KisaColors.primaryRose,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: EdgeInsets.fromLTRB(22, 12, 22, 24 + keyboardHeight),
        decoration: BoxDecoration(
          color: KisaColors.surfaceGlass.withValues(alpha: 0.94),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: KisaColors.blushSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lagi Ngapain Sekarang?',
                          style: KisaTypography.titleLarge.copyWith(fontSize: 19),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Beri tahu pasangan apa yang sedang kamu lakukan',
                          style: KisaTypography.bodyMedium.copyWith(
                            color: KisaColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Quick Presets
              Text(
                'PILIHAN CEPAT',
                style: KisaTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: KisaColors.textLight,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((preset) {
                  final isSelected = _selectedEmoji == preset.emoji &&
                      _customController.text == preset.label;
                  return BouncyButton.glass(
                    onTap: () => _handlePresetSelect(preset),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(preset.emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          preset.label,
                          style: KisaTypography.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? KisaColors.primaryRose : KisaColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // Custom Activity Input
              Text(
                'ATAU STATUS CUSTOM SENDIRI',
                style: KisaTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: KisaColors.textLight,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),

              // Emoji picker row
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _customEmojis.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final em = _customEmojis[idx];
                    final isSelected = _selectedEmoji == em;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = em),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? KisaColors.blushMedium : KisaColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? KisaColors.primaryRose : KisaColors.borderSubtle,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(em, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Custom Text Field
              Container(
                decoration: BoxDecoration(
                  color: KisaColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: KisaColors.borderSubtle, width: 1.2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _customController,
                  maxLength: 50,
                  style: KisaTypography.bodyLarge.copyWith(color: KisaColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: 'Misal: Lagi nunggu hujan reda sambil baca buku...',
                    hintStyle: KisaTypography.bodyMedium.copyWith(color: KisaColors.textLight),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              BouncyButton.primary(
                label: 'Pasang Status Sekarang',
                isLoading: _isSaving,
                onTap: _handleSubmit,
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
