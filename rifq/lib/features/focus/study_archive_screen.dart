import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/voice_recorder.dart';
import '../../shared/widgets.dart';

/// أرشيف المذاكرة: كل جلساتك السابقة بما كتبته فيها —
/// ومنه «مراجعة أسئلتي»: استرجاع الأسئلة اللي توقعتها للامتحان.
class StudyArchiveScreen extends ConsumerStatefulWidget {
  const StudyArchiveScreen({super.key});

  @override
  ConsumerState<StudyArchiveScreen> createState() => _StudyArchiveScreenState();
}

class _StudyArchiveScreenState extends ConsumerState<StudyArchiveScreen> {
  List<FocusSession>? _sessions;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await ref.read(focusRepoProvider).recent(limit: 200);
    if (mounted) setState(() => _sessions = sessions);
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _sessions;
    if (sessions == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final withQuestions =
        sessions.where((s) => s.examQuestion.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('أرشيف مذاكرتك')),
      body: sessions.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'لسه مفيش جلسات محفوظة.\nأول جلسة «افتح بس» هتظهر هنا 🌿',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (withQuestions.isNotEmpty)
                  FilledButton.icon(
                    icon: const Icon(Icons.quiz_outlined),
                    label:
                        Text('راجع أسئلتك المتوقعة (${withQuestions.length})'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            _QuestionReviewScreen(sessions: withQuestions),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                for (final s in sessions) _SessionCard(session: s),
                const GentleFooter(
                    text: 'استرجاع المعلومة من ذاكرتك أقوى من إعادة القراءة.'),
              ],
            ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final FocusSession session;

  @override
  Widget build(BuildContext context) {
    final date = session.startedAt;
    final dateLabel =
        date == null ? '' : '${date.year}/${date.month}/${date.day}';
    return SectionCard(
      title: '${session.subject} — ${session.actualMinutes} دقيقة'
          '${dateLabel.isEmpty ? '' : ' ($dateLabel)'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session.tinyStep.isNotEmpty) Text('البداية: ${session.tinyStep}'),
          if (session.retrievalAnswer.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('اللي فهمته: ${session.retrievalAnswer}'),
          ],
          if (session.unclearPoint.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('لسه مش واضح: ${session.unclearPoint}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ],
          if (session.examQuestion.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('سؤال متوقع: ${session.examQuestion}'),
          ],
          if (session.notesImagePath != null &&
              File(session.notesImagePath!).existsSync())
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(session.notesImagePath!),
                    height: 120, fit: BoxFit.cover),
              ),
            ),
          if (session.voiceNotePath != null &&
              File(session.voiceNotePath!).existsSync())
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: VoicePlayback(path: session.voiceNotePath!),
            ),
        ],
      ),
    );
  }
}

/// مراجعة الأسئلة: يعرض سؤالك المتوقع، تحاول تجاوب من ذاكرتك،
/// وبعدين تكشف اللي كنت كاتبه وقت الجلسة. استرجاع بسيط بلا درجات.
class _QuestionReviewScreen extends StatefulWidget {
  const _QuestionReviewScreen({required this.sessions});

  final List<FocusSession> sessions;

  @override
  State<_QuestionReviewScreen> createState() => _QuestionReviewScreenState();
}

class _QuestionReviewScreenState extends State<_QuestionReviewScreen> {
  int _index = 0;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.sessions[_index];
    final isLast = _index == widget.sessions.length - 1;
    return Scaffold(
      appBar: AppBar(
          title: Text('مراجعة ${_index + 1} من ${widget.sessions.length}')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(session.subject, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          SectionCard(
            title: 'السؤال اللي توقعته',
            child: Text(session.examQuestion,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 8),
          Text('جاوب في دماغك الأول… من غير ما تفتح حاجة.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          if (!_revealed)
            FilledButton(
              onPressed: () => setState(() => _revealed = true),
              child: const Text('اكشف اللي كنت كاتبه'),
            )
          else ...[
            SectionCard(
              title: 'اللي كتبته وقتها',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.retrievalAnswer.isEmpty
                      ? '(ما كتبتش إجابة وقتها)'
                      : session.retrievalAnswer),
                  if (session.unclearPoint.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('وكانت النقطة الغامضة: ${session.unclearPoint}'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: isLast
                  ? () => Navigator.of(context).pop()
                  : () => setState(() {
                        _index++;
                        _revealed = false;
                      }),
              child: Text(isLast ? 'خلصت — رجوع 🌿' : 'السؤال الجاي'),
            ),
          ],
        ],
      ),
    );
  }
}
