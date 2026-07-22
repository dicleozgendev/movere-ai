/// Movere AI - Uygulama Sabitleri
/// Route names, spacing/radius values and general constants.
class AppConstants {
  AppConstants._();

  // ---- Uygulama ----
  static const String appName = 'Movere AI';
  static const String appVersion = '0.1.0';

  // ---- Spacing (8pt grid) ----
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 28;
  static const double spacingXl = 32;

  // ---- Border Radius ----
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 24;
}

/// Route names — will be used in navigation from Sprint 3 onwards.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String usageDemo = '/usage-demo';
  static const String focus = '/focus';
  static const String progress = '/progress';
  static const String academy = '/academy';
  static const String podcast = '/podcast';
  static const String settings = '/settings';
}
