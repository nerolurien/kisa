import 'package:flutter/material.dart';

/// Design tokens for Kisa - Premium Soft Modern & Cozy Intimate Aesthetic
class KisaColors {
  // Backgrounds: Soft, warm, off-white / subtle cream (Strictly avoid pure white #FFFFFF or harsh pure black)
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundWarm = Color(0xFFF5F4F0);
  static const Color surface = Color(0xFFFCFCFB);
  static const Color surfaceGlass =
      Color(0xF2FCFCFB); // ~95% opacity off-white cream
  static const Color glassFill =
      Color(0xD9FCFCFB); // ~85% opacity off-white cream

  // Primary Accent: Warm Rose / Blush (#f43f5e per PRD)
  static const Color primaryRose = Color(0xFFF43F5E);
  static const Color primaryRoseHover = Color(0xFFE11D48);
  static const Color blushSoft = Color(0xFFFFECEF);
  static const Color blushMedium = Color(0xFFFFD1D8);
  static const Color roseGlow = Color(0x1AF43F5E); // Ultra-soft subtle glow

  // Auxiliary Soft Cozy Accents for Categories & Scrapbook
  static const Color peach = Color(0xFFF97316);
  static const Color peachSoft = Color(0xFFFFEDD5);
  static const Color chamomile = Color(0xFFF59E0B);
  static const Color chamomileSoft = Color(0xFFFEF3C7);
  static const Color sage = Color(0xFF10B981);
  static const Color sageSoft = Color(0xFFD1FAE5);
  static const Color sky = Color(0xFF0EA5E9);
  static const Color skySoft = Color(0xFFE0F2FE);
  static const Color lavender = Color(0xFF8B5CF6);
  static const Color lavenderSoft = Color(0xFFEDE9FE);

  // Typography: Slate & Zinc (Strictly avoid pure black #000000)
  static const Color textPrimary = Color(0xFF1E293B); // Slate-800 for headings
  static const Color textSecondary = Color(0xFF64748B); // Slate-500 for body
  static const Color textMuted = Color(0xFF64748B); // Slate-500
  static const Color textLight = Color(0xFF94A3B8); // Slate-400

  // Subtle Borders
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderGlass = Color(0x66FCFCFB);

  // Intimate Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFB7185), // Rose-400
      Color(0xFFF43F5E), // Rose-500
    ],
  );

  static const LinearGradient loveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFDA4AF),
      Color(0xFFF43F5E),
      Color(0xFFBE123C),
    ],
  );
}
