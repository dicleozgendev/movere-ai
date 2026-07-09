import 'package:flutter/material.dart';

/// Buton çeşitleri: primary (dolu), secondary (çerçeveli), text (düz).
enum MovereButtonVariant { primary, secondary, text }

/// Movere AI'ın standart butonu.
///
/// Kullanım:
///   MovereButton(label: 'Giriş Yap', onPressed: () {})
///   MovereButton(label: 'Kaydet', isLoading: true, onPressed: () {})
///   MovereButton(label: 'Vazgeç', variant: MovereButtonVariant.text, onPressed: () {})
class MovereButton extends StatelessWidget {
  const MovereButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MovereButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
  });

  final String label;

  /// null verilirse buton otomatik olarak devre dışı (soluk) görünür.
  final VoidCallback? onPressed;
  final MovereButtonVariant variant;

  /// true iken yazı yerine dönen bir gösterge çıkar ve buton tıklanamaz olur.
  final bool isLoading;

  /// true iken buton satırın tamamını kaplar (form ekranları için).
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // Loading sırasında kullanıcı tekrar basamasın diye onPressed'i kapatıyoruz.
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    final Widget child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : (icon == null
            ? Text(label)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ));

    // Stil bilgisi burada YOK: renkler/köşeler AppTheme'deki
    // elevatedButtonTheme vb. tanımlardan otomatik geliyor.
    final Widget button = switch (variant) {
      MovereButtonVariant.primary =>
        ElevatedButton(onPressed: effectiveOnPressed, child: child),
      MovereButtonVariant.secondary =>
        OutlinedButton(onPressed: effectiveOnPressed, child: child),
      MovereButtonVariant.text =>
        TextButton(onPressed: effectiveOnPressed, child: child),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
