import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../design_system/rifq_reduced_motion.dart';
import '../../design_system/rifq_spacing.dart';
import '../../design_system/rifq_theme_extensions.dart';

/// وضع الخلوة — يبسّط الشاشة تقريبًا بالكامل: «اترك الهاتف هنا، واذهب لتعيش».
/// بلا عدّاد مخيف، خروج خفي، ويحترم دورة حياة أندرويد. عند الانتهاء يسأل
/// «ماذا حدث خارج الهاتف؟» لا «هل أنجزت؟».
class RetreatScreen extends ConsumerStatefulWidget {
  const RetreatScreen({super.key});

  @override
  ConsumerState<RetreatScreen> createState() => _RetreatScreenState();
}

enum _Phase { choose, resting, ended }

class _RetreatScreenState extends ConsumerState<RetreatScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  _Phase _phase = _Phase.choose;
  int _minutes = 30;
  DateTime? _endsAt;
  Timer? _timer;
  final _note = TextEditingController();
  late final AnimationController _breath;

  static const _durations = [30, 60, 120, 240]; // دقائق

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _breath.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // إيقاف الحركة عند الخلفية؛ الوقت محسوب بالساعة لا بالمؤقّت فيبقى دقيقًا.
    if (state == AppLifecycleState.resumed) {
      if (_phase == _Phase.resting &&
          mounted &&
          RifqReducedMotion.ambientEnabled(context)) {
        _breath.repeat(reverse: true);
      }
    } else {
      _breath.stop();
    }
  }

  void _start() {
    _endsAt = DateTime.now().add(Duration(minutes: _minutes));
    _phase = _Phase.resting;
    if (RifqReducedMotion.ambientEnabled(context)) {
      _breath.repeat(reverse: true);
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (DateTime.now().isAfter(_endsAt!)) {
        _timer?.cancel();
        _breath.stop();
        if (mounted) setState(() => _phase = _Phase.ended);
      } else if (mounted) {
        setState(() {});
      }
    });
    setState(() {});
  }

  Future<void> _saveAndLeave() async {
    final text = _note.text.trim();
    if (text.isNotEmpty) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await ref
          .read(reflectionRepoProvider)
          .add(Reflection(date: today, learned: text));
    }
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    return Scaffold(
      backgroundColor: palette.deepSurface,
      body: SafeArea(
        child: Padding(
          padding: RifqSpacing.page,
          child: switch (_phase) {
            _Phase.choose => _chooseView(context, palette),
            _Phase.resting => _restingView(context, palette),
            _Phase.ended => _endedView(context, palette),
          },
        ),
      ),
    );
  }

  Widget _chooseView(BuildContext context, RifqPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.close, color: palette.textSecondary),
            onPressed: () => context.pop(),
          ),
        ),
        const Spacer(),
        Text('وضع الخلوة',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: palette.textPrimary)),
        const SizedBox(height: RifqSpacing.xs),
        Text('اترك الهاتف هنا، واذهب لتعيش قليلًا.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: palette.textSecondary)),
        const SizedBox(height: RifqSpacing.xl),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: RifqSpacing.sm,
          children: [
            for (final m in _durations)
              ChoiceChip(
                label: Text(_durationLabel(m)),
                selected: _minutes == m,
                onSelected: (_) => setState(() => _minutes = m),
              ),
          ],
        ),
        const SizedBox(height: RifqSpacing.xl),
        FilledButton(
          onPressed: _start,
          child: Text('ابدأ الخلوة (${_durationLabel(_minutes)})'),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _restingView(BuildContext context, RifqPalette palette) {
    final remaining = _endsAt!.difference(DateTime.now());
    return Column(
      children: [
        const Spacer(),
        // مشهد شبه ساكن — نبضة ضوء بطيئة تتنفّس.
        FadeTransition(
          opacity: RifqReducedMotion.ambientEnabled(context)
              ? Tween(begin: 0.35, end: 0.75).animate(_breath)
              : const AlwaysStoppedAnimation(0.6),
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.gold.withValues(alpha: 0.25),
            ),
          ),
        ),
        const SizedBox(height: RifqSpacing.xl),
        Text('الهاتف هنا. أنت هناك.',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: palette.textPrimary)),
        const SizedBox(height: RifqSpacing.sm),
        // إشارة وقت هادئة غير مخيفة (لا عدّاد تنازلي دقيق).
        Text(_softRemaining(remaining),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: palette.textSecondary)),
        const Spacer(),
        // خروج خفي.
        TextButton(
          onPressed: () => setState(() {
            _timer?.cancel();
            _phase = _Phase.ended;
          }),
          child: Text('أنهِ الخلوة',
              style: TextStyle(color: palette.textSecondary)),
        ),
      ],
    );
  }

  Widget _endedView(BuildContext context, RifqPalette palette) {
    return ListView(
      children: [
        const SizedBox(height: RifqSpacing.xl),
        Text('رجعت 🌿',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: palette.textPrimary)),
        const SizedBox(height: RifqSpacing.lg),
        Text('ماذا حدث خارج الهاتف؟',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: palette.textPrimary)),
        const SizedBox(height: RifqSpacing.sm),
        TextField(
          controller: _note,
          maxLines: 4,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(hintText: 'لحظة، شعور، أو لا شيء…'),
        ),
        const SizedBox(height: RifqSpacing.lg),
        FilledButton(
          onPressed: _saveAndLeave,
          child: const Text('احفظ وارجع'),
        ),
        TextButton(
          onPressed: () => context.go('/'),
          child: const Text('ارجع بلا حفظ'),
        ),
      ],
    );
  }

  String _durationLabel(int m) => switch (m) {
        30 => '30 دقيقة',
        60 => 'ساعة',
        120 => 'ساعتان',
        _ => 'نصف يوم',
      };

  /// إشارة وقت لطيفة بدل عدّاد تنازلي يخيف.
  String _softRemaining(Duration d) {
    if (d.inMinutes <= 0) return 'اقترب وقت العودة';
    if (d.inMinutes < 60) return 'ما زال أمامك بعض الوقت';
    return 'خذ وقتك… لا تستعجل';
  }
}
