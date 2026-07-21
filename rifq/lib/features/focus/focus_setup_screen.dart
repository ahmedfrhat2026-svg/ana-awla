import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models.dart';
import '../../shared/widgets.dart';

/// إعداد جلسة «افتح بس»: أصغر بداية لا تستطيع رفضها + خطة إذا–فسوف.
class FocusSetupScreen extends ConsumerStatefulWidget {
  const FocusSetupScreen({super.key});

  @override
  ConsumerState<FocusSetupScreen> createState() => _FocusSetupScreenState();
}

class _FocusSetupScreenState extends ConsumerState<FocusSetupScreen> {
  final _subject = TextEditingController();
  final _task = TextEditingController();
  final _tinyStep = TextEditingController();
  final _situation = TextEditingController();
  int _minutes = 10;
  int _energy = 3;

  static const _presets = [
    ('بداية ثقيلة', 10),
    ('تركيز هادئ', 25),
    ('عمل عميق', 45),
    ('مراجعة', 20),
  ];

  static const _tinyExamples = [
    'قراءة صفحتين',
    'مشاهدة 10 دقائق من المحاضرة',
    'حل سؤال واحد',
    'تلخيص عنوان واحد',
  ];

  @override
  void dispose() {
    _subject.dispose();
    _task.dispose();
    _tinyStep.dispose();
    _situation.dispose();
    super.dispose();
  }

  void _start() {
    if (_subject.text.trim().isEmpty || _tinyStep.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('اكتب اسم المادة وأصغر خطوة — ودي كفاية للبداية')));
      return;
    }
    final session = FocusSession(
      subject: _subject.text.trim(),
      task: _task.text.trim(),
      tinyStep: _tinyStep.text.trim(),
      plannedMinutes: _minutes,
      energyBefore: _energy,
      status: FocusStatus.running,
      startedAt: DateTime.now(),
    );
    context.push('/focus/timer', extra: session);
  }

  @override
  Widget build(BuildContext context) {
    final intention = _tinyStep.text.trim().isEmpty
        ? null
        : 'إذا ${_situation.text.trim().isEmpty ? 'جلست على المكتب' : _situation.text.trim()}، '
            'فسوف ${_tinyStep.text.trim()}.';
    return Scaffold(
      appBar: AppBar(title: const Text('جلسة «افتح بس»')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('ما أصغر بداية لا تستطيع رفضها؟',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          CalmTextField(controller: _subject, hint: 'المادة', maxLines: 1),
          const SizedBox(height: 12),
          CalmTextField(controller: _task, hint: 'المهمة (اختياري)', maxLines: 1),
          const SizedBox(height: 12),
          CalmTextField(
              controller: _tinyStep,
              hint: 'أصغر خطوة (مثال: ${_tinyExamples[DateTime.now().day % _tinyExamples.length]})',
              maxLines: 1),
          const SizedBox(height: 12),
          CalmTextField(
              controller: _situation,
              hint: 'إمتى أو فين؟ (مثال: الساعة 7 على المكتب)',
              maxLines: 1),
          const SizedBox(height: 16),
          SectionCard(
            title: 'مدة الجلسة',
            child: ChoiceChips(
              options: [for (final (l, m) in _presets) '$l — $m دقيقة'],
              selected: [
                for (final (l, m) in _presets)
                  if (m == _minutes) '$l — $m دقيقة'
              ].firstOrNull,
              onSelected: (v) => setState(() {
                _minutes = _presets.firstWhere((p) => v.contains(p.$1)).$2;
              }),
            ),
          ),
          SectionCard(
            title: 'طاقتك دلوقتي',
            child: Slider(
              value: _energy.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_energy',
              onChanged: (v) => setState(() => _energy = v.round()),
            ),
          ),
          if (intention != null)
            SectionCard(
              title: 'خطة إذا–فسوف',
              child: Text(intention,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _start, child: const Text('ابدأ — عشر دقايق وناخد القرار')),
          const GentleFooter(
              text: 'قرار الاستمرار بيتاخد بعد ما تبدأ، مش قبلها.'),
        ],
      ),
    );
  }
}
