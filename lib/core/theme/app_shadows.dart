import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Ultra-soft diffused shadows tinted with warm rose and slate tones
class KisaShadows {
  /// Whisper subtle shadow for list tiles and small chips
  static final List<BoxShadow> subtle = [
    BoxShadow(
      color: const Color(0xFF1E293B).withValues(alpha: 0.03),
      blurRadius: 18,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: KisaColors.primaryRose.withValues(alpha: 0.02),
      blurRadius: 16,
      spreadRadius: 1,
      offset: const Offset(0, 2),
    ),
  ];

  /// Soft modern card shadow (Tinted with warm rose & slate, ultra diffused)
  static final List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF1E293B).withValues(alpha: 0.03),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: KisaColors.primaryRose.withValues(alpha: 0.04),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 2),
    ),
  ];

  /// Floating spatial shadow for floating bottom bars and modal sheets
  static final List<BoxShadow> floating = [
    BoxShadow(
      color: const Color(0xFF1E293B).withValues(alpha: 0.05),
      blurRadius: 32,
      spreadRadius: -2,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: KisaColors.primaryRose.withValues(alpha: 0.05),
      blurRadius: 20,
      spreadRadius: 4,
      offset: const Offset(0, 4),
    ),
  ];

  /// Warm glowing shadow for active action buttons
  static final List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: KisaColors.primaryRose.withValues(alpha: 0.28),
      blurRadius: 22,
      spreadRadius: -1,
      offset: const Offset(0, 6),
    ),
  ];

  /// Frosted glass border highlight
  static final Border glassBorder = Border.all(
    color: const Color(0xFFFCFCFB).withValues(alpha: 0.85),
    width: 1.2,
  );

  static final Border subtleBorder = Border.all(
    color: KisaColors.borderSubtle.withValues(alpha: 0.8),
    width: 1.0,
  );
}
