import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Movere AI's standard card.
///
/// Dashboard stats, lesson cards, settings groups... all of them will use this.
/// Appearance (color, corners, border) comes from cardTheme in AppTheme.
class MovereCard extends StatelessWidget {
  const MovereCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppConstants.spacingMd),
  });

  final Widget child;

  /// If provided, the card becomes tappable and gains a touch (ripple) effect.
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return Card(
      // we zero out the margin: the spacing decision is made not by the card itself
      // but by the screen that places it (more flexible).
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias, // so the ripple effect doesn't overflow the corners
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
