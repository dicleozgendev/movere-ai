import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Movere AI'ın standart kartı.
///
/// Dashboard istatistikleri, ders kartları, ayar grupları... hepsi bunu kullanacak.
/// Görünüm (renk, köşe, kenarlık) AppTheme'deki cardTheme'den gelir.
class MovereCard extends StatelessWidget {
  const MovereCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppConstants.spacingMd),
  });

  final Widget child;

  /// Verilirse kart tıklanabilir olur ve dokunma efekti (ripple) kazanır.
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return Card(
      // margin'i sıfırlıyoruz: boşluk kararını kartın kendisi değil,
      // onu yerleştiren ekran versin (daha esnek).
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias, // ripple efekti köşelerden taşmasın
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
