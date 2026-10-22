import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../../../core/utils/security_sanitizer.dart';
import '../models/kisa_user.dart';

class AuthState {
  final KisaUser? user;
  final KisaUser? partner;
  final bool isLoading;
  final String? errorMessage;
  final bool isPaired;

  const AuthState({
    this.user,
    this.partner,
    this.isLoading = false,
    this.errorMessage,
    this.isPaired = false,
  });

  AuthState copyWith({
    KisaUser? user,
    KisaUser? partner,
    bool? isLoading,
    String? errorMessage,
    bool? isPaired,
  }) {
    return AuthState(
      user: user ?? this.user,
      partner: partner ?? this.partner,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isPaired: isPaired ?? this.isPaired,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final KisaSupabaseClient _supabaseClient;
  StreamSubscription<KisaUser?>? _partnerStreamSub;

  AuthNotifier(this._supabaseClient) : super(const AuthState()) {
    initAuth();
  }

  void _listenToPartner(String partnerId) {
    _partnerStreamSub?.cancel();
    _partnerStreamSub =
        _supabaseClient.streamUser(partnerId).listen((updatedPartner) {
      if (updatedPartner != null) {
        state = state.copyWith(partner: updatedPartner);
      }
    });
  }

  @override
  void dispose() {
    _partnerStreamSub?.cancel();
    super.dispose();
  }

  Future<void> updateStatus(
      {required String status, required String emoji}) async {
    if (state.user == null) return;
    final updated = state.user!.copyWith(
      currentStatus: status,
      statusEmoji: emoji,
      statusUpdatedAt: DateTime.now(),
    );
    state = state.copyWith(user: updated);
    await _supabaseClient.updateMyStatus(status: status, emoji: emoji);
  }

  Future<bool> updateProfile({
    required String name,
    String? avatarUrl,
    String? bio,
    DateTime? anniversaryDate,
  }) async {
    if (state.user == null) return false;
    try {
      await _supabaseClient.updateProfile(
        name: name,
        avatarUrl: avatarUrl,
        bio: bio,
        anniversaryDate: anniversaryDate,
      );
      final updated = state.user!.copyWith(
        name: name,
        avatarUrl: avatarUrl,
        bio: bio,
        anniversaryDate: anniversaryDate,
      );
      state = state.copyWith(user: updated);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> initAuth() async {
    state = state.copyWith(isLoading: true);
    await _supabaseClient.initialize();
    try {
      if (_supabaseClient.isLiveSupabase) {
        final currentAuthUser = _supabaseClient.client.auth.currentUser;
        if (currentAuthUser != null) {
          final user = await _supabaseClient.getUserProfile(currentAuthUser.id);
          KisaUser? partner;
          if (user.partnerId != null) {
            partner = await _supabaseClient.getPartnerProfile(user.partnerId);
            _listenToPartner(user.partnerId!);
          }
          state = state.copyWith(
            user: user,
            partner: partner,
            isPaired: user.isPaired,
            isLoading: false,
          );
          return;
        } else {
          // Unauthenticated -> display login/register form
          state = state.copyWith(
            user: null,
            partner: null,
            isPaired: false,
            isLoading: false,
          );
          return;
        }
      }

      final user = await _supabaseClient.getUserProfile('usr_kip_01');
      KisaUser? partner;
      if (user.partnerId != null) {
        partner = await _supabaseClient.getPartnerProfile(user.partnerId);
        _listenToPartner(user.partnerId!);
      }
      state = state.copyWith(
        user: user,
        partner: partner,
        isPaired: user.isPaired,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(user: null, isLoading: false);
    }
  }

  void loginWithDemoMode() {
    _supabaseClient.switchToDemoMode();
    final user = _supabaseClient.currentUser;
    final partner = _supabaseClient.partnerUser;
    if (partner != null) {
      _listenToPartner(partner.id);
    }
    state = state.copyWith(
      user: user,
      partner: partner,
      isPaired: true,
      isLoading: false,
      errorMessage: null,
    );
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user =
          await _supabaseClient.signIn(email: email, password: password);
      KisaUser? partner;
      if (user.partnerId != null) {
        partner = await _supabaseClient.getPartnerProfile(user.partnerId);
        _listenToPartner(user.partnerId!);
      }
      state = state.copyWith(
        user: user,
        partner: partner,
        isPaired: user.isPaired,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: KisaSecurity.toSafeErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _supabaseClient.signUp(
        email: email,
        password: password,
        name: name,
      );
      state = state.copyWith(
        user: user,
        partner: null,
        isPaired: false,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: KisaSecurity.toSafeErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> pairWithPartner(String partnerCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabaseClient.pairWithCode(partnerCode);
      if (state.user != null) {
        final updatedUser =
            await _supabaseClient.getUserProfile(state.user!.id);
        final partner =
            await _supabaseClient.getPartnerProfile(updatedUser.partnerId);
        if (partner != null) {
          _listenToPartner(partner.id);
        }
        state = state.copyWith(
          user: updatedUser,
          partner: partner,
          isPaired: true,
          isLoading: false,
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: KisaSecurity.toSafeErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(KisaSupabaseClient());
});
