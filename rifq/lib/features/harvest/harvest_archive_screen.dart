import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/voice_recorder.dart';
import '../../shared/widgets.dart';

/// أرشيف الحصاد: كل ما وثّقته خلال الأسبوع أو الشهر —
/// الإنجازات الصغيرة، الدروس، والامتنان. ذاكرة هادئة، مش لوحة نتائج.
class HarvestArchiveScreen extends ConsumerStatefulWidget {
  const HarvestArchiveScreen({super.key});

  @override
  ConsumerState<HarvestArchiveScreen> createState() =>
      _HarvestArchiveScreenState();
}

class _HarvestArchiveScreenState extends ConsumerState<HarvestArchiveScreen> {
  int _days = 7;

  Future<(List<SmallWin>, List<Reflection>)> _load() async {
    final now = DateTime.now();
    final from = now
        .subtract(Duration(days: _days))
        .toIso8601String()
        .substring(0, 10);
    final to = now.toIso8601String().substring(0, 10);
    final wins = await ref.read(winsRepoProvider).between(from, to);
    final reflections =
        await ref.read(reflectionRepoProvider).between(from, to);
    return (wins, reflections);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حصاد رحلتك')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: ChoiceChips(
              options: const ['حصاد الأسبوع', 'حصاد الشهر'],
              selected: _days == 7 ? 'حصاد الأسبوع' : 'حصاد الشهر',
              onSelected: (v) =>
                  setState(() => _days = v == 'حصاد الأسبوع' ? 7 : 30),
            ),
          ),
          Expanded(
            child: FutureBuilder<(List<SmallWin>, List<Reflection>)>(
              future: _load(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final (wins, reflections) = snapshot.data!;
                if (wins.isEmpty && reflections.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'لسه مفيش حصاد في الفترة دي.\nأصغر لحظة توثّقها النهارده هتظهر هنا 🌿',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final lessons = reflections
                    .where((r) => r.learned.isNotEmpty)
                    .toList();
                final gratitudes = reflections
                    .where((r) => r.gratitude.isNotEmpty)
                    .toList();
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    SectionCard(
                      child: Text(
                        'في آخر ${_days == 7 ? 'أسبوع' : 'شهر'}: '
                        '${wins.length} ${wins.length == 1 ? 'لحظة موثّقة' : 'لحظة موثّقة'}'
                        '${lessons.isNotEmpty ? '، و${lessons.length} ${lessons.length == 1 ? 'درس' : 'دروس'}' : ''} — '
                        'ده إنجازك ${_days == 7 ? 'الأسبوعي' : 'الشهري'} الحقيقي.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (wins.isNotEmpty)
                      SectionCard(
                        title: 'لحظات وإنجازات',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final w in wins)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          w.privacyLevel ==
                                                  PrivacyLevel.private
                                              ? Icons.lock_outline
                                              : Icons.eco_outlined,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(w.date,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      ],
                                    ),
                                    Text(w.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                    if (w.details.isNotEmpty)
                                      Text(w.details,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    if (w.imagePath != null &&
                                        File(w.imagePath!).existsSync())
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            File(w.imagePath!),
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (lessons.isNotEmpty)
                      SectionCard(
                        title: 'دروس اتعلمتها',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final r in lessons)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('• ${r.learned}'),
                              ),
                          ],
                        ),
                      ),
                    if (gratitudes.isNotEmpty)
                      SectionCard(
                        title: 'حاجات شكرت الله عليها',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final r in gratitudes)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('• ${r.gratitude}'),
                              ),
                          ],
                        ),
                      ),
                    if (reflections.any((r) =>
                        r.voicePath != null &&
                        File(r.voicePath!).existsSync()))
                      SectionCard(
                        title: 'تسجيلاتك الصوتية',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final r in reflections.where((r) =>
                                r.voicePath != null &&
                                File(r.voicePath!).existsSync()))
                              Row(
                                children: [
                                  Text(r.date,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  Expanded(
                                      child: VoicePlayback(path: r.voicePath!)),
                                ],
                              ),
                          ],
                        ),
                      ),
                    const GentleFooter(
                        text: 'كل سطر هنا كان يومًا عشته فعلًا.'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
