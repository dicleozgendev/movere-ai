import 'package:flutter/material.dart';

/// Movere AI Renk Paleti — "Move Beyond" tasarım kimliği
/// Derin siyah-yeşil zemin + neon yeşil aksan.
/// Referans: marka tasarımı (koyu tema uygulamanın doğal hali).
class AppColors {
  AppColors._();

  // ---- Primary (Neon Yeşil) ----
  static const Color primary = Color(0xFF4ADE80); // neon yeşil (CTA, vurgular)
  static const Color primaryLight = Color(0xFF86EFAC);
  static const Color primaryDark = Color(0xFF22C55E);

  // ---- Secondary (Teal-Yeşil, gradient'in soğuk ucu) ----
  static const Color secondary = Color(0xFF34D399);
  static const Color secondaryLight = Color(0xFF6EE7B7);
  static const Color secondaryDark = Color(0xFF10B981);

  // ---- Accent ----
  static const Color accent = Color(0xFF86EFAC);

  // ---- Dark (varsayılan tema) ----
  static const Color backgroundDark = Color(0xFF0A0E0C); // derin siyah-yeşil
  static const Color surfaceDark = Color(0xFF131A16); // kart zemini
  static const Color surfaceMutedDark = Color(0xFF1A231E); // ikincil yüzey
  static const Color borderDark = Color(0xFF23302A);

  // ---- Light (ikincil tema) ----
  static const Color background = Color(0xFFF6FAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEDF4EF);
  static const Color border = Color(0xFFDCE7E0);

  // ---- Metin ----
  static const Color textPrimaryDark = Color(0xFFF2F7F4);
  static const Color textSecondaryDark = Color(0xFF8FA69B);
  static const Color textPrimary = Color(0xFF13201A);
  static const Color textSecondary = Color(0xFF5B6E64);
  static const Color textOnPrimary = Color(0xFF06130B); // neon butonun üstü koyu

  // ---- Semantic ----
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFACC15);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF38BDF8);

  // ---- Gradientler ----
  /// Logo/ilerleme halkası gradient'i: teal'den neon yeşile.
  static const List<Color> brandGradient = [secondaryDark, primary];
  static const List<Color> realityScoreGradient = brandGradient;
}
