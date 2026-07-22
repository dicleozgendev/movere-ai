import 'package:flutter/material.dart';

/// Movere AI Color Palette — "Move Beyond" design identity
/// Deep black-green background + neon green accent.
/// Reference: brand design (dark theme is the app's natural state).
class AppColors {
  AppColors._();

  // ---- Primary (Neon Green) ----
  static const Color primary = Color(0xFF4ADE80); // neon green (CTA, highlights)
  static const Color primaryLight = Color(0xFF86EFAC);
  static const Color primaryDark = Color(0xFF22C55E);

  // ---- Secondary (Teal-Green, the cool end of the gradient) ----
  static const Color secondary = Color(0xFF34D399);
  static const Color secondaryLight = Color(0xFF6EE7B7);
  static const Color secondaryDark = Color(0xFF10B981);

  // ---- Accent ----
  static const Color accent = Color(0xFF86EFAC);

  // ---- Dark (default theme) ----
  static const Color backgroundDark = Color(0xFF0A0E0C); // deep black-green
  static const Color surfaceDark = Color(0xFF131A16); // card background
  static const Color surfaceMutedDark = Color(0xFF1A231E); // secondary surface
  static const Color borderDark = Color(0xFF23302A);

  // ---- Light (secondary theme) ----
  static const Color background = Color(0xFFF6FAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEDF4EF);
  static const Color border = Color(0xFFDCE7E0);

  // ---- Metin ----
  static const Color textPrimaryDark = Color(0xFFF2F7F4);
  static const Color textSecondaryDark = Color(0xFF8FA69B);
  static const Color textPrimary = Color(0xFF13201A);
  static const Color textSecondary = Color(0xFF5B6E64);
  static const Color textOnPrimary = Color(0xFF06130B); // dark text on top of the neon button

  // ---- Semantic ----
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFACC15);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF38BDF8);

  // ---- Gradientler ----
  /// Logo/progress ring gradient: from teal to neon green.
  static const List<Color> brandGradient = [secondaryDark, primary];
  static const List<Color> realityScoreGradient = brandGradient;
}
