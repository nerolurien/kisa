import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/security_sanitizer.dart';
import '../../../../core/widgets/bouncy_button.dart';
import '../../../../core/widgets/custom_toast.dart';

class AddTodoSheet extends StatefulWidget {
  final Future<bool> Function({
    required String text,
    required String category,
    required String priority,
  }) onAdd;

  const AddTodoSheet({super.key, required this.onAdd});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final _textController = TextEditingController();
  String _selectedCategory = '🍿 Movie';
  String _selectedPriority = 'Med';
  bool _isLoading = false;

  final List<String> _categories = [
    '🍿 Movie',
    '✈️ Trip',
    '🍲 Food',
    '🌱 Nest',
    '✨ Impian',
  ];

  final List<String> _priorities = ['Low', 'Med', 'High'];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final text = KisaSecurity.sanitize(_textController.text, maxLength: 160);
    if (text.isEmpty) {
      showKisaToast(
        context,
        message: 'Tuliskan rencana atau wishlist impian kalian ✨',
        icon: Icons.edit_note_rounded,
        iconColor: KisaColors.peach,
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await widget.onAdd(
      text: text,
      category: _selectedCategory,
      priority: _selectedPriority,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
        showKisaToast(
          context,
          message: 'Ditambahkan ke wishlist bersama 🥂',
          icon: Icons.check_circle_rounded,
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
                  'Tambah Bucket List / Rencana',
                  style: KisaTypography.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // Category Chips Selector
                Text(
                  'KATEGORI',
                  style: KisaTypography.caption.copyWith(
                    color: KisaColors.primaryRose,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? KisaColors.primaryRose
                                : KisaColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? KisaColors.primaryRose
                                  : KisaColors.borderSubtle,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cat,
                            style: KisaTypography.caption.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : KisaColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Text Input
                Container(
                  decoration: BoxDecoration(
                    color: KisaColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: KisaColors.borderSubtle),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: TextField(
                    controller: _textController,
                    maxLines: 2,
                    style: KisaTypography.bodyLarge
                        .copyWith(color: KisaColors.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Misal: Road trip ke Jogja naik kereta malam',
                      hintStyle: KisaTypography.bodyMedium
                          .copyWith(color: KisaColors.textMuted),
                      icon: const Icon(Icons.favorite_border_rounded,
                          size: 20, color: KisaColors.primaryRose),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Priority Selector
                Text(
                  'PRIORITAS',
                  style: KisaTypography.caption.copyWith(
                    color: KisaColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _priorities.map((p) {
                    final isSelected = p == _selectedPriority;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPriority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? KisaColors.textPrimary
                                : KisaColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? KisaColors.textPrimary
                                  : KisaColors.borderSubtle,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            p,
                            style: KisaTypography.caption.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : KisaColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Submit Button
                BouncyButton.primary(
                  label: 'Simpan ke Bucket List',
                  icon: Icons.add_task_rounded,
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
