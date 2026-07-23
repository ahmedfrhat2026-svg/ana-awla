import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/rifq_scaffold.dart';
import '../../design_system/components/rifq_surfaces.dart';
import '../../design_system/rifq_spacing.dart';
import '../../design_system/rifq_theme_extensions.dart';

/// أسئلة غرفة القرار — سؤال واحد لكل شاشة (progressive disclosure).
/// التطبيق لا يقرّر عنك؛ المخرَج تأمّل، لا حُكم.
const List<String> _questions = [
  'ما القرار الذي تفكر فيه؟',
  'لماذا تريده؟',
  'ماذا قد تخسر إذا فعلته؟',
  'ماذا قد تخسر إذا لم تفعله؟',
  'هل هذا اختيار أم محاولة للهروب؟',
  'هل يحتاج إلى قرار الآن؟',
  'ما أصغر خطوة قابلة للرجوع؟',
];

const List<String> _hints = [
  'اكتبه في جملة واحدة.',
  'الدافع الحقيقي، لا المبرّر.',
  'كن صادقًا مع نفسك.',
  'الفرصة التي قد تفوت.',
  'اختيار يقربك، أم هروب من شعور؟',
  'أم يمكن أن ينتظر حتى تهدأ؟',
  'خطوة تجرّبها دون أن تُغلق الباب.',
];

/// غرفة القرار — فحص هادئ للقرارات المهمة قبل اتخاذها.
class DecisionRoomScreen extends StatefulWidget {
  const DecisionRoomScreen({super.key});

  @override
  State<DecisionRoomScreen> createState() => _DecisionRoomScreenState();
}

class _DecisionRoomScreenState extends State<DecisionRoomScreen> {
  final _controllers =
      List.generate(_questions.length, (_) => TextEditingController());
  int _index = 0;
  bool _reviewing = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    if (_reviewing) {
      return _summary(context, palette);
    }

    final isLast = _index == _questions.length - 1;
    return RifqScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RifqPageHeader(
            title: 'غرفة القرار',
            subtitle: 'سؤال واحد في كل مرة. لا أحد يقرّر عنك.',
            onBack: () =>
                _index == 0 ? context.pop() : setState(() => _index--),
          ),
          Text('${_index + 1} من ${_questions.length}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: palette.textSecondary)),
          const SizedBox(height: RifqSpacing.sm),
          RifqOrganicSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_questions[_index],
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: RifqSpacing.xs),
                Text(_hints[_index],
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: palette.textSecondary)),
                const SizedBox(height: RifqSpacing.md),
                TextField(
                  controller: _controllers[_index],
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'اكتب بهدوء…'),
                ),
              ],
            ),
          ),
          const SizedBox(height: RifqSpacing.lg),
          FilledButton(
            onPressed: () => isLast
                ? setState(() => _reviewing = true)
                : setState(() => _index++),
            child: Text(isLast ? 'اعرض التأمّل' : 'التالي'),
          ),
        ],
      ),
    );
  }

  Widget _summary(BuildContext context, RifqPalette palette) {
    return RifqScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RifqPageHeader(
            title: 'تأمّل قرارك',
            subtitle: 'هذه مرآة لتفكيرك — القرار يبقى لك.',
            onBack: () => setState(() => _reviewing = false),
          ),
          for (var i = 0; i < _questions.length; i++)
            if (_controllers[i].text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: RifqSpacing.sm),
                child: RifqOrganicSurface(
                  padding: const EdgeInsets.all(RifqSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_questions[i],
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: palette.textSecondary)),
                      const SizedBox(height: 4),
                      Text(_controllers[i].text.trim(),
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: RifqSpacing.md),
          Text(
            'لا يوجد حُكم هنا. لو ما زلت غير متأكد، فالانتظار قرار أيضًا.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: RifqSpacing.lg),
          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('أغلق الغرفة'),
          ),
        ],
      ),
    );
  }
}
