import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/movere_button.dart';
import '../../../core/widgets/movere_card.dart';
import '../../../core/widgets/movere_progress_ring.dart';
import '../application/focus_providers.dart';
import '../domain/focus_session.dart';

/// Focus Mode: süre seç → odaklan → özet.
/// Üç iç durum tek widget'ta: idle / running / summary.
/// WidgetsBindingObserver ile kullanıcı seans sırasında uygulamadan
/// çıkarsa yakalanıyor (yaşam döngüsü olayı, özel izin gerektirmez)
/// ve kesinti olarak kaydediliyor.
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

enum _Phase { idle, running, summary }

class _FocusOption {
  const _FocusOption(this.minutes, this.name, this.desc, this.icon);
  final int minutes;
  final String name;
  final String desc;
  final IconData icon;
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with WidgetsBindingObserver {
  static const _options = [
    _FocusOption(15, 'Quick', 'Short and sharp', Icons.bolt),
    _FocusOption(25, 'Classic', 'The proven rhythm', Icons.timer_outlined),
    _FocusOption(45, 'Deep', 'Real deep work', Icons.psychology),
    _FocusOption(90, 'Marathon', 'For the big things', Icons.terrain),
  ];

  _Phase _phase = _Phase.idle;
  int _selectedMinutes = 25;

  Timer? _ticker;
  DateTime? _startedAt;
  int _remainingSeconds = 0;
  int _interruptions = 0;
  FocusSession? _lastSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_phase != _Phase.running) return;
    if (state == AppLifecycleState.paused) {
      _interruptions++;
    } else if (state == AppLifecycleState.resumed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Focus interrupted — come back to the zone.'),
        ),
      );
      setState(() {});
    }
  }

  void _start() {
    setState(() {
      _phase = _Phase.running;
      _startedAt = DateTime.now();
      _remainingSeconds = _selectedMinutes * 60;
      _interruptions = 0;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _finish(completed: true);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _giveUp() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End this session?'),
        content: const Text('Your focus time so far will still be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End session'),
          ),
        ],
      ),
    );
    if (sure == true) _finish(completed: false);
  }

  void _finish({required bool completed}) {
    _ticker?.cancel();
    final elapsedSeconds = _selectedMinutes * 60 - _remainingSeconds;
    final session = FocusSession(
      startedAt: _startedAt ?? DateTime.now(),
      plannedMinutes: _selectedMinutes,
      elapsedMinutes: (elapsedSeconds / 60).floor(),
      completed: completed,
      interruptions: _interruptions,
    );
    ref.read(focusSessionsProvider.notifier).add(session);
    setState(() {
      _lastSession = session;
      _phase = _Phase.summary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _Phase.idle => _buildIdle(context),
      _Phase.running => _buildRunning(context),
      _Phase.summary => _buildSummary(context),
    };
  }

  // --- 1. Süre seçimi: isimli mod kartları ---
  Widget _buildIdle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: [
        Text('Deep Focus', style: textTheme.displayMedium),
        const SizedBox(height: 4),
        Text('Choose your mode. Silence the noise.',
            style: textTheme.bodyMedium,),
        const SizedBox(height: AppConstants.spacingLg),
        for (final o in _options) ...[
          MovereCard(
            onTap: () => setState(() => _selectedMinutes = o.minutes),
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withValues(
                        alpha: _selectedMinutes == o.minutes ? 0.2 : 0.08,),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(o.icon, color: primary, size: 22),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${o.name} · ${o.minutes} min',
                          style: textTheme.titleMedium,),
                      Text(o.desc, style: textTheme.labelSmall),
                    ],
                  ),
                ),
                Icon(
                  _selectedMinutes == o.minutes
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _selectedMinutes == o.minutes
                      ? primary
                      : textTheme.labelSmall?.color,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
        ],
        const SizedBox(height: AppConstants.spacingMd),
        MovereButton(
          label: 'Start Focus',
          onPressed: _start,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          'Leaving the app during a session counts as an interruption.',
          style: textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // --- 2. Seans sürüyor: ışımalı halka + evreye göre mesaj ---
  Widget _buildRunning(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    final total = _selectedMinutes * 60;
    final progress = _remainingSeconds / total;
    final mm = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (_remainingSeconds % 60).toString().padLeft(2, '0');

    final phrase = progress > 0.66
        ? 'Settle in. Let the world wait.'
        : progress > 0.33
            ? 'You are in the zone. Stay there.'
            : 'Final stretch — finish strong.';

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(phrase, style: textTheme.headlineMedium,
              textAlign: TextAlign.center,),
          const SizedBox(height: AppConstants.spacingXl),
          // Halkanın arkasında marka yeşili yumuşak bir ışıma:
          // koyu zeminde "nefes alan" bir odak alanı hissi veriyor.
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.25),
                  blurRadius: 60,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: MovereProgressRing(
              progress: progress,
              label: '$mm:$ss',
              size: 200,
              strokeWidth: 12,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Text(
            _interruptions == 0
                ? 'Clean run — no interruptions.'
                : 'Interruptions: $_interruptions',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppConstants.spacingXl),
          MovereButton(
            label: 'End Session',
            variant: MovereButtonVariant.text,
            onPressed: _giveUp,
          ),
        ],
      ),
    );
  }

  // --- 3. Özet: tamamlanma halkası + istatistikler ---
  Widget _buildSummary(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final s = _lastSession!;
    final completion =
        (s.elapsedMinutes / s.plannedMinutes).clamp(0.0, 1.0).toDouble();

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: [
        Text(
          s.completed ? 'Session complete' : 'Session ended',
          style: textTheme.displayMedium,
        ),
        const SizedBox(height: 4),
        Text(
          s.completed
              ? 'You stayed with it to the end. That is how focus is built.'
              : 'Every focused minute still counts. Come back stronger.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppConstants.spacingLg),
        MovereCard(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            children: [
              MovereProgressRing(
                progress: completion,
                label: 'done',
                size: 130,
              ),
              const SizedBox(height: AppConstants.spacingLg),
              _summaryRow(context, 'Focused', '${s.elapsedMinutes} min'),
              const Divider(height: AppConstants.spacingLg),
              _summaryRow(context, 'Planned', '${s.plannedMinutes} min'),
              const Divider(height: AppConstants.spacingLg),
              _summaryRow(context, 'Interruptions', '${s.interruptions}'),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        MovereButton(
          label: 'Start Another Session',
          onPressed: () => setState(() => _phase = _Phase.idle),
        ),
      ],
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
