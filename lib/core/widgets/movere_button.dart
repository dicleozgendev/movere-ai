import 'package:flutter/material.dart';

/// Button variants: primary (filled), secondary (outlined), text (flat).
enum MovereButtonVariant { primary, secondary, text }

/// Movere AI's standard button.
///
/// Usage:
///     MovereButton(label: 'Sign In', onPressed: () {})
///   MovereButton(label: 'Kaydet', isLoading: true, onPressed: () {})
///     MovereButton(label: 'Cancel', variant: MovereButtonVariant.text, onPressed: () {})
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

  /// if null is given, the button automatically looks disabled (dimmed).
  final VoidCallback? onPressed;
  final MovereButtonVariant variant;

  /// while true, a spinner appears instead of the label and the button becomes untappable.
  final bool isLoading;

  /// while true, the button spans the full row (for form screens).
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // During loading we disable onPressed so the user can't press again.
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    final Widget child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              // The primary button's background is also green; if the spinner is the same color
              // it becomes invisible. We use the color defined for "on top of" the background.
              color: variant == MovereButtonVariant.primary
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
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

    // Style info is NOT here: colors/corners come automatically from
    // definitions like elevatedButtonTheme in AppTheme.
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
