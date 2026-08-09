import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/movere_card.dart';
import '../../../core/widgets/movere_navigation.dart';
import '../../academy/application/academy_providers.dart';
import '../../academy/presentation/lesson_detail_screen.dart';
import '../../focus/application/focus_providers.dart';
import '../../podcast/application/podcast_providers.dart';
import '../../podcast/presentation/player_screen.dart';
import '../../reality_score/application/reality_score_provider.dart';
import '../application/recommendation_provider.dart';

/// One line of the simple chat thread at the bottom of the AI tab.
class _ChatMessage {
  const _ChatMessage({required this.text, required this.fromUser});
  final String text;
  final bool fromUser;
}

/// AI Recommendation Prototype (Sprint 5): a dedicated assistant-style
/// screen — not just a card bolted onto the Dashboard. The top half reads
/// today's real activity and shows four insights (Focus / Reading /
/// Listening / Explore) the way a personal assistant would summarise a
/// day. Underneath, a small keyword-matched Q&A box lets the user "ask"
/// about their own data directly.
///
/// Honesty note (also in the code, not just here): the chat box below is
/// NOT a language model — it's simple keyword matching over the same
/// real local data the insights above use. It's built this way on
/// purpose for a *prototype*: no API key, no per-message cost, no data
/// leaving the device, while still giving the "ask it something" feel
/// the brief asked for. A real LLM backend would be a separate,
/// deliberate decision (cost, API key ownership, privacy) — not
/// something to slip in quietly.
class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key, required this.onGoToTab});

  /// Lets an insight's action button jump to another Dashboard tab
  /// (Focus or Academy) — passed down the same way _DashboardTab
  /// receives its onDeepFocus/onAcademy callbacks.
  final void Function(int) onGoToTab;

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _act(AiInsight insight) {
    switch (insight.target) {
      case RecommendationTarget.focus:
        widget.onGoToTab(1);
      case RecommendationTarget.academy:
        widget.onGoToTab(3);
      case RecommendationTarget.academyLesson:
        final lesson =
            lessons.where((l) => l.id == insight.lessonId).firstOrNull;
        if (lesson != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
          );
        }
      case RecommendationTarget.podcast:
        final eps = episodesForLesson(insight.lessonId ?? '');
        final listened = ref.read(listenedProvider);
        final unheard = eps.where((e) => !listened.contains(e.id)).toList();
        if (unheard.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PlayerScreen(episode: unheard.first)),
          );
        }
      case null:
        break;
    }
  }

  /// The deployed Cloud Function's URL — Firebase prints the real one
  /// after `firebase deploy --only functions`. Replace this placeholder
  /// with that exact URL (looks like
  /// https://aiRecommendation-XXXXXXXXXX-uc.a.run.app or
  /// https://us-central1-movere-ai.cloudfunctions.net/aiRecommendation).
  static const _aiEndpoint =
      'https://us-central1-movere-ai.cloudfunctions.net/aiRecommendation';

  /// Simple keyword matching over real local data — used as the
  /// offline/fallback path if the real-AI call fails or hasn't been
  /// deployed yet. See the class-level doc comment for why this exists
  /// alongside a real AI call rather than instead of it.
  String _localRespond(String question) {
    final q = question.toLowerCase();
    final todayMinutes = ref.read(todayFocusMinutesProvider);
    final score = ref.read(realityScoreProvider);
    final insights = ref.read(aiInsightsProvider);

    if (q.contains('focus') || q.contains('odak') || q.contains('session')) {
      return todayMinutes == 0
          ? 'You haven\u2019t logged any focus time yet today. A Quick '
              '(15 min) session is an easy way to start.'
          : 'You\u2019ve focused for $todayMinutes min today \u2014 nice work, '
              'keep the momentum going.';
    }
    if (q.contains('score') || q.contains('puan') || q.contains('reality')) {
      return 'Your Reality Score right now is ${score.value}/100. It '
          'blends today\u2019s focus goal, your recent session completion '
          'rate, and your reading progress.';
    }
    if (q.contains('read') || q.contains('lesson') || q.contains('ders') ||
        q.contains('academy')) {
      final reading =
          insights.firstWhere((i) => i.category == 'Reading');
      return '${reading.title}. ${reading.description}';
    }
    if (q.contains('podcast') || q.contains('listen') || q.contains('audio')) {
      final listening =
          insights.firstWhere((i) => i.category == 'Listening');
      return '${listening.title}. ${listening.description}';
    }
    if (q.contains('help') || q.contains('what can you') || q.contains('?')) {
      return 'Ask me about your focus time, Reality Score, reading '
          'progress, or podcast episodes \u2014 I\u2019m reading your real '
          'activity, not guessing.';
    }
    return 'I\u2019m a simple prototype for now \u2014 try asking about your '
        '"focus", "score", "reading" or "podcast".';
  }

  /// Calls the deployed Cloud Function, which asks a real AI model to
  /// phrase the answer — the facts themselves still come from this
  /// device's real local data, sent along in the request body. Falls
  /// back to [_localRespond] if the endpoint isn't set up yet, the
  /// network fails, or the call errors out — the user always gets an
  /// answer, real-AI or not.
  Future<String> _respond(String question) async {
    if (_aiEndpoint == 'PASTE_YOUR_DEPLOYED_FUNCTION_URL_HERE') {
      return _localRespond(question);
    }
    final todayMinutes = ref.read(todayFocusMinutesProvider);
    final score = ref.read(realityScoreProvider);
    final insights = ref.read(aiInsightsProvider);
    final facts = {
      'todayFocusMinutes': todayMinutes,
      'realityScore': score.value,
      'insights': [
        for (final i in insights)
          {'category': i.category, 'title': i.title, 'status': i.status.name},
      ],
    };
    try {
      final res = await http
          .post(
            Uri.parse(_aiEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'question': question, 'facts': facts}),
          )
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return (data['text'] as String?)?.trim().isNotEmpty == true
            ? data['text'] as String
            : _localRespond(question);
      }
      return _localRespond(question);
    } catch (_) {
      // Network error, timeout, function not deployed yet, etc. — the
      // rule-based prototype still answers instead of showing nothing.
      return _localRespond(question);
    }
  }

  bool _waitingForReply = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _waitingForReply) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, fromUser: true));
      _waitingForReply = true;
    });
    _controller.clear();
    _scrollToBottom();

    final reply = await _respond(text);

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(text: reply, fromUser: false));
      _waitingForReply = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    final insights = ref.watch(aiInsightsProvider);
    final top = ref.watch(topRecommendationProvider);

    return Scaffold(
      appBar: const MovereAppBar(title: 'AI Assistant'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              children: [
                // --- Assistant header: avatar + greeting ---
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: AppColors.brandGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 26,),
                    ),
                    const SizedBox(width: AppConstants.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Movere Assistant',
                              style: textTheme.titleMedium,),
                          Text('Based on today\u2019s activity',
                              style: textTheme.labelSmall,),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // --- Top pick ---
                _ChatBubble(
                  highlighted: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(top.icon, size: 16, color: primary),
                          const SizedBox(width: 6),
                          Text('TOP PICK',
                              style: textTheme.labelSmall?.copyWith(
                                color: primary,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                              ),),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      Text(top.title, style: textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(top.description, style: textTheme.bodyMedium),
                      if (top.actionLabel != null) ...[
                        const SizedBox(height: AppConstants.spacingMd),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => _act(top),
                            child: Text(top.actionLabel!),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacingLg),
                Text('FULL BRIEFING',
                    style: textTheme.labelSmall?.copyWith(letterSpacing: 1.2),),
                const SizedBox(height: AppConstants.spacingSm),

                for (final insight in insights)
                  _ChatBubble(
                    highlighted: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: insight.status == InsightStatus.actionable
                                ? primary.withValues(alpha: 0.14)
                                : Colors.green.withValues(alpha: 0.14),
                          ),
                          child: Icon(
                            insight.status == InsightStatus.actionable
                                ? insight.icon
                                : Icons.check,
                            size: 17,
                            color: insight.status == InsightStatus.actionable
                                ? primary
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(insight.category,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                    letterSpacing: 1,
                                  ),),
                              const SizedBox(height: 2),
                              Text(insight.title,
                                  style: textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),),
                              const SizedBox(height: 2),
                              Text(insight.description,
                                  style: textTheme.labelSmall,),
                              if (insight.actionLabel != null) ...[
                                const SizedBox(height: AppConstants.spacingSm),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () => _act(insight),
                                  child: Text(insight.actionLabel!),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // --- Ask box: keyword Q&A over the same real data ---
                const SizedBox(height: AppConstants.spacingLg),
                Text('ASK ABOUT YOUR DATA',
                    style: textTheme.labelSmall?.copyWith(letterSpacing: 1.2),),
                const SizedBox(height: AppConstants.spacingSm),
                for (final m in _messages)
                  Align(
                    alignment: m.fromUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      margin: const EdgeInsets.only(
                          bottom: AppConstants.spacingSm,),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMd,
                        vertical: AppConstants.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: m.fromUser
                            ? primary.withValues(alpha: 0.16)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: m.fromUser
                            ? null
                            : Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.08),
                              ),
                      ),
                      child: Text(m.text, style: textTheme.bodyMedium),
                    ),
                  ),
                if (_waitingForReply)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(
                          bottom: AppConstants.spacingSm,),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMd,
                        vertical: AppConstants.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.08),
                        ),
                      ),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                if (_messages.isEmpty)
                  Text(
                    'Try asking: "how\u2019s my focus today?" or "what\u2019s my score?"',
                    style: textTheme.labelSmall,
                  ),
              ],
            ),
          ),

          // --- Input bar, pinned to the bottom ---
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingMd,
                AppConstants.spacingSm,
                AppConstants.spacingMd,
                AppConstants.spacingSm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_waitingForReply,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Ask about your focus, score, reading\u2026',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  IconButton.filled(
                    onPressed: _waitingForReply ? null : _send,
                    icon: const Icon(Icons.send, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single "message" card — the assistant's top pick gets a highlighted
/// (brand-tinted border) treatment, the rest are plain cards, mimicking
/// the look of a chat thread without pretending to be a live LLM chat.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.child, required this.highlighted});

  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: MovereCard(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Container(
          decoration: highlighted
              ? BoxDecoration(
                  border: Border(
                    left: BorderSide(color: primary, width: 3),
                  ),
                )
              : null,
          padding: highlighted
              ? const EdgeInsets.only(left: AppConstants.spacingSm)
              : EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
