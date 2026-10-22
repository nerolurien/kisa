import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/widgets/glassy_container.dart';
import '../providers/todo_provider.dart';
import 'widgets/todo_item_tile.dart';
import 'widgets/add_todo_sheet.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTodoSheet(
        onAdd: ({
          required String text,
          required String category,
          required String priority,
        }) async {
          return await ref.read(todoProvider.notifier).createTodo(
                text: text,
                category: category,
                priority: priority,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoProvider);
    final categories = [
      'All',
      '🍿 Movie',
      '✈️ Trip',
      '🍲 Food',
      '🌱 Nest',
      '✨ Impian',
    ];

    return Scaffold(
      backgroundColor: KisaColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Header
            CustomHeader(
              title: 'Bucket List Kita',
              subtitle: 'Impian & Rencana Masa Depan',
              trailing: BouncyButton.glass(
                onTap: () => _openAddSheet(context, ref),
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
                      'Wishlist',
                      style: KisaTypography.labelSmall.copyWith(
                        color: KisaColors.primaryRose,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: KisaColors.primaryRose,
                backgroundColor: KisaColors.surface,
                onRefresh: () => ref.read(todoProvider.notifier).loadTodos(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                  children: [
                    // Gamification Progress Card (PRD 3.B)
                    GlassyContainer(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 28,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TARGET TERCAPAI',
                                      style: KisaTypography.caption.copyWith(
                                        color: KisaColors.primaryRose,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      todoState.gamificationCheer,
                                      style: KisaTypography.titleMedium.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Circular Percentage Display
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: KisaColors.blushSoft,
                                ),
                                child: Center(
                                  child: Text(
                                    '${(todoState.progressPercentage * 100).toInt()}%',
                                    style: KisaTypography.labelSmall.copyWith(
                                      color: KisaColors.primaryRose,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Smooth Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: todoState.progressPercentage,
                              minHeight: 7,
                              backgroundColor: KisaColors.backgroundWarm,
                              valueColor: const AlwaysStoppedAnimation<Color>(KisaColors.primaryRose),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Category Filter Pills
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = cat == todoState.selectedCategory;
                          return GestureDetector(
                            onTap: () => ref.read(todoProvider.notifier).selectCategory(cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? KisaColors.primaryRose : KisaColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? KisaColors.primaryRose : KisaColors.borderSubtle,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cat,
                                style: KisaTypography.labelSmall.copyWith(
                                  color: isSelected ? Colors.white : KisaColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Todos List
                    if (todoState.isLoading && todoState.todos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: KisaColors.primaryRose,
                            strokeWidth: 2.2,
                          ),
                        ),
                      )
                    else if (todoState.filteredTodos.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: KisaColors.blushSoft,
                                ),
                                child: const Icon(
                                  Icons.checklist_rtl_rounded,
                                  size: 40,
                                  color: KisaColors.primaryRose,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum Ada Wishlist di "${todoState.selectedCategory}"',
                                style: KisaTypography.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sentuh tombol "+ Wishlist" untuk menambah impian!',
                                style: KisaTypography.caption.copyWith(color: KisaColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...todoState.filteredTodos.map((todo) {
                        return TodoItemTile(
                          key: ValueKey(todo.id),
                          todo: todo,
                          onToggle: () {
                            ref.read(todoProvider.notifier).toggleTodo(todo.id);
                          },
                          onDelete: () {
                            ref.read(todoProvider.notifier).deleteTodo(todo.id);
                          },
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
