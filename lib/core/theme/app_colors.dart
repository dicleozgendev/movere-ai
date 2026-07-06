import 'package:flutter/material.dart';

/// Movere AI Renk Paleti
/// Tema: Sakin / Wellbeing (yeşil-mavi tonları)
/// Amaç: Odaklanma, huzur ve denge hissi uyandırmak.
class AppColors {
  AppColors._();

  // ---- Primary (Teal/Green) ----
  static const Color primary = Color(0xFF2E7D6B); // Ana teal-yeşil
  static const Color primaryLight = Color(0xFF5AA893);
  static const Color primaryDark = Color(0xFF1B5544);

  // ---- Secondary (Soft Blue) ----
  static const Color secondary = Color(0xFF4A90A4); // Sakin mavi
  static const Color secondaryLight = Color(0xFF7FB8C9);
  static const Color secondaryDark = Color(0xFF2E6575);

  // ---- Accent ----
  static const Color accent = Color(0xFF8FD9C4); // Mint accent (Reality Score, CTA)

  // ---- Neutral / Background ----
  static const Color background = Color(0xFFF7FAF9); // Açık mod arkaplan
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFF5F3);

  // ---- Dark Mode ----
  static const Color backgroundDark = Color(0xFF0F1715);
  static const Color surfaceDark = Color(0xFF17211F);
  static const Color surfaceMutedDark = Color(0xFF1E2A27);

  // ---- Text ----
  static const Color textPrimary = Color(0xFF1A2523);
  static const Color textSecondary = Color(0xFF5C6B68);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFEAF2F0);
  static const Color textSecondaryDark = Color(0xFFA3B3B0);

  // ---- Semantic ----
  static const Color success = Color(0xFF4CAF7D);
  static const Color warning = Color(0xFFE8A63C);
  static const Color error = Color(0xFFD9614F);
  static const Color info = Color(0xFF4A90A4);

  // ---- Reality Score Gradient (Dashboard için) ----
  static const List<Color> realityScoreGradient = [
    Color(0xFF2E7D6B),
    Color(0xFF4A90A4),
  ];

  // ---- Borders / Dividers ----
  static const Color border = Color(0xFFDCE7E4);
  static const Color borderDark = Color(0xFF2A3835);
}
