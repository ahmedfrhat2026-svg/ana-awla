import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// اختبار الاسترجاع بعد الجلسة — استرجاع المعلومة من الذاكرة بدل إعادة القراءة.
class RetrievalReviewScreen extends ConsumerStatefulWidget {
  const RetrievalReviewScreen({super.key, required this.session});

  final FocusSession session;

  @override
  ConsumerState<RetrievalReviewScreen> createState() =>
      _RetrievalReviewScreenState();
}

class _RetrievalReviewScreenState extends ConsumerState<RetrievalReviewScreen> {
  final _remember = TextEditingController();
  final _unclear = TextEditingController();
  final _examQuestion = TextEditingController();
  final _nextStep = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _remember.dispose();
    _unclear.dispose();
    _examQuestion.dispose();
    _nextStep.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.session.copyWith(
      retrievalAnswer: _remember.text.trim(),
      unclearPoint: _unclear.text.trim(),
      examQuestion: _examQuestion.text.trim(),
      nextStep: _nextStep.text.trim(),
    );
    await ref.read(focusRepoProvider).add(updated);
    ref.invalidate(recentFocusProvider);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.session.actualMinutes;
    return Scaffold(
      appBar: AppBar(title: const Text('قبل ما تقفل الدفتر')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionCard(
            child: Text(
              'قعدت $minutes دقيقة مع ${widget.session.subject} — البداية نفسها إنجاز.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text('ثلاث أسئلة استرجاع — من ذاكرتك، من غير ما تفتح المصدر:',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          CalmTextField(
              controller: _remember, hint: '1) إيه اللي فهمته وفاكره دلوقتي؟'),
          const SizedBox(height: 12),
          CalmTextField(
              controller: _unclear, hint: '2) إيه النقطة اللي لسه مش واضحة؟'),
          const SizedBox(height: 12),
          CalmTextField(
              controller: _examQuestion,
              hint: '3) اكتب سؤال ممكن ييجي في الامتحان'),
          const SizedBox(height: 12),
          CalmTextField(
              controller: _nextStep,
              hint: 'الخطوة الجاية (اختياري)',
              maxLines: 1),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('احفظ الجلسة'),
          ),
          TextButton(
            onPressed: _saving
                ? null
                : () async {
                    // حفظ الجلسة حتى بدون إجابات — بلا لوم.
                    setState(() => _saving = true);
                    await ref.read(focusRepoProvider).add(widget.session);
                    ref.invalidate(recentFocusProvider);
                    if (context.mounted) context.go('/');
                  },
            child: const Text('مش دلوقتي — احفظ الجلسة بس'),
          ),
        ],
      ),
    );
  }
}
