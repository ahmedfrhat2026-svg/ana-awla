import 'dart:async';

import 'package:flutter/material.dart';

/// دائرة تنفّس هادئة: شهيق 4 ثوانٍ، زفير 6 ثوانٍ، بلا حبس للنفس.
/// يمكن إيقاف الحركة (تبقى التعليمات النصية) مراعاةً لتفضيلات الحركة.
class BreathingCircle extends StatefulWidget {
  const BreathingCircle({
    super.key,
    required this.totalSeconds,
    required this.onDone,
    this.animate = true,
  });

  final int totalSeconds;
  final VoidCallback onDone;
  final bool animate;

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  static const inhaleSeconds = 4;
  static const exhaleSeconds = 6;

  late final AnimationController _controller;
  late final Animation<double> _scale;
  Timer? _ticker;
  int _elapsed = 0;
  bool _inhaling = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: inhaleSeconds),
    );
    _scale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _startPhase(inhale: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed++;
      if (_elapsed >= widget.totalSeconds) {
        _ticker?.cancel();
        widget.onDone();
      } else {
        setState(() {});
      }
    });
  }

  void _startPhase({required bool inhale}) {
    _inhaling = inhale;
    _controller.duration =
        Duration(seconds: inhale ? inhaleSeconds : exhaleSeconds);
    final future = inhale
        ? _controller.forward(from: 0)
        : _controller.reverse(from: 1);
    future.whenComplete(() {
      if (mounted && _elapsed < widget.totalSeconds) {
        setState(() => _startPhase(inhale: !inhale));
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = widget.totalSeconds - _elapsed;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _inhaling ? 'شهيق… ببطء' : 'زفير… أطول شوية',
          style: Theme.of(context).textTheme.headlineSmall,
          semanticsLabel: _inhaling ? 'خذ شهيقًا ببطء' : 'أخرج زفيرًا أطول',
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 220,
          height: 220,
          child: Center(
            child: widget.animate
                ? ScaleTransition(
                    scale: _scale,
                    child: _circle(scheme),
                  )
                : _circle(scheme),
          ),
        ),
        const SizedBox(height: 32),
        Text('$remaining ثانية متبقية',
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _circle(ColorScheme scheme) => Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.primary.withValues(alpha: 0.25),
          border: Border.all(color: scheme.primary, width: 2),
        ),
      );
}
