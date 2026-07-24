import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/movere_card.dart';
import '../../../core/widgets/movere_navigation.dart';
import '../application/podcast_providers.dart';
import '../domain/episode.dart';

/// Episode player.
/// The transport controls, progress bar and elapsed/remaining labels are
/// fully implemented; playback is currently driven by a timer (demo mode)
/// because the recordings are still in production. When the audio files
/// are ready only the position source changes — the UI stays the same.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.episode});

  final Episode episode;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  Timer? _ticker;
  int _position = 0; // seconds
  bool _playing = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_position >= widget.episode.seconds) {
          _finish();
        } else {
          setState(() => _position++);
        }
      });
    } else {
      _ticker?.cancel();
    }
  }

  void _finish() {
    _ticker?.cancel();
    ref.read(listenedProvider.notifier).markListened(widget.episode.id);
    setState(() {
      _playing = false;
      _position = widget.episode.seconds;
    });
  }

  void _seek(int deltaSeconds) {
    setState(() {
      _position = (_position + deltaSeconds).clamp(0, widget.episode.seconds);
    });
  }

  String _label(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    final e = widget.episode;
    final progress = e.seconds == 0 ? 0.0 : _position / e.seconds;

    return Scaffold(
      appBar: MovereAppBar(title: e.series),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        children: [
          // Cover placeholder — brand mark until real artwork is produced.
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                border: Border.all(color: primary.withValues(alpha: 0.35)),
              ),
              child: Icon(Icons.graphic_eq, size: 72, color: primary),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Text(e.title, style: textTheme.displayMedium),
          const SizedBox(height: 4),
          Text(e.host, style: textTheme.bodyMedium),
          const SizedBox(height: AppConstants.spacingLg),

          // Progress bar with elapsed / remaining labels.
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(value: progress, minHeight: 5),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_label(_position), style: textTheme.labelSmall),
              Text('-${_label(e.seconds - _position)}',
                  style: textTheme.labelSmall,),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Transport controls.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 34,
                tooltip: 'Back 15 seconds',
                icon: const Icon(Icons.replay_10),
                onPressed: () => _seek(-15),
              ),
              const SizedBox(width: AppConstants.spacingLg),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _playing ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingLg),
              IconButton(
                iconSize: 34,
                tooltip: 'Forward 15 seconds',
                icon: const Icon(Icons.forward_10),
                onPressed: () => _seek(15),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),

          MovereCard(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About this episode', style: textTheme.titleMedium),
                const SizedBox(height: AppConstants.spacingSm),
                Text(e.description, style: textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'Demo mode: playback is simulated until the episode audio is '
            'available. Controls, progress and completion tracking are live.',
            style: textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
