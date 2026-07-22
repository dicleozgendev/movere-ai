import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A circular progress ring with the brand gradient.
///
/// The "72% Progress" indicator in the design. In Sprint 2 it will be used on the
/// focus card in the dashboard, and later in the Reality Score.
///
/// Usage: MovereProgressRing(progress: 0.72, label: 'Progress')
class MovereProgressRing extends StatelessWidget {
  const MovereProgressRing({
    super.key,
    required this.progress,
    this.size = 110,
    this.strokeWidth = 10,
    this.label,
  }) : assert(progress >= 0 && progress <= 1, 'progress must be in the range 0..1');

  /// progress between 0.0 and 1.0 (0.72 => 72%).
  final double progress;
  final double size;
  final double strokeWidth;

  /// A small caption under the percentage (e.g. "Progress").
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
          // The custom painter that draws the ring. Since the built-in CircularProgressIndicator
          // doesn't support gradients, we use CustomPaint.
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

    // 2) Progress arc: a gradient line starting at 12 o'clock (-90 degrees) and sweeping
    //       by the progress amount, with rounded caps.
    final sweep = 2 * math.pi * progress;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi,
        colors: AppColors.brandGradient,
        transform: GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
  }

  // don't repaint if progress hasn't changed (performance).
  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor;
}
