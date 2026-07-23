import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../design_system/components/rifq_scaffold.dart';
import '../../design_system/components/rifq_surfaces.dart';
import '../../design_system/rifq_spacing.dart';
import '../../design_system/rifq_theme_extensions.dart';
import 'life_value.dart';
import 'widgets/value_plant.dart';

/// حديقة القيم — كل قيمة نبتة تنمو من أفعال ذات معنى، وتبطّأ عند الإهمال
/// لكنها لا تموت. اختيار القيم مرن، ويمكن تغييره مع تطوّر الإنسان.
class ValuesGardenScreen extends ConsumerWidget {
  const ValuesGardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = RifqPalette.of(context);
    final valuesAsync = ref.watch(lifeValuesProvider);

    return RifqScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RifqPageHeader(
            title: 'حديقة القيم',
            subtitle: 'ما تريد أن تمنحه مساحة — لا ما يبدو مثاليًا.',
            onBack: () => context.pop(),
          ),
          valuesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: RifqSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Text('تعذّر فتح الحديقة الآن.'),
            data: (values) => _content(context, ref, palette, values),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, RifqPalette palette,
      List<LifeValue> values) {
    final chosen = {for (final v in values) v.kind: v};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(compassObservation(values),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: RifqSpacing.lg),
        // النباتات المزروعة.
        if (chosen.isNotEmpty) ...[
          Wrap(
            spacing: RifqSpacing.md,
            runSpacing: RifqSpacing.md,
            children: [
              for (final v in values)
                _PlantTile(
                  value: v,
                  onAct: () async {
                    await ref.read(valuesRepoProvider).actOn(v.kind);
                    ref.invalidate(lifeValuesProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('نمَت ${v.kind.label} قليلًا 🌱')));
                    }
                  },
                  onRemove: () async {
                    await ref.read(valuesRepoProvider).remove(v.kind);
                    ref.invalidate(lifeValuesProvider);
                  },
                ),
            ],
          ),
          const SizedBox(height: RifqSpacing.xl),
        ],
        Text('أضِف قيمة للحديقة',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: RifqSpacing.sm),
        Wrap(
          spacing: RifqSpacing.sm,
          runSpacing: RifqSpacing.sm,
          children: [
            for (final kind in ValueKind.values)
              if (!chosen.containsKey(kind))
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(kind.label),
                  onPressed: () async {
                    await ref.read(valuesRepoProvider).choose(kind);
                    ref.invalidate(lifeValuesProvider);
                  },
                ),
          ],
        ),
        const SizedBox(height: RifqSpacing.xl),
        Center(
          child: Text(
            'النبتة لا تموت لو غبت — تستريح فقط، وتعود بأصغر فعل.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: palette.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _PlantTile extends StatelessWidget {
  const _PlantTile({
    required this.value,
    required this.onAct,
    required this.onRemove,
  });

  final LifeValue value;
  final VoidCallback onAct;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    final growth = value.growth();
    return SizedBox(
      width: 150,
      child: RifqOrganicSurface(
        padding: const EdgeInsets.all(RifqSpacing.sm),
        onTap: onAct,
        child: Column(
          children: [
            Semantics(
              label: '${value.kind.label} — '
                  '${growth.resting ? 'في راحة' : 'تنمو'}',
              child: ValuePlant(growth: growth),
            ),
            Text(value.kind.label,
                style: Theme.of(context).textTheme.titleMedium),
            Text(
              growth.resting ? 'في راحة — المسها لتعود' : 'اضغط لتخدمها',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: palette.textSecondary),
              textAlign: TextAlign.center,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'إزالة من الحديقة',
                icon: Icon(Icons.close, size: 18, color: palette.textSecondary),
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
