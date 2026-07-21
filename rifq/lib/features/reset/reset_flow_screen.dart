import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/sacred_texts.dart';
import '../../core/content/seed_texts.dart';
import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import 'breathing_widget.dart';

/// بروتوكول «أنا تايه دلوقتي» — عودة هادئة من 90 ثانية إلى 5 دقائق:
/// افصل → تنفّس → ارجع لقلبك → إيه اللي كنت هتعمله؟ → خطوة أرضية.
class ResetFlowScreen extends ConsumerStatefulWidget {
  const ResetFlowScreen({super.key});

  @override
  ConsumerState<ResetFlowScreen> createState() => _ResetFlowScreenState();
}

enum _Step { disconnect, chooseDuration, breathe, heart, need, tinyAction }

class _ResetFlowScreenState extends ConsumerState<ResetFlowScreen> {
  _Step _step = _Step.disconnect;
  int _breathSeconds = 90;
  bool _animate = true;
  String? _need;
  String? _tinyAction;
  int _disconnectRemaining = 5;
  Timer? _disconnectTimer;
  late final SacredText _sacred;

  static const _needs = [
    'أذاكر',
    'أصلي أو أتوضأ',
    'أنام',
    'أتحرك',
    'أعمل مهمة منزلية',
    'كنت بهرب من شعور',
    'مش عارف',
  ];

  @override
  void initState() {
    super.initState();
    _sacred = calmingTexts[DateTime.now().day % calmingTexts.length];
    _startDisconnect();
  }

  void _startDisconnect() {
    _disconnectTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _disconnectRemaining--);
      if (_disconnectRemaining <= 0) {
        t.cancel();
        setState(() => _step = _Step.chooseDuration);
      }
    });
  }

  @override
  void dispose() {
    _disconnectTimer?.cancel();
    super.dispose();
  }

  /// اقتراح خطوات أرضية مناسبة للاحتياج المختار.
  List<String> _suggestedActions() {
    return switch (_need) {
      'أذاكر' => const [
          'افتح صفحة واحدة بس',
          'اكتب أول سطر',
          'حل سؤال واحد',
          'رتّب المكتب لدقيقتين',
        ],
      'أصلي أو أتوضأ' => const ['توضأ فقط', 'اشرب كوب ماء ثم توضأ'],
      'أنام' => const [
          'حط الموبايل بعيد عن السرير',
          'اطفي النور واستلقِ من غير شاشة',
        ],
      'أتحرك' => const ['امشِ خمس دقائق من غير الهاتف', 'اعمل تمدد بسيط دقيقتين'],
      'أعمل مهمة منزلية' => const [
          'رتّب حاجة واحدة قدامك',
          'اغسل الأكواب اللي في الحوض بس',
        ],
      'كنت بهرب من شعور' => const [
          'اكتب الشعور في سطر واحد',
          'اشرب كوب ماء على مهل',
          'امشِ خمس دقائق من غير الهاتف',
        ],
      _ => [
          tinyActions[DateTime.now().minute % tinyActions.length],
          'اشرب كوب ماء على مهل',
          'بصّ من الشباك دقيقة',
        ],
    };
  }

  Future<void> _finish() async {
    final session = ResetSession(
      selectedNeed: _need ?? '',
      breathingDurationSeconds: _breathSeconds,
      tinyAction: _tinyAction ?? '',
      completed: true,
    );
    await ref.read(resetRepoProvider).add(session);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عودة هادئة'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'إنهاء بدون إكمال — مفيش مشكلة',
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: switch (_step) {
          _Step.disconnect => _disconnectView(),
          _Step.chooseDuration => _durationView(),
          _Step.breathe => BreathingCircle(
              totalSeconds: _breathSeconds,
              animate: _animate,
              onDone: () => setState(() => _step = _Step.heart),
            ),
          _Step.heart => _heartView(),
          _Step.need => _needView(),
          _Step.tinyAction => _tinyActionView(),
        },
      ),
    );
  }

  Widget _disconnectView() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ابعد عينيك عن الشاشة',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text('بصّ على أبعد حاجة حواليك… خمس ثوانٍ بس.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Text('$_disconnectRemaining',
              style: Theme.of(context).textTheme.displayMedium),
        ],
      );

  Widget _durationView() => ListView(
        children: [
          Text('جلسة التنفّس',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('شهيق 4 ثوانٍ، زفير 6 ثوانٍ — من غير حبس للنفس.',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          for (final (label, seconds) in const [
            ('دقيقة ونص — عودة سريعة', 90),
            ('3 دقائق — تهدئة أعمق', 180),
            ('5 دقائق — سكينة كاملة', 300),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton(
                onPressed: () => setState(() {
                  _breathSeconds = seconds;
                  _step = _Step.breathe;
                }),
                child: Text(label),
              ),
            ),
          SwitchListTile(
            title: const Text('حركة الدائرة'),
            subtitle: const Text('أوقفها لو الحركة بتضايقك'),
            value: _animate,
            onChanged: (v) => setState(() => _animate = v),
          ),
        ],
      );

  Widget _heartView() => ListView(
        children: [
          const SizedBox(height: 24),
          Text('ارجع لقلبك',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SectionCard(
            child: Column(
              children: [
                Text(
                  '«${_sacred.text}»',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _sacred.source,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (_sacred.hasTadabbur)
            SectionCard(
              title: 'تدبّر معي',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('«${_sacred.tadabbur!}»',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(_sacred.tadabburSource!,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => setState(() => _step = _Step.need),
            child: const Text('كمّل'),
          ),
        ],
      );

  Widget _needView() => ListView(
        children: [
          Text('إيه الشيء اللي كنت هتعمله قبل ما تتوه؟',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          for (final need in _needs)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _need = need;
                  _step = _Step.tinyAction;
                }),
                child: Text(need),
              ),
            ),
        ],
      );

  Widget _tinyActionView() => ListView(
        children: [
          Text('خطوة أرضية واحدة تكفي',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('مش مطلوب ساعتين — أصغر حاجة ترجّعك للحقيقي.',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          for (final action in _suggestedActions())
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FilledButton(
                onPressed: () {
                  _tinyAction = action;
                  _finish();
                },
                child: Text(action),
              ),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _finish,
            child: const Text('هرجع من غير خطوة — وده كفاية النهارده'),
          ),
        ],
      );
}
