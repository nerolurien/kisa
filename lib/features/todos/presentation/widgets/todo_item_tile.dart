import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animated_checkbox.dart';
import '../../../../core/widgets/glassy_container.dart';
import '../../models/kisa_todo.dart';

class TodoItemTile extends StatelessWidget {
  final KisaTodo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoItemTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return KisaColors.primaryRose;
      case 'med':
        return KisaColors.chamomile;
      case 'low':
        return KisaColors.sage;
      default:
        return KisaColors.textMuted;
    }
  }

  Color _priorityBg(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return KisaColors.blushSoft;
      case 'med':
        return KisaColors.chamomileSoft;
      case 'low':
        return KisaColors.sageSoft;
      default:
        return KisaColors.backgroundWarm;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pColor = _priorityColor(todo.priority);
    final pBg = _priorityBg(todo.priority);

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: KisaColors.blushSoft,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: KisaColors.primaryRose,
          size: 24,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: GlassyContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderRadius: 24,
          onTap: onToggle,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Custom squircle animated checkbox
              KisaAnimatedCheckbox(
                value: todo.isCompleted,
                onChanged: (_) => onToggle(),
              ),
              const SizedBox(width: 14),

              // Text, category, and priority
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: KisaTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: todo.isCompleted ? KisaColors.textMuted : KisaColors.textPrimary,
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: KisaColors.textMuted,
                      ),
                      child: Text(todo.text),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Category Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: KisaColors.backgroundWarm,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: KisaColors.borderSubtle),
                          ),
                          child: Text(
                            todo.category,
                            style: KisaTypography.caption.copyWith(
                              color: KisaColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Priority Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: pBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Prioritas ${todo.priority}',
                            style: KisaTypography.caption.copyWith(
                              color: pColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
