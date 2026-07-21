import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models.dart';

/// مؤقت بسيط بلا اقتباسات متغيرة ولا ضغط — Pause وEnd early بدون لوم.
class FocusTimerScreen extends ConsumerStatefulWidget {
  const FocusTimerScreen({super.key, required this.session});

  final FocusSession session;

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _paused = false;

  int get _totalSeconds => widget.session.plannedMinutes * 60;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      setState(() => _elapsedSeconds++);
      if (_elapsedSeconds >= _totalSeconds) _end(completed: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _end({required bool completed}) {
    _timer?.cancel();
    final updated = widget.session.copyWith(
      actualMinutes: (_elapsedSeconds / 60).ceil(),
      status: completed ? FocusStatus.completed : FocusStatus.endedEarly,
      endedAt: DateTime.now(),
    );
    context.pushReplacement('/focus/review', extra: updated);
  }

  String _fmt(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _totalSeconds - _elapsedSeconds;
    return Scaffold(
      appBar: AppBar(title: Text(widget.session.subject)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.session.tinyStep,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 40),
            Text(_fmt(remaining < 0 ? 0 : remaining),
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontFeatures: const [])),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (_elapsedSeconds / _totalSeconds).clamp(0.0, 1.0),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                    label: Text(_paused ? 'كمّل' : 'وقفة'),
                    onPressed: () => setState(() => _paused = !_paused),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('أنهي دلوقتي'),
                    onPressed: () => _end(completed: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'اللي عملته لحد هنا محسوب — الإنهاء المبكر مش خسارة.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
