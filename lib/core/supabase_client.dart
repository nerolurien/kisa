import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/models/kisa_user.dart';
import '../features/todos/models/kisa_todo.dart';
import '../features/activities/models/kisa_activity.dart';
import '../features/map/models/kisa_location.dart';

/// Central BaaS client managing Supabase Auth, PostgreSQL tables,
/// Real-time sync, and fallback demo data for Kip & Pipit.
class KisaSupabaseClient {
  static final KisaSupabaseClient _instance = KisaSupabaseClient._internal();
  factory KisaSupabaseClient() => _instance;
  KisaSupabaseClient._internal();

  /// Supabase project URL loaded dynamically from .env or --dart-define
  static String get supabaseUrl {
    if (dotenv.isInitialized && (dotenv.env['SUPABASE_URL']?.isNotEmpty ?? false)) {
      return dotenv.env['SUPABASE_URL']!;
    }
    return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  }

  /// Supabase Anon / Publishable Key loaded dynamically from .env or --dart-define
  static String get supabaseAnonKey {
    if (dotenv.isInitialized && (dotenv.env['SUPABASE_ANON_KEY']?.isNotEmpty ?? false)) {
      return dotenv.env['SUPABASE_ANON_KEY']!;
    }
    return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  }

  SupabaseClient? _client;
  bool _isInitialized = false;

  bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('xyzcompany') &&
      !supabaseAnonKey.contains('dummy');

  bool get isLiveSupabase => _isInitialized && isConfigured;

  SupabaseClient get client {
    if (_client == null) {
      throw StateError('KisaSupabaseClient has not been initialized yet.');
    }
    return _client!;
  }

  // Local reactive couple cache (Kip & Pipit)
  KisaUser? _currentUser;
  KisaUser? _partnerUser;
  final List<KisaTodo> _cachedTodos = [];
  final List<KisaActivity> _cachedActivities = [];
  KisaLocation? _cachedPartnerLocation;

  KisaUser? get currentUser => _currentUser;
  KisaUser? get partnerUser => _partnerUser;

  void switchToDemoMode() {
    _setupInitialCoupleData();
  }

  /// Initialize Supabase with graceful fallback
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (isConfigured) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          // ignore: deprecated_member_use
          anonKey: supabaseAnonKey,
        );
        _client = Supabase.instance.client;
        _isInitialized = true;
        if (kDebugMode) debugPrint('[KisaSupabaseClient] Connected to live Supabase cloud');
      } catch (e) {
        if (kDebugMode) debugPrint('[KisaSupabaseClient] Supabase init warning: $e. Starting local engine.');
        _setupInitialCoupleData();
      }
    } else {
      if (kDebugMode) debugPrint('[KisaSupabaseClient] Running with local demo state.');
      _setupInitialCoupleData();
    }
  }

  void _setupInitialCoupleData() {
    _currentUser = KisaUser(
      id: 'usr_kip_01',
      email: 'kip@kisa.love',
      name: 'Kip',
      partnerId: 'usr_fexa_02',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      pairingCode: 'KIP-749',
      currentStatus: 'Lagi ngopi santai ☕',
      statusEmoji: '☕',
      statusUpdatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      createdAt: DateTime.now().subtract(const Duration(days: 280)),
    );

    _partnerUser = KisaUser(
      id: 'usr_fexa_02',
      email: 'fexa@kisa.love',
      name: 'Fexa',
      partnerId: 'usr_kip_01',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
      pairingCode: 'FEX-882',
      currentStatus: 'Sedang kerja di kantor 💼',
      statusEmoji: '💼',
      statusUpdatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      createdAt: DateTime.now().subtract(const Duration(days: 280)),
    );

    _cachedTodos.addAll([
      KisaTodo(
        id: 'todo_01',
        createdBy: 'usr_fexa_02',
        text: 'Nonton film Ghibli maraton sambil pesan pizza 🍕',
        isCompleted: true,
        category: '🍿 Movie',
        priority: 'High',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      KisaTodo(
        id: 'todo_02',
        createdBy: 'usr_kip_01',
        text: 'Jalan sore ke Pasar Santa cari vinyl & kopi susu',
        isCompleted: true,
        category: '🍲 Food',
        priority: 'Med',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      KisaTodo(
        id: 'todo_03',
        createdBy: 'usr_fexa_02',
        text: 'Road trip ke pantai liat sunrise bareng 🌊',
        isCompleted: false,
        category: '✈️ Trip',
        priority: 'High',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      KisaTodo(
        id: 'todo_04',
        createdBy: 'usr_kip_01',
        text: 'Beli tanaman monstera baru untuk pojok kamar',
        isCompleted: false,
        category: '🌱 Nest',
        priority: 'Low',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      KisaTodo(
        id: 'todo_05',
        createdBy: 'usr_kip_01',
        text: 'Backpacking ke Kyoto liat cherry blossom 🌸',
        isCompleted: false,
        category: '✈️ Trip',
        priority: 'High',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ]);

    _cachedActivities.addAll([
      KisaActivity(
        id: 'act_01',
        userId: 'usr_fexa_02',
        authorName: 'Fexa',
        authorAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
        content: 'Menemukan cafe mungil dengan taman rahasia di belakang stasiun. Kopi hazelnut-nya enak banget, aku simpan meja buat kamu!',
        moodEmoji: '☕',
        photoUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
        locationTag: 'Kedai Kopi Sudut Temu',
        likesCount: 14,
        isLikedByMe: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      KisaActivity(
        id: 'act_02',
        userId: 'usr_kip_01',
        authorName: 'Kip',
        authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        content: 'Langit sore ini warnanya pink keemasan. Langsung keinget senyummu tadi pagi pas pamitan ✨',
        moodEmoji: '🌅',
        photoUrl: 'https://images.unsplash.com/photo-1518495973542-4542c06a5843?auto=format&fit=crop&w=800&q=80',
        locationTag: 'Jembatan Penyeberangan Pinisi',
        likesCount: 22,
        isLikedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      KisaActivity(
        id: 'act_03',
        userId: 'usr_fexa_02',
        authorName: 'Fexa',
        authorAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
        content: 'Cangkir keramik handmade kita dari workshop minggu lalu udah jadi dan selesai dibakar! Nanti malam kita minum teh bareng yaa 🍵',
        moodEmoji: '✨',
        photoUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?auto=format&fit=crop&w=800&q=80',
        locationTag: 'Studio Tanah Liat Kita',
        likesCount: 19,
        isLikedByMe: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);

    _cachedPartnerLocation = KisaLocation(
      id: 'loc_01',
      userId: 'usr_fexa_02',
      userName: 'Fexa',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
      latitude: -6.2297,
      longitude: 106.8167,
      updatedAt: DateTime.now().subtract(const Duration(minutes: 4)),
    );
  }

  // =========================================================================
  // AUTH & PAIRING
  // =========================================================================

  Future<KisaUser> signIn({required String email, required String password}) async {
    if (isLiveSupabase) {
      try {
        final res = await client.auth.signInWithPassword(email: email, password: password);
        final userId = res.user?.id;
        if (userId == null) throw Exception('Email atau kata sandi salah.');
        final profile = await getUserProfile(userId, fallbackEmail: email);
        _currentUser = profile;
        return profile;
      } on AuthApiException catch (e) {
        final msg = e.message.toLowerCase();
        if (msg.contains('email not confirmed')) {
          throw Exception(
            'Email belum dikonfirmasi. Cek link di kotak masuk/spam email Anda, atau matikan "Confirm email" di Dashboard Supabase > Authentication > Providers > Email.',
          );
        } else if (msg.contains('invalid login credentials')) {
          throw Exception('Email atau kata sandi tidak cocok. Jika belum punya akun, silakan klik tab "Daftar Akun" di atas.');
        }
        throw Exception(e.message);
      } catch (e) {
        rethrow;
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = _currentUser?.copyWith(email: email) ??
        KisaUser(
          id: 'usr_kip_01',
          email: email,
          name: email.split('@').first,
          pairingCode: 'KIP-749',
          createdAt: DateTime.now(),
        );
    return _currentUser!;
  }

  Future<KisaUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (isLiveSupabase) {
      try {
        final res = await client.auth.signUp(
          email: email,
          password: password,
          data: {'name': name},
        );
        final user = res.user;
        if (user == null) throw Exception('Pendaftaran akun gagal. Silakan coba lagi.');

        final newUser = KisaUser(
          id: user.id,
          email: email,
          name: name,
          pairingCode: _generatePairingCode(name),
          createdAt: DateTime.now(),
        );

        // Attempt direct upsert into public.users in case trigger hasn't fired yet
        try {
          await client.from('users').upsert(newUser.toJson());
        } catch (e) {
          if (kDebugMode) debugPrint('[KisaSupabaseClient] Notice on users upsert: $e');
        }

        if (res.session == null) {
          throw Exception(
            'Akun $email berhasil didaftarkan!\n\nKarena opsi "Confirm email" aktif di Supabase, silakan verifikasi email Anda atau nonaktifkan "Confirm email" di Dashboard Supabase > Authentication > Providers > Email agar langsung bisa masuk.',
          );
        }

        _currentUser = newUser;
        return newUser;
      } on AuthApiException catch (e) {
        final msg = e.message.toLowerCase();
        if (msg.contains('user already registered')) {
          throw Exception('Email ini sudah terdaftar. Silakan pilih tab "Masuk" untuk login.');
        } else if (msg.contains('password should be at least')) {
          throw Exception('Kata sandi minimal harus 6 karakter.');
        }
        throw Exception(e.message);
      } catch (e) {
        rethrow;
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = KisaUser(
      id: 'usr_kip_01',
      email: email,
      name: name,
      pairingCode: _generatePairingCode(name),
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  Future<void> signOut() async {
    if (isLiveSupabase) {
      await client.auth.signOut();
    }
    _currentUser = null;
    _partnerUser = null;
  }

  Future<KisaUser> getUserProfile(
    String userId, {
    String? fallbackEmail,
    String? fallbackName,
  }) async {
    if (isLiveSupabase) {
      final res = await client.from('users').select().eq('id', userId).maybeSingle();
      if (res != null) {
        final profile = KisaUser.fromJson(res);
        _currentUser = profile;
        return profile;
      }

      // Auto-heal missing profile in public.users
      final email = fallbackEmail ?? client.auth.currentUser?.email ?? 'user@kisa.love';
      final name = fallbackName ?? client.auth.currentUser?.userMetadata?['name'] ?? email.split('@').first;
      final pairingCode = _generatePairingCode(name);

      final profileMap = {
        'id': userId,
        'email': email,
        'name': name,
        'pairing_code': pairingCode,
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        await client.from('users').upsert(profileMap);
      } catch (e) {
        if (kDebugMode) debugPrint('[KisaSupabaseClient] Auto-heal warning: $e');
      }

      final healedUser = KisaUser.fromJson(profileMap);
      _currentUser = healedUser;
      return healedUser;
    }
    return _currentUser!;
  }

  Future<KisaUser?> getPartnerProfile(String? partnerId) async {
    if (partnerId == null || partnerId.isEmpty) return null;
    if (isLiveSupabase) {
      try {
        final res = await client.from('users').select().eq('id', partnerId).maybeSingle();
        if (res == null) return null;
        return KisaUser.fromJson(res);
      } catch (e) {
        return null;
      }
    }
    return _partnerUser;
  }

  /// Real-time stream for user profile (including status changes)
  Stream<KisaUser?> streamUser(String userId) {
    if (isLiveSupabase && userId.isNotEmpty) {
      return client
          .from('users')
          .stream(primaryKey: ['id'])
          .eq('id', userId)
          .map((records) {
            if (records.isEmpty) return null;
            return KisaUser.fromJson(records.first);
          });
    }
    return Stream.value(userId == _currentUser?.id ? _currentUser : _partnerUser);
  }

  /// Update current user live activity status
  Future<void> updateMyStatus({required String status, required String emoji}) async {
    final now = DateTime.now();
    _currentUser = _currentUser?.copyWith(
      currentStatus: status,
      statusEmoji: emoji,
      statusUpdatedAt: now,
    );

    if (isLiveSupabase && _currentUser != null) {
      await client.from('users').update({
        'current_status': status,
        'status_emoji': emoji,
        'status_updated_at': now.toIso8601String(),
      }).eq('id', _currentUser!.id);
    }
  }

  Future<bool> pairWithCode(String targetCode) async {
    final cleanCode = targetCode.trim().toUpperCase();
    if (isLiveSupabase) {
      final res = await client.rpc('pair_with_code', params: {'target_code': cleanCode});
      if (res != null && res['success'] == true) {
        return true;
      } else {
        throw Exception(res?['message'] ?? 'Kode pairing tidak valid');
      }
    }

    // Local simulation for pairing
    await Future.delayed(const Duration(milliseconds: 600));
    if (cleanCode == 'FEX-882' || cleanCode.length >= 6) {
      _currentUser = _currentUser?.copyWith(partnerId: 'usr_fexa_02');
      _partnerUser = _partnerUser?.copyWith(partnerId: _currentUser?.id);
      return true;
    }
    throw Exception('Kode pairing tidak ditemukan. Pastikan kodenya sama dengan di HP pasangan!');
  }

  /// Update user profile details (name, avatar, bio, anniversary)
  Future<void> updateProfile({
    required String name,
    String? avatarUrl,
    String? bio,
    DateTime? anniversaryDate,
  }) async {
    _currentUser = _currentUser?.copyWith(
      name: name,
      avatarUrl: avatarUrl,
      bio: bio,
      anniversaryDate: anniversaryDate,
    );

    if (isLiveSupabase && _currentUser != null) {
      final updateData = <String, dynamic>{
        'name': name,
      };
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (anniversaryDate != null) {
        updateData['anniversary_date'] = anniversaryDate.toIso8601String();
      }

      await client.from('users').update(updateData).eq('id', _currentUser!.id);
    }
  }

  // =========================================================================
  // TODOS & SHARED BUCKET LIST
  // =========================================================================

  /// Real-time stream for shared todos
  Stream<List<KisaTodo>> streamTodos() {
    if (isLiveSupabase) {
      return client
          .from('todos')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((records) => records.map((e) => KisaTodo.fromJson(e)).toList());
    }
    return Stream.value(List.from(_cachedTodos));
  }

  Future<List<KisaTodo>> fetchTodos() async {
    if (isLiveSupabase) {
      final res = await client.from('todos').select().order('created_at', ascending: false);
      return (res as List).map((e) => KisaTodo.fromJson(e)).toList();
    }
    return List.from(_cachedTodos);
  }

  Future<KisaTodo> createTodo({
    required String text,
    String category = '🍿 Movie',
    String priority = 'Med',
  }) async {
    final newTodo = KisaTodo(
      id: 'todo_${DateTime.now().millisecondsSinceEpoch}',
      createdBy: _currentUser?.id ?? 'usr_kip_01',
      text: text,
      isCompleted: false,
      category: category,
      priority: priority,
      createdAt: DateTime.now(),
    );

    if (isLiveSupabase) {
      final res = await client.from('todos').insert(newTodo.toJson()).select().single();
      return KisaTodo.fromJson(res);
    }

    _cachedTodos.insert(0, newTodo);
    return newTodo;
  }

  Future<void> toggleTodo(String todoId, bool isCompleted) async {
    final idx = _cachedTodos.indexWhere((t) => t.id == todoId);
    if (idx != -1) {
      _cachedTodos[idx] = _cachedTodos[idx].copyWith(isCompleted: isCompleted);
    }

    if (isLiveSupabase) {
      await client.from('todos').update({'is_completed': isCompleted}).eq('id', todoId);
    }
  }

  Future<void> deleteTodo(String todoId) async {
    _cachedTodos.removeWhere((t) => t.id == todoId);
    if (isLiveSupabase) {
      await client.from('todos').delete().eq('id', todoId);
    }
  }

  // =========================================================================
  // ACTIVITIES (SCRAPBOOK FEED)
  // =========================================================================

  /// Real-time stream for scrapbook activities
  Stream<List<KisaActivity>> streamActivities() {
    if (isLiveSupabase) {
      return client
          .from('activities')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((records) => records
              .map((item) => KisaActivity.fromJson(item, currentUserId: _currentUser?.id ?? ''))
              .toList());
    }
    return Stream.value(List.from(_cachedActivities));
  }

  Future<List<KisaActivity>> fetchActivities() async {
    if (isLiveSupabase) {
      final res = await client
          .from('activities')
          .select('*, users:user_id(name, avatar_url)')
          .order('created_at', ascending: false);
      return (res as List)
          .map((item) => KisaActivity.fromJson(item, currentUserId: _currentUser?.id ?? ''))
          .toList();
    }
    return List.from(_cachedActivities);
  }

  Future<KisaActivity> createActivity({
    required String content,
    String moodEmoji = '✨',
    String? photoUrl,
    String? locationTag,
  }) async {
    final newActivity = KisaActivity(
      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser?.id ?? 'usr_kip_01',
      authorName: _currentUser?.name ?? 'Kip',
      authorAvatar: _currentUser?.avatarUrl,
      content: content,
      moodEmoji: moodEmoji,
      photoUrl: photoUrl,
      locationTag: locationTag,
      likesCount: 0,
      isLikedByMe: false,
      createdAt: DateTime.now(),
    );

    if (isLiveSupabase) {
      final res = await client.from('activities').insert(newActivity.toJson()).select().single();
      return KisaActivity.fromJson(res);
    }

    _cachedActivities.insert(0, newActivity);
    return newActivity;
  }

  Future<void> toggleLike(String activityId) async {
    final idx = _cachedActivities.indexWhere((a) => a.id == activityId);
    if (idx != -1) {
      final item = _cachedActivities[idx];
      final newLiked = !item.isLikedByMe;
      final newCount = newLiked ? item.likesCount + 1 : (item.likesCount > 0 ? item.likesCount - 1 : 0);
      _cachedActivities[idx] = item.copyWith(isLikedByMe: newLiked, likesCount: newCount);
    }

    if (isLiveSupabase) {
      await client.rpc('toggle_activity_like', params: {'activity_id': activityId});
    }
  }

  // =========================================================================
  // LIVE LOCATIONS & BACKGROUND MAP TRACKING
  // =========================================================================

  /// Real-time stream for partner's live GPS coordinates
  Stream<KisaLocation?> streamPartnerLocation(String partnerId) {
    if (isLiveSupabase && partnerId.isNotEmpty) {
      return client
          .from('locations')
          .stream(primaryKey: ['id'])
          .eq('user_id', partnerId)
          .map((records) {
            if (records.isEmpty) return null;
            return KisaLocation.fromJson(records.first);
          });
    }
    return Stream.value(_cachedPartnerLocation);
  }

  Future<KisaLocation?> getPartnerLocation() async {
    if (isLiveSupabase && _currentUser?.partnerId != null) {
      final res = await client
          .from('locations')
          .select('*, users:user_id(name, avatar_url)')
          .eq('user_id', _currentUser!.partnerId!)
          .maybeSingle();
      if (res != null) {
        return KisaLocation.fromJson(res);
      }
    }
    return _cachedPartnerLocation;
  }

  Future<void> updateMyLocation({
    required double latitude,
    required double longitude,
  }) async {
    if (isLiveSupabase && _currentUser != null) {
      await client.from('locations').upsert({
        'user_id': _currentUser!.id,
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  String _generatePairingCode(String name) {
    final prefix = name.isNotEmpty ? name.substring(0, name.length >= 3 ? 3 : name.length).toUpperCase() : 'KIS';
    final randomPart = (100 + (DateTime.now().millisecond % 900)).toString();
    return '$prefix-$randomPart';
  }
}
