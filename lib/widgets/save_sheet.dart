import 'package:flutter/material.dart';

import '../db/database.dart';
import '../db/models.dart';
import '../theme.dart';

class SaveSheet extends StatefulWidget {
  const SaveSheet({super.key});

  @override
  State<SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends State<SaveSheet> {
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  String? _category;

  static const _cats = ['قهوة', 'أكل', 'شوبينج', 'مواصلات', 'هدايا', 'أخرى'];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    await AppDb.instance.insertSaving(Saving(
      date: DateTime.now(),
      amount: amount,
      reason: _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
      category: _category,
      createdAt: DateTime.now(),
    ));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.good,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Text('كنت هاصرف',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'حاجة كنت ناوي تشتريها ومشتريتش — هتتسجل في صندوق «أنا أولى».',
            style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'المبلغ اللي مصرفتوش'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reasonCtrl,
            decoration: const InputDecoration(hintText: 'إيه اللي كنت هتشتريه؟'),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: _cats.map((c) {
              final selected = c == _category;
              return ChoiceChip(
                label: Text(c),
                selected: selected,
                onSelected: (_) => setState(() => _category = selected ? null : c),
                selectedColor: AppColors.good.withOpacity(0.2),
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: selected ? AppColors.good : AppColors.divider,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.good),
              child: const Text('سجّل الادخار'),
            ),
          ),
        ],
      ),
    );
  }
}
