import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../design_system/rifq_theme_extensions.dart';

/// وقت اليوم — يحدد لون الضوء في المشهد.
enum DayLight { dawn, morning, midday, evening, night }

DayLight dayLightFor(DateTime now) {
  final h = now.hour;
  if (h < 6) return DayLight.night;
  if (h < 9) return DayLight.dawn;
  if (h < 15) return DayLight.morning;
  if (h < 18) return DayLight.midday;
  if (h < 21) return DayLight.evening;
  return DayLight.night;
}

/// رسّام حديقة رِفْق — مشهد أصلي بالكامل بأشكال عضوية بسيطة:
/// بركة (المرآة)، طريق حجري (البوصلة)، وركن ظليل تحت شجرة (الملجأ)،
/// مع ضوء نهار يتغيّر حسب الوقت. خفيف: أشكال متجهية فقط، بلا صور.
///
/// [ambient] نبضة هادئة جدًا من 0→1→0 لتموّج الماء وميلان الأوراق.
/// عند تقليل الحركة تُمرَّر قيمة ثابتة فيبقى المشهد ساكنًا.
class GardenScenePainter extends CustomPainter {
  GardenScenePainter({
    required this.palette,
    required this.light,
    required this.ambient,
  });

  final RifqPalette palette;
  final DayLight light;
  final double ambient;

  Color get _lightTint => switch (light) {
        DayLight.dawn => palette.clay.withValues(alpha: 0.14),
        DayLight.morning => palette.gold.withValues(alpha: 0.12),
        DayLight.midday => palette.gold.withValues(alpha: 0.16),
        DayLight.evening => palette.clay.withValues(alpha: 0.18),
        DayLight.night => palette.forest.withValues(alpha: 0.22),
      };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ضوء علوي دافئ يتدرّج نحو القماش.
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.alphaBlend(_lightTint, palette.canvas),
          palette.canvas,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), sky);

    // شمس/قمر هادئ في الأعلى يمين.
    final orbCenter = Offset(w * 0.80, h * 0.20);
    canvas.drawCircle(
      orbCenter,
      w * 0.07,
      Paint()
        ..color = (light == DayLight.night ? palette.water : palette.gold)
            .withValues(alpha: 0.35),
    );

    // أرض عشبية ناعمة أسفل المشهد.
    final ground = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.5, h * 0.66, w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
        ground, Paint()..color = palette.sage.withValues(alpha: 0.18));

    _paintPool(canvas, w, h); // المرآة
    _paintPath(canvas, w, h); // البوصلة
    _paintTree(canvas, w, h); // الملجأ
  }

  /// بركة بيضاوية عاكسة مع تموّج خفيف — رمز المرآة (يسار).
  void _paintPool(Canvas canvas, double w, double h) {
    final center = Offset(w * 0.24, h * 0.80);
    final rect =
        Rect.fromCenter(center: center, width: w * 0.30, height: h * 0.16);
    canvas.drawOval(
        rect, Paint()..color = palette.water.withValues(alpha: 0.55));
    canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = palette.water.withValues(alpha: 0.8));
    // حلقتا تموّج تتنفّسان مع ambient.
    for (var i = 0; i < 2; i++) {
      final t = (ambient + i * 0.5) % 1.0;
      canvas.drawOval(
        Rect.fromCenter(
            center: center,
            width: w * 0.10 * (0.4 + t),
            height: h * 0.05 * (0.4 + t)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = palette.canvas.withValues(alpha: 0.5 * (1 - t)),
      );
    }
  }

  /// طريق من حصوات متدرّجة نحو العمق — رمز البوصلة (وسط).
  void _paintPath(Canvas canvas, double w, double h) {
    final stonePaint = Paint()..color = palette.sand.withValues(alpha: 0.85);
    final points = [
      Offset(w * 0.52, h * 0.92),
      Offset(w * 0.55, h * 0.85),
      Offset(w * 0.57, h * 0.79),
      Offset(w * 0.585, h * 0.74),
      Offset(w * 0.595, h * 0.70),
    ];
    for (var i = 0; i < points.length; i++) {
      final scale = 1.0 - i * 0.16;
      canvas.drawOval(
        Rect.fromCenter(
            center: points[i],
            width: w * 0.11 * scale,
            height: h * 0.03 * scale),
        stonePaint,
      );
    }
  }

  /// شجرة زيتون بظلّ يحتضن ركنًا — رمز الملجأ (يمين).
  void _paintTree(Canvas canvas, double w, double h) {
    final trunkTop = Offset(w * 0.80, h * 0.55);
    final trunkBase = Offset(w * 0.80, h * 0.76);
    canvas.drawLine(
      trunkBase,
      trunkTop,
      Paint()
        ..color = palette.forest.withValues(alpha: 0.65)
        ..strokeWidth = w * 0.02
        ..strokeCap = StrokeCap.round,
    );

    // ظل الركن المحمي أسفل الشجرة.
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.80, h * 0.80),
          width: w * 0.24,
          height: h * 0.06),
      Paint()..color = palette.forest.withValues(alpha: 0.10),
    );

    // ثلاث كتل أوراق تميل قليلًا مع ambient.
    final sway = math.sin(ambient * math.pi * 2) * 0.03;
    final leafPaint = Paint()..color = palette.sage.withValues(alpha: 0.7);
    final darkLeaf = Paint()..color = palette.forest.withValues(alpha: 0.55);
    void blob(double dx, double dy, double r, Paint p) {
      canvas.save();
      canvas.translate(trunkTop.dx, trunkTop.dy);
      canvas.rotate(sway);
      canvas.drawCircle(Offset(dx, dy), r, p);
      canvas.restore();
    }

    blob(-w * 0.06, -h * 0.02, w * 0.09, leafPaint);
    blob(w * 0.05, -h * 0.04, w * 0.08, darkLeaf);
    blob(0, -h * 0.08, w * 0.075, leafPaint);
  }

  @override
  bool shouldRepaint(GardenScenePainter old) =>
      old.ambient != ambient || old.light != light || old.palette != palette;
}
