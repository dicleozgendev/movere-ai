import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/movere_card.dart';
import '../../../core/widgets/movere_navigation.dart';
import '../application/podcast_providers.dart';
import '../domain/episode.dart';

/// Episode player. Plays the bundled recording for this lesson part with
/// just_audio: transport controls, a live progress bar and elapsed/
/// remaining labels are all driven by the real playback position.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.episode});

  final Episode episode;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  final _player = AudioPlayer();
  bool _markedListened = false;

  @override
  void initState() {
    super.initState();
    _player.setAsset(widget.episode.audioAsset);
    // Mark the episode "listened" once playback actually completes —
    // not just when the screen opens.
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed &&
          !_markedListened) {
        _markedListened = true;
        ref.read(listenedProvider.notifier).markListened(widget.episode.id);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _label(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    final e = widget.episode;

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

          // Live progress bar with elapsed / remaining labels.
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final total = _player.duration ?? const Duration(seconds: 1);
              final progress =
                  total.inMilliseconds == 0
                      ? 0.0
                      : position.inMilliseconds / total.inMilliseconds;
              final remaining = total - position;
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: primary.withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_label(position), style: textTheme.labelSmall),
                      Text(
                        '-${_label(remaining.isNegative ? Duration.zero : remaining)}',
                        style: textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              );
            },
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
                onPressed: () {
                  final pos = _player.position - const Duration(seconds: 15);
                  _player.seek(pos.isNegative ? Duration.zero : pos);
                },
              ),
              const SizedBox(width: AppConstants.spacingLg),
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return GestureDetector(
                    onTap: () => playing ? _player.pause() : _player.play(),
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        size: 40,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: AppConstants.spacingLg),
              IconButton(
                iconSize: 34,
                tooltip: 'Forward 15 seconds',
                icon: const Icon(Icons.forward_10),
                onPressed: () {
                  final total = _player.duration ?? Duration.zero;
                  final pos = _player.position + const Duration(seconds: 15);
                  _player.seek(pos > total ? total : pos);
                },
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
        ],
      ),
    );
  }
}
