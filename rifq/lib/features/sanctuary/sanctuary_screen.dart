import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/rifq_shapes.dart';
import '../../design_system/rifq_spacing.dart';
import '../../design_system/rifq_theme_extensions.dart';
import 'emotion_paths.dart';

/// الملجأ — أقل تجربة احتكاكًا: بيئة معتمة، ضوء واحد، سؤال واحد.
/// «ماذا يحدث داخلك الآن؟» ثم استجابة مختلفة لكل حالة، وخروج سريع للحياة.
class SanctuaryScreen extends StatefulWidget {
  const SanctuaryScreen({super.key});

  @override
  State<SanctuaryScreen> createState() => _SanctuaryScreenState();
}

class _SanctuaryScreenState extends State<SanctuaryScreen> {
  Emotion? _selected;

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    // بيئة معتمة قليلًا وهادئة — نخفّض الكثافة البصرية.
    return Scaffold(
      backgroundColor: palette.deepSurface,
      body: SafeArea(
        child: Padding(
          padding: RifqSpacing.page,
          child: _selected == null
              ? _picker(context, palette)
              : _response(context, palette, _selected!),
        ),
      ),
    );
  }

  Widget _picker(BuildContext context, RifqPalette palette) {
    final onDark = palette.textPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.close, color: palette.textSecondary),
            tooltip: 'خروج',
            onPressed: () => context.pop(),
          ),
        ),
        const Spacer(),
        // ضوء واحد دافئ.
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                palette.gold.withValues(alpha: 0.5),
                palette.gold.withValues(alpha: 0.0),
              ]),
            ),
            child: Icon(Icons.wb_twilight, color: palette.gold, size: 34),
          ),
        ),
        const SizedBox(height: RifqSpacing.lg),
        Text(
          'ماذا يحدث داخلك الآن؟',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: onDark),
        ),
        const SizedBox(height: RifqSpacing.xl),
        // خيارات كبيرة قابلة للتمرير (لا شبكة مزدحمة).
        Expanded(
          child: ListView(
            children: [
              for (final e in Emotion.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: RifqSpacing.sm),
                  child: _EmotionButton(
                    label: e.label,
                    onTap: () => setState(() => _selected = e),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _response(BuildContext context, RifqPalette palette, Emotion e) {
    final r = responseFor(e);
    final onDark = palette.textPrimary;
    return ListView(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('شعور آخر'),
            style: TextButton.styleFrom(foregroundColor: palette.textSecondary),
            onPressed: () => setState(() => _selected = null),
          ),
        ),
        const SizedBox(height: RifqSpacing.sm),
        Text(e.label,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: onDark)),
        const SizedBox(height: RifqSpacing.xs),
        Text(r.opening,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: palette.textSecondary)),
        const SizedBox(height: RifqSpacing.lg),
        for (final action in r.actions)
          Padding(
            padding: const EdgeInsets.only(bottom: RifqSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: palette.sage),
                const SizedBox(width: RifqSpacing.sm),
                Expanded(
                  child: Text(action,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: onDark)),
                ),
              ],
            ),
          ),
        if (r.needsSupport) ...[
          const SizedBox(height: RifqSpacing.sm),
          Container(
            padding: const EdgeInsets.all(RifqSpacing.md),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.15),
              borderRadius: RifqRadii.medium,
            ),
            child: Text(
              'لو الحزن ثقيل واستمر، التواصل مع شخص تثق فيه أو مختص خطوة '
              'شجاعة — لست وحدك.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.textSecondary),
            ),
          ),
        ],
        const SizedBox(height: RifqSpacing.lg),
        if (r.suggestBreathing)
          FilledButton.icon(
            icon: const Icon(Icons.self_improvement),
            label: const Text('جلسة تنفّس هادئة'),
            onPressed: () => context.push('/reset'),
          ),
        if (r.suggestVoiceNote)
          Padding(
            padding: const EdgeInsets.only(top: RifqSpacing.sm),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.mic_none),
              label: const Text('فرّغ بصوتك في حصاد اليوم'),
              onPressed: () => context.push('/harvest'),
            ),
          ),
        const SizedBox(height: RifqSpacing.md),
        Center(
          child: TextButton(
            onPressed: () => context.go('/'),
            child: const Text('خطوة واحدة تكفي — أرجع للحياة'),
          ),
        ),
      ],
    );
  }
}

class _EmotionButton extends StatelessWidget {
  const _EmotionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    return Semantics(
      button: true,
      child: Material(
        color: palette.surface.withValues(alpha: 0.18),
        borderRadius: RifqRadii.medium,
        child: InkWell(
          borderRadius: RifqRadii.medium,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: RifqSpacing.md),
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: palette.textPrimary)),
          ),
        ),
      ),
    );
  }
}
