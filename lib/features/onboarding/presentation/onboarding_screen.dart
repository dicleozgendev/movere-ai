import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/media/onboarding_video_preloader.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/movere_button.dart';
import '../../../l10n/app_localizations.dart';

/// The data model of a single onboarding page.
/// A page shows either a video or a static image; the brand-gradient icon
/// with a gentle pulse animation is kept as a fallback for any future
/// page that doesn't carry real media.
class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.description,
    this.videoAsset,
    this.imageAsset,
  });

  final String title;
  final String description;
  final String? videoAsset;
  final String? imageAsset;
}

/// A 3-page intro flow: swipeable PageView + dot indicator.
/// On the last page "Let's start" -> Login. "Skip" at the top right goes to Login anytime.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Built per-frame from the current locale (not a static const list
  // anymore) so the titles/descriptions actually translate — only the
  // asset paths are fixed, the text comes from AppLocalizations.
  List<_OnboardingPage> _pages(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return [
      _OnboardingPage(
        title: t.onboardingFocusTitle,
        description: t.onboardingFocusDescription,
        videoAsset: 'assets/onboarding/focus.mp4',
      ),
      _OnboardingPage(
        title: t.onboardingProgressTitle,
        description: t.onboardingProgressDescription,
        imageAsset: 'assets/onboarding/progress.jpg',
      ),
      _OnboardingPage(
        title: t.onboardingBreakFreeTitle,
        description: t.onboardingBreakFreeDescription,
        imageAsset: 'assets/onboarding/breakfree.jpg',
      ),
    ];
  }

  bool _isLast(BuildContext context) =>
      _currentPage == _pages(context).length - 1;

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _next() {
    if (_isLast(context)) {
      _goToLogin();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Computed once per build and reused below — this used to be called
    // 5+ times per frame (itemCount, itemBuilder, the dot indicator, and
    // twice more inside _isLast), rebuilding the whole 3-item list (and
    // re-reading AppLocalizations) each time for no reason.
    final pages = _pages(context);
    final isLast = _currentPage == pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top row: just "Skip"
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingSm),
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text(AppLocalizations.of(context)!.onboardingSkip),
                ),
              ),
            ),
            // Swipeable pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  final page = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXl,),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _OnboardingIllustration(page: page),
                        const SizedBox(height: AppConstants.spacingLg),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        Text(
                          page.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dot indicator: the active page is long and green.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: MovereButton(
                label: isLast
                    ? AppLocalizations.of(context)!.onboardingGetStarted
                    : AppLocalizations.of(context)!.onboardingContinue,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders whichever media a page carries: a looping muted video, a static
/// image, or (fallback) the original brand-gradient icon. Kept as its own
/// widget so the video controller's lifecycle (init in initState, dispose
/// in dispose) is fully self-contained and never leaks across pages.
class _OnboardingIllustration extends StatefulWidget {
  const _OnboardingIllustration({required this.page});

  final _OnboardingPage page;

  @override
  State<_OnboardingIllustration> createState() =>
      _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<_OnboardingIllustration> {
  VideoPlayerController? _videoController;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    final asset = widget.page.videoAsset;
    if (asset != null) {
      // Reuse the controller Splash already started loading, if it's
      // ready — falls back to a fresh (cold) load otherwise, so this is
      // always correct, just faster when the preload had time to run.
      final claimed = OnboardingVideoPreloader.claim();
      final VideoPlayerController controller;
      final Future<void> initFuture;
      if (claimed != null) {
        (controller, initFuture) = claimed;
      } else {
        controller = VideoPlayerController.asset(asset);
        initFuture = controller.initialize();
      }
      _videoController = controller;
      initFuture.then((_) {
        if (!mounted) return;
        controller
          ..setLooping(true)
          ..setVolume(0) // decorative background clip, no sound
          ..play();
        setState(() {});
      }).catchError((_) {
        // No native video platform available (e.g. widget tests) or the
        // clip failed to load — stop the spinner instead of animating
        // forever, and fall through to a static placeholder.
        if (mounted) setState(() => _videoFailed = true);
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 220.0;

    if (widget.page.videoAsset != null) {
      final controller = _videoController;
      if (controller == null || !controller.value.isInitialized) {
        // Placeholder while the video loads — black background, no grey
        // flash. If loading failed, skip the spinner (it would animate
        // forever) and just show the static box.
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          child: _videoFailed
              ? null
              : const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          width: size,
          height: size,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        ),
      );
    }

    if (widget.page.imageAsset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          width: size,
          height: size,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Image.asset(
            widget.page.imageAsset!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Fallback: the original gradient icon (Break Free), now with a
    // slow breathing pulse so every page feels alive, no asset required.
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
    );
  }
}
