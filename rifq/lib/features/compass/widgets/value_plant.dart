/// نبتة القيمة — رسم متجه أصلي هادئ يعبّر عن مرحلة نمو القيمة وحالتها
/// (نشطة أو في راحة) داخل حديقة القيم. رسم بالكامل عبر [CustomPainter]؛
/// لا صور ولا أصول خارجية. النبتة في «راحة» تبقى سليمة وهادئة أبدًا،
/// لا ذابلة ولا ميتة — لا عقوبة ولا حالة فشل.
library;

import 'package:flutter/material.dart';

import '../../../design_system/rifq_theme_extensions.dart';
import '../life_value.dart';

/// نقطة على منحنى بيزييه التربيعي عند المعامل [t] — تُستخدم لمحاذاة
/// الأوراق على انحناء الساق بدل توزيعها على خط مستقيم.
Offset _pointOnQuadratic(Offset p0, Offset p1, Offset p2, double t) {
  final double u = 1 - t;
  final double x = u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx;
  final double y = u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy;
  return Offset(x, y);
}

/// رسّام نبتة القيمة الواحدة — يعكس [ValueGrowth] بلا نص ولا رموز فشل.
class ValuePlantPainter extends CustomPainter {
  const ValuePlantPainter({required this.palette, required this.growth});

  final RifqPalette palette;
  final ValueGrowth growth;

  /// درجة اللون: أهدأ وأخفت في حالة الراحة، دون أي إيحاء بالذبول.
  Color _tone(Color color) =>
      growth.resting ? color.withValues(alpha: 0.55) : color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double centerX = w * 0.5;
    final double soilTop = h * 0.80;

    final Paint soilPaint = Paint()..color = _tone(palette.sand);
    final Paint leafPaint = Paint()..color = _tone(palette.sage);
    final Paint blossomPaint = Paint()..color = _tone(palette.gold);

    final Rect soilRect = Rect.fromCenter(
      center: Offset(centerX, h * 0.86),
      width: w * 0.62,
      height: h * 0.22,
    );
    canvas.drawOval(soilRect, soilPaint);

    switch (growth.stage) {
      case GrowthStage.seed:
        canvas.drawCircle(
          Offset(centerX, soilTop - h * 0.02),
          w * 0.035,
          leafPaint,
        );
        break;
      case GrowthStage.sprout:
        _drawStemAndLeaves(
          canvas: canvas,
          w: w,
          h: h,
          centerX: centerX,
          soilTop: soilTop,
          heightFactor: 0.22,
          strokeWidthFactor: 0.020,
          leafPaint: leafPaint,
        );
        break;
      case GrowthStage.growing:
        _drawStemAndLeaves(
          canvas: canvas,
          w: w,
          h: h,
          centerX: centerX,
          soilTop: soilTop,
          heightFactor: 0.42,
          strokeWidthFactor: 0.022,
          leafPaint: leafPaint,
        );
        break;
      case GrowthStage.established:
        _drawStemAndLeaves(
          canvas: canvas,
          w: w,
          h: h,
          centerX: centerX,
          soilTop: soilTop,
          heightFactor: 0.56,
          strokeWidthFactor: 0.024,
          leafPaint: leafPaint,
          secondBranch: true,
        );
        break;
      case GrowthStage.flourishing:
        _drawStemAndLeaves(
          canvas: canvas,
          w: w,
          h: h,
          centerX: centerX,
          soilTop: soilTop,
          heightFactor: 0.66,
          strokeWidthFactor: 0.026,
          leafPaint: leafPaint,
          blossomPaint: growth.resting ? null : blossomPaint,
        );
        break;
    }
  }

  /// يرسم الساق المنحنية وأوراقها، وفرعًا ثانويًا هادئًا أو زهرة صغيرة
  /// حسب مرحلة النمو.
  void _drawStemAndLeaves({
    required Canvas canvas,
    required double w,
    required double h,
    required double centerX,
    required double soilTop,
    required double heightFactor,
    required double strokeWidthFactor,
    required Paint leafPaint,
    bool secondBranch = false,
    Paint? blossomPaint,
  }) {
    final Offset p0 = Offset(centerX, soilTop);
    final Offset p2 = Offset(centerX, soilTop - h * heightFactor);
    final Offset p1 = Offset(centerX + w * 0.06, (p0.dy + p2.dy) * 0.5);

    final Paint stemPaint = Paint()
      ..color = _tone(palette.forest)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * strokeWidthFactor
      ..strokeCap = StrokeCap.round;

    final Path stemPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);
    canvas.drawPath(stemPath, stemPaint);

    final int leafCount = growth.leaves;
    for (int i = 0; i < leafCount; i++) {
      final double t = (i + 1) / (leafCount + 1);
      final Offset origin = _pointOnQuadratic(p0, p1, p2, t);
      final bool onRight = i.isEven;
      final double angle = onRight ? -0.55 : 3.6916;
      _drawLeaf(
        canvas: canvas,
        origin: origin,
        angle: angle,
        length: w * 0.22,
        width: w * 0.10,
        paint: leafPaint,
      );
    }

    if (secondBranch) {
      final Offset branchStart = _pointOnQuadratic(p0, p1, p2, 0.42);
      final Offset branchControl = Offset(
        branchStart.dx - w * 0.10,
        branchStart.dy - h * 0.05,
      );
      final Offset branchEnd = Offset(
        branchStart.dx - w * 0.16,
        branchStart.dy - h * 0.14,
      );
      final Paint branchPaint = Paint()
        ..color = _tone(palette.forest)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.015
        ..strokeCap = StrokeCap.round;
      final Path branchPath = Path()
        ..moveTo(branchStart.dx, branchStart.dy)
        ..quadraticBezierTo(
          branchControl.dx,
          branchControl.dy,
          branchEnd.dx,
          branchEnd.dy,
        );
      canvas.drawPath(branchPath, branchPaint);
    }

    if (blossomPaint != null) {
      canvas.drawCircle(
        Offset(p2.dx, p2.dy - h * 0.03),
        w * 0.045,
        blossomPaint,
      );
    }
  }

  /// يرسم ورقة واحدة كبيضاوية صغيرة مدارة للخارج من نقطة اتصالها بالساق.
  void _drawLeaf({
    required Canvas canvas,
    required Offset origin,
    required double angle,
    required double length,
    required double width,
    required Paint paint,
  }) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    final Rect leafRect = Rect.fromCenter(
      center: Offset(length * 0.5, 0),
      width: length,
      height: width,
    );
    canvas.drawOval(leafRect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ValuePlantPainter oldDelegate) {
    return oldDelegate.growth.stage != growth.stage ||
        oldDelegate.growth.resting != growth.resting ||
        oldDelegate.palette != palette;
  }
}

/// عرض مرئي صغير وثابت لنبتة قيمة واحدة داخل حديقة القيم. عنصر زخرفي بحت؛
/// التسمية النصية تأتي من الودجت الأب.
class ValuePlant extends StatelessWidget {
  const ValuePlant({super.key, required this.growth});

  final ValueGrowth growth;

  @override
  Widget build(BuildContext context) {
    final RifqPalette palette = RifqPalette.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: 96,
        height: 96,
        child: RepaintBoundary(
          child: CustomPaint(
            size: const Size(96, 96),
            painter: ValuePlantPainter(palette: palette, growth: growth),
          ),
        ),
      ),
    );
  }
}
