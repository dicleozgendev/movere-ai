import 'package:video_player/video_player.dart';

/// Pre-warms the Onboarding "Focus" video during Splash's idle wait
/// (Splash already waits ~4s before navigating away — time that was
/// otherwise wasted). By the time Onboarding actually appears, the video
/// is already initializing (or done), instead of starting cold on
/// Onboarding's very first frame, which is what caused the noticeable
/// pause users could see the video page load.
///
/// Ownership: whoever reads [claim] takes full responsibility for
/// disposing the controller — this class only ever hands a controller
/// out once, then forgets about it, so there's no risk of double
/// management or a stale reference being reused after disposal.
class OnboardingVideoPreloader {
  OnboardingVideoPreloader._();

  static VideoPlayerController? _controller;
  static Future<void>? _initFuture;

  static void warm(String asset) {
    if (_controller != null) return; // already warming/warmed
    final controller = VideoPlayerController.asset(asset);
    _controller = controller;
    final future = controller.initialize();
    _initFuture = future;
    // Separate listener just to silence "unhandled Future rejection"
    // console noise if nobody ever claims this controller — the claimer
    // (below) attaches its own independent listener to the same future,
    // so a real failure still reaches it and its normal fallback UI.
    future.catchError((_) {});
  }

  /// Hands over the pre-warmed controller and its (possibly still
  /// pending) initialization future — the caller now owns the
  /// controller exclusively and should use this future instead of
  /// calling initialize() again (which video_player doesn't support).
  static (VideoPlayerController, Future<void>)? claim() {
    final c = _controller;
    final f = _initFuture;
    _controller = null;
    _initFuture = null;
    if (c == null || f == null) return null;
    return (c, f);
  }
}
