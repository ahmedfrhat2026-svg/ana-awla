import 'package:flutter/material.dart';

import '../db/database.dart';
import '../db/models.dart';
import '../theme.dart';

Future<void> showRegretPicker(BuildContext context, Expense e) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      Future<void> pick(RegretLevel r, NeedType n) async {
        await AppDb.instance.updateExpense(e.copyWith(regretLevel: r, needType: n));
        if (ctx.mounted) Navigator.of(ctx).pop();
      }

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('راضي عن المصروف؟',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _option(
                    label: 'آه راضي',
                    color: AppColors.good,
                    icon: Icons.sentiment_satisfied_alt,
                    onTap: () => pick(RegretLevel.happy, NeedType.necessary),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _option(
                    label: 'نص نص',
                    color: AppColors.warn,
                    icon: Icons.sentiment_neutral,
                    onTap: () => pick(RegretLevel.neutral, NeedType.niceToHave),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _option(
                    label: 'ندمان',
                    color: AppColors.bad,
                    icon: Icons.sentiment_dissatisfied,
                    onTap: () => pick(RegretLevel.regret, NeedType.impulse),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _option({
  required String label,
  required Color color,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}
