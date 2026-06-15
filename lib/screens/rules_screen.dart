import 'package:flutter/material.dart';

import '../db/database.dart';
import '../db/models.dart';
import '../theme.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  List<Rule> _rules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await AppDb.instance.rules();
    if (!mounted) return;
    setState(() {
      _rules = r;
      _loading = false;
    });
  }

  Future<void> _add() async {
    final result = await showDialog<Rule>(
      context: context,
      builder: (_) => const _RuleEditor(),
    );
    if (result != null) {
      await AppDb.instance.upsertRule(result);
      await _load();
    }
  }

  Future<void> _delete(Rule r) async {
    await AppDb.instance.deleteRule(r.id!);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final grouped = <String, List<Rule>>{};
    for (final r in _rules) {
      grouped.putIfAbsent(r.category, () => []).add(r);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add),
        label: const Text('قاعدة جديدة'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.accent, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'كل كلمة هنا بتتحوّل تلقائياً لتصنيف عند كتابة مصروف.',
                    style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...grouped.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.value
                        .map((r) => InputChip(
                              label: Text(r.keyword),
                              onDeleted: () => _delete(r),
                              backgroundColor: AppColors.bg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: AppColors.divider),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RuleEditor extends StatefulWidget {
  const _RuleEditor();

  @override
  State<_RuleEditor> createState() => _RuleEditorState();
}

class _RuleEditorState extends State<_RuleEditor> {
  final _kw = TextEditingController();
  final _cat = TextEditingController();

  @override
  void dispose() {
    _kw.dispose();
    _cat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('قاعدة جديدة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _kw,
            decoration: const InputDecoration(hintText: 'كلمة (مثال: أوبر)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cat,
            decoration: const InputDecoration(hintText: 'تصنيف (مثال: مواصلات)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final k = _kw.text.trim();
            final c = _cat.text.trim();
            if (k.isEmpty || c.isEmpty) return;
            Navigator.pop(context, Rule(keyword: k, category: c));
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
