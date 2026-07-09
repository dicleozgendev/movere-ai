import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Marka gradient'li dairesel ilerleme halkası.
///
/// Tasarımdaki "%72 İlerleme" göstergesi. Sprint 2'de dashboard'daki
/// odak kartında, ileride Reality Score'da kullanılacak.
///
/// Kullanım: MovereProgressRing(progress: 0.72, label: 'İlerleme')
class MovereProgressRing extends StatelessWidget {
  const MovereProgressRing({
    super.key,
    required this.progress,
    this.size = 110,
    this.strokeWidth = 10,
    this.label,
  }) : assert(progress >= 0 && progress <= 1, 'progress 0..1 aralığında olmalı');

  /// 0.0 – 1.0 arası ilerleme (0.72 => %72).
  final double progress;
  final double size;
  final double strokeWidth;

  /// Yüzdenin altındaki küçük açıklama (örn. "İlerleme").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halkayı çizen özel ressam. Hazır CircularProgressIndicator
          // gradient desteklemediği için CustomPaint kullanıyoruz.
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              trackColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '%${(progress * 100).round()}',
                style: textTheme.headlineMedium,
              ),
              if (label != null)
                Text(label!, style: textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1) Arka plan izi: soluk tam daire.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    // 2) İlerleme yayı: saat 12'den (-90°) başlayıp progress kadar dönen,
    //    uçları yuvarlatılmış gradient çizgi.
    final sweep = 2 * math.pi * progress;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi,
        colors: AppColors.brandGradient,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
  }

  // progress değişmediyse yeniden çizme (performans).
  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor;
}
