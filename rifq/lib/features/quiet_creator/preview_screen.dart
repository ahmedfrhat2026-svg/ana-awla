import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/content/content_template_engine.dart';
import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// معاينة المحتوى: تعديل، Value Check صادق (ليس Score)، نسخ، مشاركة عبر
/// Android Share Sheet، حفظ مسودة، أو «ليس الآن».
class PreviewScreen extends ConsumerStatefulWidget {
  const PreviewScreen({super.key, required this.draft});

  final ContentDraft draft;

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  late final TextEditingController _body;
  final _hashtags = TextEditingController();
  final Set<int> _checkedValues = {};

  @override
  void initState() {
    super.initState();
    _body = TextEditingController(text: widget.draft.body);
  }

  @override
  void dispose() {
    _body.dispose();
    _hashtags.dispose();
    super.dispose();
  }

  List<String> get _tags => _hashtags.text
      .split(RegExp(r'[\s,]+'))
      .where((t) => t.isNotEmpty)
      .take(5) // بحد أقصى خمسة هاشتاجات.
      .map((t) => t.startsWith('#') ? t : '#$t')
      .toList();

  String get _finalText =>
      [_body.text.trim(), if (_tags.isNotEmpty) _tags.join(' ')].join('\n\n');

  Future<void> _updateStatus(DraftStatus status) async {
    await ref
        .read(draftsRepoProvider)
        .update(widget.draft.copyWith(body: _body.text, status: status));
  }

  Future<void> _share() async {
    await _updateStatus(DraftStatus.shared);
    if (widget.draft.imagePath != null &&
        File(widget.draft.imagePath!).existsSync()) {
      await Share.shareXFiles([XFile(widget.draft.imagePath!)],
          text: _finalText);
    } else {
      await Share.share(_finalText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.draft.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.draft.imagePath != null &&
              File(widget.draft.imagePath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(File(widget.draft.imagePath!),
                  height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            maxLines: 12,
            minLines: 5,
            textDirection: TextDirection.rtl,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'نص المحتوى'),
          ),
          const SizedBox(height: 8),
          Text('${_body.text.length} حرف تقريبًا',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          CalmTextField(
              controller: _hashtags,
              hint: 'هاشتاجات (اختياري — 5 كحد أقصى)',
              maxLines: 1),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Value Check — بينك وبين نفسك، مش درجة',
            child: Column(
              children: [
                for (var i = 0; i < valueCheckQuestions.length; i++)
                  CheckboxListTile(
                    dense: true,
                    value: _checkedValues.contains(i),
                    title: Text(valueCheckQuestions[i]),
                    onChanged: (v) => setState(() {
                      v == true
                          ? _checkedValues.add(i)
                          : _checkedValues.remove(i);
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.ios_share),
            label: const Text('مشاركة عبر Share Sheet'),
            onPressed: _share,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('نسخ النص'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _finalText));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('اتنسخ ✓')));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('حفظ مسودة'),
                  onPressed: () async {
                    await _updateStatus(DraftStatus.draft);
                    if (context.mounted) context.go('/');
                  },
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () async {
              await _updateStatus(DraftStatus.notNow);
              if (context.mounted) context.go('/');
            },
            child: const Text('ليس الآن — والعيشة قبل النشر'),
          ),
        ],
      ),
    );
  }
}
