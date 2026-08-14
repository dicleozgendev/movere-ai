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
import '../../../l10n/app_localizations.dart';
import '../application/recommendation_provider.dart';

/// Turns an [AiInsight]'s category/state into the localized text to
/// show — kept as a free function (not on the data class) because it
/// needs a BuildContext for AppLocalizations, which the data class
/// deliberately doesn't carry.
({String category, String title, String description, String? actionLabel})
    insightText(AppLocalizations t, AiInsight i) {
  switch (i.kind) {
    case InsightKind.focusNone:
      return (
        category: t.aiCategoryFocus,
        title: t.aiFocusNoneTitle,
        description: t.aiFocusNoneDesc,
        actionLabel: t.aiFocusNoneAction,
      );
    case InsightKind.focusActive:
      return (
        category: t.aiCategoryFocus,
        title: t.aiFocusActiveTitle(i.todayMinutes ?? 0),
        description: t.aiFocusActiveDesc,
        actionLabel: null,
      );
    case InsightKind.readingActionable:
      return (
        category: t.aiCategoryReading,
        title: t.aiReadingActionableTitle(
            i.lessonTitle ?? '', i.progressPercent ?? 0,),
        description: t.aiReadingActionableDesc,
        actionLabel: t.aiReadingActionableAction,
      );
    case InsightKind.readingPositive:
      return (
        category: t.aiCategoryReading,
        title: t.aiReadingPositiveTitle,
        description: t.aiReadingPositiveDesc,
        actionLabel: null,
      );
    case InsightKind.listeningActionable:
      return (
        category: t.aiCategoryListening,
        title: t.aiListeningActionableTitle,
        description: t.aiListeningActionableDesc,
        actionLabel: t.aiListeningActionableAction,
      );
    case InsightKind.listeningPositive:
      return (
        category: t.aiCategoryListening,
        title: t.aiListeningPositiveTitle,
        description: t.aiListeningPositiveDesc,
        actionLabel: null,
      );
    case InsightKind.exploreActionable:
      return (
        category: t.aiCategoryExplore,
        title: t.aiExploreActionableTitle(i.lessonTitle ?? ''),
        description: t.aiExploreActionableDesc,
        actionLabel: t.aiExploreActionableAction,
      );
    case InsightKind.explorePositive:
      return (
        category: t.aiCategoryExplore,
        title: t.aiExplorePositiveTitle,
        description: t.aiExplorePositiveDesc,
        actionLabel: null,
      );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.fromUser});
  final String text;
  final bool fromUser;
}

/// AI Recommendation Prototype (Sprint 5): a dedicated assistant-style
/// screen. The top half reads today's real activity and shows four
/// insights (Focus / Reading / Listening / Explore). Underneath, a
/// keyword/AI-backed Q&A box lets the user ask about their own data.
///
/// Honesty note: the fallback chat responder is plain keyword matching
/// over real local data, not a language model — the real-AI path (a
/// deployed Cloud Function) is used when reachable, with this as a
/// safety net, not a language model imitation.
class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key, required this.onGoToTab});

  final void Function(int) onGoToTab;

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _waitingForReply = false;

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

  static const _aiEndpoint =
      'https://us-central1-movere-ai.cloudfunctions.net/aiRecommendation';

  /// Simple keyword matching over real local data — used if the real-AI
  /// call fails or hasn't been deployed. Reuses the same localized
  /// insight text as the briefing above, so the fallback speaks the
  /// same language the rest of the screen does.
  String _localRespond(String question) {
    final t = AppLocalizations.of(context)!;
    final q = question.toLowerCase();
    final score = ref.read(realityScoreProvider);
    final insights = ref.read(aiInsightsProvider);

    if (q.contains('focus') || q.contains('odak') || q.contains('session')) {
      final f = insights.firstWhere((i) => i.kind == InsightKind.focusNone ||
          i.kind == InsightKind.focusActive,);
      final txt = insightText(t, f);
      return '${txt.title}. ${txt.description}';
    }
    if (q.contains('score') || q.contains('puan') || q.contains('reality')) {
      return 'Reality Score: ${score.value}/100.';
    }
    if (q.contains('read') || q.contains('ders') || q.contains('academy') ||
        q.contains('lesson')) {
      final r = insights.firstWhere((i) => i.kind == InsightKind.readingActionable ||
          i.kind == InsightKind.readingPositive,);
      final txt = insightText(t, r);
      return '${txt.title}. ${txt.description}';
    }
    if (q.contains('podcast') || q.contains('listen') || q.contains('audio')) {
      final l = insights.firstWhere((i) => i.kind == InsightKind.listeningActionable ||
          i.kind == InsightKind.listeningPositive,);
      final txt = insightText(t, l);
      return '${txt.title}. ${txt.description}';
    }
    return t.aiAskPlaceholder;
  }

  Future<String> _respond(String question) async {
    final locale = Localizations.localeOf(context).languageCode;
    final todayMinutes = ref.read(todayFocusMinutesProvider);
    final score = ref.read(realityScoreProvider);
    final insights = ref.read(aiInsightsProvider);
    final facts = {
      'todayFocusMinutes': todayMinutes,
      'realityScore': score.value,
      // Deliberately NOT localized: kind/status are plain English enum
      // keys, not translated text. If these carried the app's current
      // display language (e.g. Turkish category names), that language
      // could bias the model's reply even when the user's own question
      // was asked in a different language — keeping facts neutral means
      // the question text is the only language signal in the prompt.
      'insights': [
        for (final i in insights)
          {
            'kind': i.kind.name,
            'status': i.status.name,
            if (i.todayMinutes != null) 'todayFocusMinutes2': i.todayMinutes,
            if (i.lessonTitle != null) 'lessonTitle': i.lessonTitle,
            if (i.progressPercent != null) 'progressPercent': i.progressPercent,
          },
      ],
    };
    try {
      final res = await http
          .post(
            Uri.parse(_aiEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(
                {'question': question, 'facts': facts, 'language': locale},),
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
      return _localRespond(question);
    }
  }

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
    final t = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    final insights = ref.watch(aiInsightsProvider);
    final top = ref.watch(topRecommendationProvider);
    final topText = insightText(t, top);

    return Scaffold(
      appBar: MovereAppBar(title: t.aiAssistantLabel),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              children: [
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
                          Text(t.aiGreetingTitle, style: textTheme.titleMedium),
                          Text(t.aiGreetingSubtitle, style: textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLg),

                _ChatBubble(
                  highlighted: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(top.icon, size: 16, color: primary),
                          const SizedBox(width: 6),
                          Text(t.aiTopPick,
                              style: textTheme.labelSmall?.copyWith(
                                color: primary,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                              ),),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      Text(topText.title, style: textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(topText.description, style: textTheme.bodyMedium),
                      if (topText.actionLabel != null) ...[
                        const SizedBox(height: AppConstants.spacingMd),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => _act(top),
                            child: Text(topText.actionLabel!),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacingLg),
                Text(t.aiFullBriefing,
                    style: textTheme.labelSmall?.copyWith(letterSpacing: 1.2),),
                const SizedBox(height: AppConstants.spacingSm),

                for (final insight in insights)
                  Builder(builder: (context) {
                    final txt = insightText(t, insight);
                    return _ChatBubble(
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
                                Text(txt.category,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                      letterSpacing: 1,
                                    ),),
                                const SizedBox(height: 2),
                                Text(txt.title,
                                    style: textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),),
                                const SizedBox(height: 2),
                                Text(txt.description, style: textTheme.labelSmall),
                                if (txt.actionLabel != null) ...[
                                  const SizedBox(height: AppConstants.spacingSm),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () => _act(insight),
                                    child: Text(txt.actionLabel!),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },),

                const SizedBox(height: AppConstants.spacingLg),
                Text(t.aiAskSectionTitle,
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
                if (_messages.isEmpty) Text(t.aiAskPlaceholder, style: textTheme.labelSmall),
              ],
            ),
          ),
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
                      decoration: InputDecoration(
                        hintText: t.aiAskHint,
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
