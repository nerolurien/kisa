import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../models/kisa_activity.dart';

class ActivityState {
  final List<KisaActivity> activities;
  final bool isLoading;
  final bool isCreating;
  final String? errorMessage;

  const ActivityState({
    this.activities = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.errorMessage,
  });

  ActivityState copyWith({
    List<KisaActivity>? activities,
    bool? isLoading,
    bool? isCreating,
    String? errorMessage,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      errorMessage: errorMessage,
    );
  }
}

class ActivityNotifier extends StateNotifier<ActivityState> {
  final KisaSupabaseClient _supabaseClient;
  StreamSubscription<List<KisaActivity>>? _streamSubscription;

  ActivityNotifier(this._supabaseClient) : super(const ActivityState()) {
    unawaited(loadActivities());
    _initRealtimeStream();
  }

  void _initRealtimeStream() {
    _streamSubscription = _supabaseClient.streamActivities().listen(
      (realtimeActivities) {
        state =
            state.copyWith(activities: realtimeActivities, isLoading: false);
      },
      onError: (err) {
        // Silent fallback on stream error
      },
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadActivities() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _supabaseClient.fetchActivities();
      state = state.copyWith(activities: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> createActivity({
    required String content,
    String moodEmoji = '✨',
    String? photoUrl,
    String? locationTag,
  }) async {
    state = state.copyWith(isCreating: true);
    try {
      final newAct = await _supabaseClient.createActivity(
        content: content,
        moodEmoji: moodEmoji,
        photoUrl: photoUrl,
        locationTag: locationTag,
      );

      state = state.copyWith(
        activities: [newAct, ...state.activities],
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

  Future<void> toggleLike(String activityId) async {
    // Optimistic double-tap love update
    final updatedList = state.activities.map((item) {
      if (item.id == activityId) {
        final newIsLiked = !item.isLikedByMe;
        final newCount = newIsLiked
            ? item.likesCount + 1
            : (item.likesCount > 0 ? item.likesCount - 1 : 0);
        return item.copyWith(isLikedByMe: newIsLiked, likesCount: newCount);
      }
      return item;
    }).toList();

    state = state.copyWith(activities: updatedList);

    try {
      await _supabaseClient.toggleLike(activityId);
    } catch (e) {
      await loadActivities();
    }
  }
}

final activityProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  return ActivityNotifier(KisaSupabaseClient());
});
