import 'package:flutter/material.dart';

import '../db/database.dart';
import '../db/models.dart';
import '../theme.dart';
import 'money.dart';

class BeforePayResult {
  final String action; // buy | wait | save
  const BeforePayResult(this.action);
}

class BeforePaySheet extends StatefulWidget {
  final double? suggestedAmount;
  final String? suggestedReason;
  const BeforePaySheet({super.key, this.suggestedAmount, this.suggestedReason});

  @override
  State<BeforePaySheet> createState() => _BeforePaySheetState();
}

class _BeforePaySheetState extends State<BeforePaySheet> {
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  bool? q1;
  bool? q2;
  bool? q3;

  @override
  void initState() {
    super.initState();
    if (widget.suggestedAmount != null) {
      _amountCtrl.text = widget.suggestedAmount!.toStringAsFixed(0);
    }
    if (widget.suggestedReason != null) {
      _reasonCtrl.text = widget.suggestedReason!;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Widget _q(String text, bool? value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
          const SizedBox(width: 12),
          _chip('آه', value == true, () => onChanged(true)),
          const SizedBox(width: 8),
          _chip('لأ', value == false, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          border: Border.all(color: selected ? AppColors.accent : AppColors.divider),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Color _verdictColor() {
    final yesCount = [q1, q2, q3].where((e) => e == true).length;
    final noCount = [q1, q2, q3].where((e) => e == false).length;
    if (yesCount >= 2 && q1 == true) return AppColors.good;
    if (noCount >= 2) return AppColors.bad;
    return AppColors.warn;
  }

  String _verdictText() {
    if (q1 == null || q2 == null || q3 == null) return '';
    final yes = [q1, q2, q3].where((e) => e == true).length;
    if (yes >= 2 && q1 == true) return 'يبدو قرار جيد. اشتري بضمير مرتاح.';
    if ([q1, q2, q3].where((e) => e == false).length >= 2) {
      return 'في الغالب مش محتاجها. أجّل أو وفّر المبلغ.';
    }
    return 'مش محسوم. خد 24 ساعة وقرر بعدها.';
  }

  Future<void> _save(String action) async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final reason = _reasonCtrl.text.trim();

    if (action == 'save' && amount > 0) {
      await AppDb.instance.insertSaving(Saving(
        date: DateTime.now(),
        amount: amount,
        reason: reason.isEmpty ? 'وفّرت قبل ما أدفع' : reason,
        category: 'مقاومة',
        createdAt: DateTime.now(),
      ));
    } else if (action == 'wait' && amount > 0) {
      await AppDb.instance.insertWaiting(WaitingItem(
        createdAt: DateTime.now(),
        amount: amount,
        description: reason.isEmpty ? 'انتظار 24 ساعة' : reason,
      ));
    }
    if (mounted) Navigator.of(context).pop(BeforePayResult(action));
  }

  @override
  Widget build(BuildContext context) {
    final answered = q1 != null && q2 != null && q3 != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
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
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('قبل ما أدفع',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'المبلغ',
                prefixIcon: Icon(Icons.attach_money, size: 18),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(
                hintText: 'الحاجة اللي ناوي تشتريها',
              ),
            ),
            const SizedBox(height: 16),
            _q('هل ده ضروري؟', q1, (v) => setState(() => q1 = v)),
            _q('هل عندي بديل أرخص؟', q2, (v) => setState(() => q2 = v)),
            _q('هل هافرح بيه بعد 48 ساعة؟', q3, (v) => setState(() => q3 = v)),
            if (answered) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _verdictColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: _verdictColor()),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _verdictText(),
                        style: TextStyle(
                          color: _verdictColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _save('buy'),
                    child: const Text('اشتري'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _save('wait'),
                    child: const Text('أجّل 24 ساعة'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _save('save'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.good),
                    child: const Text('وفّر المبلغ'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if ((double.tryParse(_amountCtrl.text.trim()) ?? 0) > 0)
              Center(
                child: Text(
                  'لو وفّرت: ${fmtMoney(double.parse(_amountCtrl.text.trim()))} ➜ صندوق «أنا أولى»',
                  style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
