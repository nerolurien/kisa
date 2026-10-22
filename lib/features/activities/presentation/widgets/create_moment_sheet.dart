import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/security_sanitizer.dart';
import '../../../../core/widgets/bouncy_button.dart';
import '../../../../core/widgets/custom_toast.dart';

class CreateMomentSheet extends StatefulWidget {
  final Future<bool> Function({
    required String content,
    String moodEmoji,
    String? photoUrl,
    String? locationTag,
  }) onSave;

  const CreateMomentSheet({super.key, required this.onSave});

  @override
  State<CreateMomentSheet> createState() => _CreateMomentSheetState();
}

class _CreateMomentSheetState extends State<CreateMomentSheet> {
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedMood = '✨';
  String? _selectedPhotoUrl;
  bool _isLoading = false;

  final List<String> _moods = ['✨', '🥰', '☕', '🌅', '🍣', '🍿', '🌿', '💌'];

  final List<Map<String, String>> _samplePhotos = [
    {
      'label': 'Kopi',
      'url':
          'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
    },
    {
      'label': 'Sunset',
      'url':
          'https://images.unsplash.com/photo-1518495973542-4542c06a5843?auto=format&fit=crop&w=800&q=80',
    },
    {
      'label': 'Keramik',
      'url':
          'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?auto=format&fit=crop&w=800&q=80',
    },
    {
      'label': 'Taman',
      'url':
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final text = KisaSecurity.sanitize(_contentController.text, maxLength: 500);
    final locationTag =
        KisaSecurity.sanitize(_locationController.text, maxLength: 60);

    if (text.isEmpty) {
      showKisaToast(
        context,
        message: 'Ceritakan momen manismu hari ini ✨',
        icon: Icons.edit_rounded,
        iconColor: KisaColors.peach,
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await widget.onSave(
      content: text,
      moodEmoji: _selectedMood,
      photoUrl: _selectedPhotoUrl,
      locationTag: locationTag.isNotEmpty ? locationTag : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
        showKisaToast(
          context,
          message: 'Momen tersimpan di scrapbook kita 📖',
          icon: Icons.favorite_rounded,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: KisaColors.surfaceGlass.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            border: KisaShadows.glassBorder,
            boxShadow: KisaShadows.floating,
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: KisaColors.borderSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  'Catat Momen di Scrapbook',
                  style: KisaTypography.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Text(
                  'MOOD HARI INI',
                  style: KisaTypography.caption.copyWith(
                    color: KisaColors.primaryRose,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _moods.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final emoji = _moods[index];
                      final isSelected = emoji == _selectedMood;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = emoji),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? KisaColors.blushSoft
                                : KisaColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? KisaColors.primaryRose
                                  : KisaColors.borderSubtle,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child:
                              Text(emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Text Content Input
                Container(
                  decoration: BoxDecoration(
                    color: KisaColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: KisaColors.borderSubtle),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: TextField(
                    controller: _contentController,
                    maxLines: 3,
                    style: KisaTypography.bodyLarge
                        .copyWith(color: KisaColors.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tuliskan catatan cinta atau kabar harianmu...',
                      hintStyle: KisaTypography.bodyMedium
                          .copyWith(color: KisaColors.textMuted),
                      icon: const Icon(Icons.notes_rounded,
                          size: 20, color: KisaColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Location Tag Input with Chips
                Container(
                  decoration: BoxDecoration(
                    color: KisaColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: KisaColors.borderSubtle),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: TextField(
                    controller: _locationController,
                    style: KisaTypography.bodyLarge
                        .copyWith(color: KisaColors.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tag Lokasi (opsional, misal: Kedai Kopi)',
                      hintStyle: KisaTypography.bodyMedium
                          .copyWith(color: KisaColors.textMuted),
                      icon: const Icon(Icons.location_on_outlined,
                          size: 20, color: KisaColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Rumah Kita 🏡',
                    'Kedai Kopi Sudut Temu ☕',
                    'Stasiun MRT 🚇',
                    'Taman Kota 🌿'
                  ].map((tag) {
                    return GestureDetector(
                      onTap: () => _locationController.text = tag,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: KisaColors.backgroundWarm,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: KisaTypography.caption
                              .copyWith(color: KisaColors.textSecondary),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Photo Presets
                Text(
                  'FOTO KENANGAN',
                  style: KisaTypography.caption.copyWith(
                    color: KisaColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 68,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _samplePhotos.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isNone = _selectedPhotoUrl == null;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPhotoUrl = null),
                          child: Container(
                            width: 68,
                            decoration: BoxDecoration(
                              color: isNone
                                  ? KisaColors.blushSoft
                                  : KisaColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isNone
                                    ? KisaColors.primaryRose
                                    : KisaColors.borderSubtle,
                                width: isNone ? 1.5 : 1,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.hide_image_outlined,
                                    size: 18, color: KisaColors.textMuted),
                                SizedBox(height: 4),
                                Text('Tanpa foto',
                                    style: TextStyle(fontSize: 9.5)),
                              ],
                            ),
                          ),
                        );
                      }

                      final photo = _samplePhotos[index - 1];
                      final isSelected = photo['url'] == _selectedPhotoUrl;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedPhotoUrl = photo['url']),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 68,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? KisaColors.primaryRose
                                    : Colors.transparent,
                                width: 2.2,
                              ),
                            ),
                            child: Image.network(
                              photo['url']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                BouncyButton.primary(
                  label: 'Bagikan ke Pasangan',
                  icon: Icons.send_rounded,
                  isLoading: _isLoading,
                  onTap: _handleSubmit,
                  height: 52,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
