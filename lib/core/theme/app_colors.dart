import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary Palette ─────────────────────────────────────────────
  static const Color deepPurple = Color(0xFF1A0A3E);
  static const Color purple = Color(0xFF2D1B69);
  static const Color blueViolet = Color(0xFF3A2080);
  static const Color lavender = Color(0xFF6C4AB6);
  static const Color softLavender = Color(0xFF8B6FC0);

  // ─── Accent Colors ───────────────────────────────────────────────
  static const Color magenta = Color(0xFFD946EF);
  static const Color softMagenta = Color(0xFFE879F9);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color softCyan = Color(0xFF67E8F9);
  static const Color accentBlue = Color(0xFF818CF8);

  // ─── Dark Theme Surfaces ─────────────────────────────────────────
  static const Color darkBg = Color(0xFF0D0620);
  static const Color darkSurface = Color(0xFF150B35);
  static const Color darkCard = Color(0xFF1E1245);
  static const Color darkElevated = Color(0xFF281A55);

  // ─── Light Theme Surfaces ────────────────────────────────────────
  static const Color lightBg = Color(0xFFF0ECFA);
  static const Color lightSurface = Color(0xFFF8F5FF);
  static const Color lightCard = Color(0xFFEDE7F9);
  static const Color lightElevated = Color(0xFFE4DCFF);

  // ─── Glass Effect Colors ─────────────────────────────────────────
  static const Color glassDarkBg = Color(0x33FFFFFF);
  static const Color glassDarkBorder = Color(0x22FFFFFF);
  static const Color glassLightBg = Color(0x55FFFFFF);
  static const Color glassLightBorder = Color(0x44FFFFFF);

  // ─── Text Colors ─────────────────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFF1F0FF);
  static const Color darkTextSecondary = Color(0xFF9B8EC4);
  static const Color darkTextTertiary = Color(0xFF6B5B8D);
  static const Color lightTextPrimary = Color(0xFF1A0A3E);
  static const Color lightTextSecondary = Color(0xFF6B5B8D);
  static const Color lightTextTertiary = Color(0xFF9B8EC4);

  // ─── Functional Colors ───────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color favorite = Color(0xFFEF4444);

  // ─── Active / Indicator ──────────────────────────────────────────
  static const Color activeIndicator = Color(0xFF22D3EE);
  static const Color activeGlow = Color(0x4422D3EE);

  // ─── Gradients ───────────────────────────────────────────────────

  /// Main background gradient — deep purple to blue-violet
  static const LinearGradient darkBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A0A3E),
      Color(0xFF150B35),
      Color(0xFF0D0620),
    ],
  );

  /// Light background gradient — soft lavender
  static const LinearGradient lightBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF0ECFA),
      Color(0xFFE8E0F8),
      Color(0xFFDDD4F4),
    ],
  );

  /// Now Playing background — rich deep purple
  static const LinearGradient nowPlayingDarkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2D1B69),
      Color(0xFF1A0A3E),
      Color(0xFF0D0620),
    ],
  );

  /// Now Playing light — soft purple
  static const LinearGradient nowPlayingLightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE4DCFF),
      Color(0xFFD5CAFF),
      Color(0xFFC8BBFF),
    ],
  );

  /// Accent gradient — purple to magenta
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6C4AB6),
      Color(0xFFD946EF),
    ],
  );

  /// Card gradient — dark subtle
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E1245),
      Color(0xFF281A55),
    ],
  );

  /// Glass gradient — frosted overlay
  static const LinearGradient glassGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x28FFFFFF),
      Color(0x0AFFFFFF),
    ],
  );

  static const LinearGradient glassGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x80FFFFFF),
      Color(0x40FFFFFF),
    ],
  );

  /// Cyan glow gradient for playhead
  static const LinearGradient cyanGlowGradient = LinearGradient(
    colors: [
      Color(0xFF22D3EE),
      Color(0xFF818CF8),
    ],
  );

  /// Featured playlist card mesh gradient
  static const LinearGradient meshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D0620),
      Color(0xFF1A0A3E),
      Color(0xFF2D1B69),
      Color(0xFF1A1060),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
}
