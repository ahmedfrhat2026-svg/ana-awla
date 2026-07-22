import 'package:flutter/material.dart';

import '../rifq_shapes.dart';
import '../rifq_spacing.dart';
import '../rifq_theme.dart';
import '../rifq_theme_extensions.dart';

/// سطح ورقي عضوي هادئ — بديل البطاقة، بظل ناعم وحافة مستديرة.
/// يفضّل الفصل اللوني (tonal) على الحدود، بلا ظل Material قاسٍ.
class RifqOrganicSurface extends StatelessWidget {
  const RifqOrganicSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(RifqSpacing.lg),
    this.color,
    this.radius = RifqRadii.large,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? palette.surface,
        borderRadius: radius,
        boxShadow: rifqSoftShadow(context),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return surface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        splashColor: palette.sage.withValues(alpha: 0.12),
        child: surface,
      ),
    );
  }
}

/// قسم بعنوان هادئ ومساحة سفلية مريحة.
class RifqSection extends StatelessWidget {
  const RifqSection({
    super.key,
    this.title,
    required this.child,
    this.trailing,
  });

  final String? title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RifqSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(title!,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: RifqSpacing.sm),
          ],
          child,
        ],
      ),
    );
  }
}

/// حالة فارغة رحيمة — أمل صادق بلا إيحاء بالفشل.
class RifqEmptyState extends StatelessWidget {
  const RifqEmptyState({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.spa_outlined,
    this.action,
  });

  final String title;
  final String body;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RifqSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: palette.sage),
            const SizedBox(height: RifqSpacing.md),
            Text(title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: RifqSpacing.xs),
            Text(body,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: palette.textSecondary),
                textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: RifqSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
