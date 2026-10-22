import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../models/kisa_todo.dart';

class TodoState {
  final List<KisaTodo> todos;
  final String selectedCategory;
  final bool isLoading;
  final bool isCreating;
  final String? errorMessage;

  const TodoState({
    this.todos = const [],
    this.selectedCategory = 'All',
    this.isLoading = false,
    this.isCreating = false,
    this.errorMessage,
  });

  int get totalCount => todos.length;
  int get completedCount => todos.where((t) => t.isCompleted).length;
  double get progressPercentage =>
      totalCount == 0 ? 0.0 : completedCount / totalCount;

  String get gamificationCheer {
    if (totalCount == 0) return 'Mulai buat bucket list impian kita berdua ✨';
    if (completedCount == totalCount) {
      return 'Kita udah nyelesaiin semua $completedCount bucket list bareng! 🥂🎉';
    }
    return 'Kita udah nyelesaiin $completedCount dari $totalCount bucket list bareng! 🥂';
  }

  List<KisaTodo> get filteredTodos {
    if (selectedCategory == 'All') {
      return todos;
    }
    return todos.where((t) => t.category == selectedCategory).toList();
  }

  TodoState copyWith({
    List<KisaTodo>? todos,
    String? selectedCategory,
    bool? isLoading,
    bool? isCreating,
    String? errorMessage,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      errorMessage: errorMessage,
    );
  }
}

class TodoNotifier extends StateNotifier<TodoState> {
  final KisaSupabaseClient _supabaseClient;
  StreamSubscription<List<KisaTodo>>? _streamSubscription;

  TodoNotifier(this._supabaseClient) : super(const TodoState()) {
    unawaited(loadTodos());
    _initRealtimeStream();
  }

  void _initRealtimeStream() {
    _streamSubscription = _supabaseClient.streamTodos().listen(
      (realtimeList) {
        state = state.copyWith(todos: realtimeList, isLoading: false);
      },
      onError: (err) {
        // Silent fallback to standard fetch on connection drops
      },
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _supabaseClient.fetchTodos();
      state = state.copyWith(todos: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> toggleTodo(String todoId) async {
    final idx = state.todos.indexWhere((t) => t.id == todoId);
    if (idx == -1) return;

    final target = state.todos[idx];
    final newCompleted = !target.isCompleted;

    // 1. Optimistic UI update
    final updatedList = List<KisaTodo>.from(state.todos);
    updatedList[idx] = target.copyWith(isCompleted: newCompleted);
    state = state.copyWith(todos: updatedList);

    // 2. Persist to Supabase
    try {
      await _supabaseClient.toggleTodo(todoId, newCompleted);
    } catch (e) {
      // Revert upon error
      await loadTodos();
    }
  }

  Future<bool> createTodo({
    required String text,
    String category = '🍿 Movie',
    String priority = 'Med',
  }) async {
    state = state.copyWith(isCreating: true);
    try {
      final newTodo = await _supabaseClient.createTodo(
        text: text,
        category: category,
        priority: priority,
      );

      state = state.copyWith(
        todos: [newTodo, ...state.todos],
        isCreating: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> deleteTodo(String todoId) async {
    final updatedList = state.todos.where((t) => t.id != todoId).toList();
    state = state.copyWith(todos: updatedList);

    try {
      await _supabaseClient.deleteTodo(todoId);
    } catch (e) {
      await loadTodos();
    }
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier(KisaSupabaseClient());
});
