import 'package:flutter/material.dart';

import '../../../design_system/rifq_theme_extensions.dart';

/// ماء ساكن تستقرّ عليه حصوات — كل حصاة لحظة عودة.
/// رسم متجهي خفيف وساكن (بلا حركة) — المرآة مكان تأمل لا حركة.
class StillWaterPainter extends CustomPainter {
  StillWaterPainter({required this.palette, required this.stoneCount});

  final RifqPalette palette;

  /// عدد الحصوات المرئية (مقصوص بصريًا) — يعكس لحظات العودة.
  final int stoneCount;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // بركة بيضاوية عاكسة تملأ العرض.
    final pool = Rect.fromLTWH(w * 0.06, h * 0.30, w * 0.88, h * 0.62);
    final poolPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.water.withValues(alpha: 0.5),
          palette.water.withValues(alpha: 0.75),
        ],
      ).createShader(pool);
    canvas.drawOval(pool, poolPaint);
    canvas.drawOval(
      pool,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = palette.water.withValues(alpha: 0.85),
    );

    // انعكاس ضوء هادئ أعلى الماء.
    canvas.drawOval(
      Rect.fromLTWH(w * 0.16, h * 0.36, w * 0.34, h * 0.10),
      Paint()..color = palette.canvas.withValues(alpha: 0.22),
    );

    // حصوات مستقرّة على حافة الماء — بلا أرقام، مجرد أثر مادي.
    final visible = stoneCount.clamp(0, 14);
    final stonePaint = Paint()..color = palette.sand;
    final stoneShade = Paint()..color = palette.forest.withValues(alpha: 0.12);
    for (var i = 0; i < visible; i++) {
      // توزيع شبه منتظم على قوس الحافة السفلية.
      final t = visible == 1 ? 0.5 : i / (visible - 1);
      final angle = 3.14159 * (0.15 + 0.7 * t); // قوس سفلي
      final cx = pool.center.dx - (pool.width / 2) * 0.82 * _cos(angle);
      final cy = pool.center.dy + (pool.height / 2) * 0.72 * _sin(angle);
      final r = w * (0.018 + 0.010 * (i % 3));
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, cy + r * 0.5), width: r * 2.4, height: r * 0.9),
        stoneShade,
      );
      canvas.drawCircle(Offset(cx, cy), r, stonePaint);
    }
  }

  // جيب/جيب تمام بسيطان لتفادي استيراد dart:math لقيم قليلة.
  double _sin(double x) {
    // تقريب كافٍ للزوايا ضمن [0, pi].
    return _cos(x - 1.5707963);
  }

  double _cos(double x) {
    var t = x;
    // إرجاع t إلى [-pi, pi].
    while (t > 3.14159265) {
      t -= 6.2831853;
    }
    while (t < -3.14159265) {
      t += 6.2831853;
    }
    final t2 = t * t;
    // متسلسلة تايلور حتى الحد السادس.
    return 1 - t2 / 2 + t2 * t2 / 24 - t2 * t2 * t2 / 720;
  }

  @override
  bool shouldRepaint(StillWaterPainter old) =>
      old.stoneCount != stoneCount || old.palette != palette;
}

/// رأس المرآة — ماء ساكن بحصوات العودة، بارتفاع ثابت مريح.
class StillWaterHeader extends StatelessWidget {
  const StillWaterHeader({super.key, required this.stoneCount});

  final int stoneCount;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: StillWaterPainter(
              palette: RifqPalette.of(context),
              stoneCount: stoneCount,
            ),
          ),
        ),
      ),
    );
  }
}
