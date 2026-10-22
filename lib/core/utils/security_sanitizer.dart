/// Central Security, Validation, Sanitization, and Error Shield for Kisa App
class KisaSecurity {
  // RFC 5322 Compliant Email Regex
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  // Dangerous script/HTML patterns
  static final RegExp _htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
  static final RegExp _scriptRegex = RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false);
  static final RegExp _controlCharsRegex = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');

  /// Sanitize user string inputs: remove dangerous script tags, HTML tags, control chars, and enforce length limits
  static String sanitize(String input, {int maxLength = 255}) {
    String clean = input.replaceAll(_scriptRegex, '');
    clean = clean.replaceAll(_htmlTagRegex, '');
    clean = clean.replaceAll(_controlCharsRegex, '');
    clean = clean.trim();
    if (clean.length > maxLength) {
      clean = clean.substring(0, maxLength);
    }
    return clean;
  }

  /// Validate Email address format
  static bool isValidEmail(String email) {
    final clean = email.trim();
    if (clean.isEmpty || clean.length > 100) return false;
    return _emailRegex.hasMatch(clean);
  }

  /// Validate Password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Kata sandi wajib diisi.';
    }
    if (password.length < 6) {
      return 'Kata sandi minimal 6 karakter demi keamanan akunmu 🔒';
    }
    if (password.length > 72) {
      return 'Kata sandi maksimal 72 karakter.';
    }
    return null;
  }

  /// Validate Display Name
  static String? validateName(String name) {
    final clean = sanitize(name, maxLength: 50);
    if (clean.isEmpty) {
      return 'Nama panggilan wajib diisi.';
    }
    if (clean.length < 2) {
      return 'Nama panggilan minimal 2 karakter.';
    }
    if (clean.length > 30) {
      return 'Nama panggilan maksimal 30 karakter.';
    }
    return null;
  }

  /// Transform raw system / Postgres / Supabase / Socket exceptions into friendly, non-leaking user messages
  static String toSafeErrorMessage(dynamic error) {
    if (error == null) return 'Terjadi kendala. Silakan coba lagi.';

    final raw = error.toString().toLowerCase();

    // 1. Authentication Credentials
    if (raw.contains('invalid login credentials') ||
        raw.contains('invalid_credentials') ||
        raw.contains('invalid_grant')) {
      return 'Email atau kata sandi tidak cocok. Silakan periksa kembali ya.';
    }

    // 2. Email Confirmation
    if (raw.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Silakan cek tautan verifikasi di kotak masuk emailmu.';
    }

    // 3. User Already Exists
    if (raw.contains('user already registered') ||
        raw.contains('already_registered') ||
        raw.contains('unique constraint') ||
        raw.contains('users_email_key')) {
      return 'Email ini sudah terdaftar. Silakan langsung masuk di tab "Masuk".';
    }

    // 4. Rate Limiting / Brute Force Protection from Server
    if (raw.contains('rate limit') ||
        raw.contains('too many requests') ||
        raw.contains('over_email_send_rate_limit') ||
        raw.contains('429')) {
      return 'Terlalu banyak percobaan. Demi keamananmu, silakan tunggu beberapa menit.';
    }

    // 5. Network / Timeout / Connectivity
    if (raw.contains('socketexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('connection refused') ||
        raw.contains('connection reset') ||
        raw.contains('timeout') ||
        raw.contains('handshakeexception') ||
        raw.contains('network is unreachable')) {
      return 'Koneksi internet tidak stabil. Pastikan paket data atau Wi-Fi kamu aktif ya.';
    }

    // 6. Pairing Code Specifics
    if (raw.contains('kode pairing') || raw.contains('target_code') || raw.contains('pairing')) {
      if (raw.contains('tidak ditemukan') || raw.contains('tidak valid')) {
        return 'Kode pairing tidak ditemukan. Pastikan kodenya sama persis dengan di HP pasangan.';
      }
      if (raw.contains('sudah memiliki pasangan') || raw.contains('already paired')) {
        return 'Akun ini atau pasanganmu sudah terhubung dengan akun lain.';
      }
    }

    // 7. Password rules
    if (raw.contains('password should be at least')) {
      return 'Kata sandi minimal 6 karakter.';
    }

    // Safe, non-verbose fallback (Never leaks SQL queries, table schemas, or stack traces!)
    return 'Terjadi kendala pada sistem. Silakan coba sesaat lagi.';
  }
}

/// In-memory Client Rate Limiter to prevent brute-force attempts
class ClientRateLimiter {
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  bool get isLockedOut {
    if (_lockoutUntil == null) return false;
    if (DateTime.now().isBefore(_lockoutUntil!)) {
      return true;
    }
    // Lockout expired
    _lockoutUntil = null;
    _failedAttempts = 0;
    return false;
  }

  int get remainingLockoutSeconds {
    if (_lockoutUntil == null) return 0;
    final diff = _lockoutUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  void recordFailure() {
    _failedAttempts++;
    if (_failedAttempts >= 5) {
      // Lock out for 30 seconds after 5 failed attempts
      _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
    } else if (_failedAttempts >= 3) {
      // Mild warning threshold
    }
  }

  void reset() {
    _failedAttempts = 0;
    _lockoutUntil = null;
  }
}
