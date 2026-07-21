import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/content/seed_texts.dart';
import '../../core/db/models.dart';
import '../../core/privacy/safety_check.dart';
import '../../core/providers.dart';
import '../../shared/voice_recorder.dart';
import '../../shared/widgets.dart';

/// حصاد اليوم: توثيق الإنجازات الصغيرة + التأمل المسائي.
/// لا يوجد «يوم ناجح/فاشل» — فقط: ما الشيء الصغير الذي لا تريد أن يضيع؟
class HarvestScreen extends ConsumerStatefulWidget {
  const HarvestScreen({super.key});

  @override
  ConsumerState<HarvestScreen> createState() => _HarvestScreenState();
}

class _HarvestScreenState extends ConsumerState<HarvestScreen> {
  final _winTitle = TextEditingController();
  final _winDetails = TextEditingController();
  final _learned = TextEditingController();
  final _gratitude = TextEditingController();
  final _release = TextEditingController();
  WinCategory _category = WinCategory.habit;
  String? _imagePath;
  String? _voicePath;
  int _mood = 3;

  static const _categoryLabels = {
    WinCategory.study: 'مذاكرة',
    WinCategory.habit: 'عادة صغيرة',
    WinCategory.slowLiving: 'حياة أبطأ',
    WinCategory.meaning: 'معنى',
    WinCategory.worship: 'عبادة (خاص دائمًا)',
    WinCategory.charity: 'صدقة (خاص دائمًا)',
    WinCategory.privateFamily: 'عائلة (خاص دائمًا)',
    WinCategory.health: 'صحة (خاص دائمًا)',
    WinCategory.financial: 'مال (خاص دائمًا)',
    WinCategory.other: 'حاجة تانية',
  };

  @override
  void dispose() {
    _winTitle.dispose();
    _winDetails.dispose();
    _learned.dispose();
    _gratitude.dispose();
    _release.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _checkSafety(String text) async {
    if (containsSelfHarmSignal(text)) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('إنت مش لوحدك'),
          content: const Text(supportiveMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('فهمت'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveWin() async {
    if (_winTitle.text.trim().isEmpty) return;
    await _checkSafety('${_winTitle.text} ${_winDetails.text}');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final win = SmallWin.create(
      date: today,
      title: _winTitle.text.trim(),
      details: _winDetails.text.trim(),
      category: _category,
      imagePath: _imagePath,
    );
    await ref.read(winsRepoProvider).add(win);
    ref.invalidate(todayWinsProvider);
    _winTitle.clear();
    _winDetails.clear();
    setState(() => _imagePath = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(win.category.sensitiveByDefault
              ? 'اتحفظ خاص — بينك وبين نفسك 🌿'
              : 'اتوثّق 🌿')));
    }
  }

  Future<void> _saveReflection() async {
    await _checkSafety(
        '${_learned.text} ${_gratitude.text} ${_release.text}');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await ref.read(reflectionRepoProvider).add(Reflection(
          date: today,
          learned: _learned.text.trim(),
          gratitude: _gratitude.text.trim(),
          releaseThought: _release.text.trim(),
          moodAfter: _mood,
          voicePath: _voicePath,
        ));
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final todayWins = ref.watch(todayWinsProvider).valueOrNull ?? [];
    final prompt = eveningReflectionPrompts[
        DateTime.now().day % eveningReflectionPrompts.length];
    return Scaffold(
      appBar: AppBar(title: const Text('حصاد اليوم')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionCard(
            title: 'أوثّق لحظتي',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalmTextField(
                    controller: _winTitle,
                    hint: 'إنجاز صغير… حتى «فتحت الكتاب» يُحسب',
                    maxLines: 1),
                const SizedBox(height: 10),
                CalmTextField(
                    controller: _winDetails,
                    hint: 'تفاصيل أو درس (اختياري)',
                    maxLines: 2),
                const SizedBox(height: 10),
                ChoiceChips(
                  options: _categoryLabels.values.toList(),
                  selected: _categoryLabels[_category],
                  onSelected: (v) => setState(() {
                    _category = _categoryLabels.entries
                        .firstWhere((e) => e.value == v)
                        .key;
                  }),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.image_outlined),
                      label: Text(_imagePath == null ? 'صورة' : 'اتحطت ✓'),
                      onPressed: _pickImage,
                    ),
                    const Spacer(),
                    FilledButton(
                        onPressed: _saveWin, child: const Text('وثّق')),
                  ],
                ),
              ],
            ),
          ),
          if (todayWins.isNotEmpty)
            SectionCard(
              title: 'لحظات النهارده',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final w in todayWins)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            w.privacyLevel == PrivacyLevel.private
                                ? Icons.lock_outline
                                : Icons.eco_outlined,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(w.title)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          SectionCard(
            title: prompt,
            child: Column(
              children: [
                CalmTextField(controller: _learned, hint: 'حاجة اتعلمتها'),
                const SizedBox(height: 10),
                CalmTextField(
                    controller: _gratitude, hint: 'حاجة شاكر عليها'),
                const SizedBox(height: 10),
                CalmTextField(
                    controller: _release,
                    hint: 'حاجة هسيبها ومش هشيلها لبكرة'),
                const SizedBox(height: 10),
                VoiceRecorder(onChanged: (p) => _voicePath = p),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('شعوري دلوقتي'),
                    Expanded(
                      child: Slider(
                        value: _mood.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '$_mood',
                        onChanged: (v) =>
                            setState(() => _mood = v.round()),
                      ),
                    ),
                  ],
                ),
                FilledButton(
                    onPressed: _saveReflection,
                    child: const Text('اختم اليوم بهدوء')),
              ],
            ),
          ),
          const GentleFooter(
              text: 'أحب الأعمال إلى الله أدومها وإن قل — متفق عليه.'),
        ],
      ),
    );
  }
}
