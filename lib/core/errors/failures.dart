import 'package:flutter/foundation.dart';

/// Base enterprise failure class representing typed application domain errors.
@immutable
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Server or BaaS (Supabase) communication failure
class ServerFailure extends Failure {
  const ServerFailure(
      [super.message =
          'Terjadi kendala pada server. Coba beberapa saat lagi.']);
}

/// Network connectivity / offline failure
class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'Koneksi internet tidak stabil. Memuat data lokal...']);
}

/// Authentication and session authorization failure
class AuthFailure extends Failure {
  const AuthFailure(
      [super.message = 'Sesi masuk telah berakhir. Silakan login kembali.']);
}

/// Client-side input or data validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Hardware location & GPS tracking failure
class LocationFailure extends Failure {
  const LocationFailure(
      [super.message =
          'Gagal mengakses GPS perangkat. Pastikan izin lokasi aktif.']);
}
