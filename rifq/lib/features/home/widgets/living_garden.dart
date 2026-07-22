import 'package:flutter/material.dart';

import '../../../design_system/rifq_reduced_motion.dart';
import '../../../design_system/rifq_spacing.dart';
import '../../../design_system/rifq_theme_extensions.dart';
import 'garden_scene.dart';

/// وجهة داخل الحديقة: تسمية عربية + سطر شارح + موضع نسبي + فعل.
class GardenDestination {
  const GardenDestination({
    required this.label,
    required this.hint,
    required this.alignment,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final String hint;
  final Alignment alignment;
  final VoidCallback onTap;
  final IconData icon;
}

/// الحديقة الحية — مشهد واحد هادئ يضم الأنظمة الثلاثة كوجهات واضحة.
/// كل وجهة لها تسمية عربية ومساحة لمس ≥ 48، فلا يعتمد الفهم على الرسم وحده.
/// الحركة المحيطة بطيئة جدًا وتتوقف عند الخلفية أو تفعيل «تقليل الحركة».
class LivingGarden extends StatefulWidget {
  const LivingGarden({super.key, required this.destinations});

  final List<GardenDestination> destinations;

  @override
  State<LivingGarden> createState() => _LivingGardenState();
}

class _LivingGardenState extends State<LivingGarden>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // نبضة محيطة بطيئة جدًا (8 ثوانٍ) — بالكاد ملحوظة.
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // احترام «تقليل الحركة»: يبقى المشهد ساكنًا تمامًا.
    if (RifqReducedMotion.ambientEnabled(context)) {
      if (!_ambient.isAnimating) _ambient.repeat();
    } else {
      _ambient.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // إيقاف الحركة عند الخلفية حفاظًا على البطارية.
    if (state == AppLifecycleState.resumed) {
      if (mounted && RifqReducedMotion.ambientEnabled(context)) {
        _ambient.repeat();
      }
    } else {
      _ambient.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    final light = dayLightFor(DateTime.now());

    return AspectRatio(
      aspectRatio: 1.15,
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // المشهد المرسوم — مستبعد من الدلالات (زخرفي).
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: AnimatedBuilder(
                      animation: _ambient,
                      builder: (context, _) => CustomPaint(
                        painter: GardenScenePainter(
                          palette: palette,
                          light: light,
                          ambient: _ambient.value,
                        ),
                      ),
                    ),
                  ),
                ),
                // الوجهات التفاعلية فوق المشهد.
                for (final d in widget.destinations)
                  Align(
                    alignment: d.alignment,
                    child: _DestinationChip(destination: d),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DestinationChip extends StatelessWidget {
  const _DestinationChip({required this.destination});

  final GardenDestination destination;

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '${destination.label} — ${destination.hint}',
      child: Material(
        color: palette.canvas.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: destination.onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            padding: const EdgeInsets.symmetric(
                horizontal: RifqSpacing.md, vertical: RifqSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(destination.icon, color: palette.forest, size: 24),
                const SizedBox(height: 2),
                Text(destination.label,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(destination.hint,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: palette.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
