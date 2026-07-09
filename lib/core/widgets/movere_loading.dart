import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Sayfa ortasında dönen yükleme göstergesi (opsiyonel mesajlı).
///
/// Kullanım: veriler gelene kadar `MovereLoading(message: 'Yükleniyor...')`
class MovereLoading extends StatelessWidget {
  const MovereLoading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppConstants.spacingMd),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// İçerik yüklenirken yerini tutan gri "iskelet" kutu.
///
/// Liste/kart yüklemelerinde gerçek içeriğin boyutunda gösterilir;
/// hafif bir soluklaşma animasyonuyla "yükleniyor" hissi verir.
class MovereSkeleton extends StatefulWidget {
  const MovereSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = AppConstants.radiusSm,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<MovereSkeleton> createState() => _MovereSkeletonState();
}

class _MovereSkeletonState extends State<MovereSkeleton>
    with SingleTickerProviderStateMixin {
  // repeat(reverse: true) => 0.4 ile 1.0 arasında sürekli gidip gelen opaklık.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.4,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose(); // animasyonu bırakmayı unutursak bellek sızar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;

    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
