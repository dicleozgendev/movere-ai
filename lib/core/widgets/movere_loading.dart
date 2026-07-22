import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// A spinning loading indicator in the center of the page (with an optional message).
///
/// Usage: until the data arrives, `MovereLoading(message: 'Loading...')`
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

/// A gray "skeleton" box that holds the place while content loads.
///
/// Shown at the size of the real content during list/card loading;
/// a subtle fade animation gives a "loading" feel.
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
  // repeat(reverse: true) => opacity continuously oscillating between 0.4 and 1.0.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.4,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose(); // if we forget to release the animation, memory leaks
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
