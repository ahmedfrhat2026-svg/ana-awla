import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// مسجّل صوتي هادئ: تسجيل، إيقاف، سماع، وحذف.
/// إذن المايك يُطلب في سياقه — عند أول ضغطة تسجيل فقط.
/// الملفات تُحفظ محليًا في مجلد مستندات التطبيق ولا تغادر الجهاز.
class VoiceRecorder extends StatefulWidget {
  const VoiceRecorder({super.key, required this.onChanged, this.initialPath});

  /// يُستدعى بالمسار الجديد عند اكتمال تسجيل، وبـ null عند الحذف.
  final ValueChanged<String?> onChanged;
  final String? initialPath;

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  String? _path;
  bool _recording = false;
  bool _playing = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _path = widget.initialPath;
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!await _recorder.hasPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('من غير إذن المايك مفيش تسجيل — وده اختيارك تمامًا')));
      }
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/rifq_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path);
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
    if (mounted) setState(() => _recording = true);
  }

  Future<void> _stop() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (mounted) {
      setState(() {
        _recording = false;
        _path = path;
      });
    }
    widget.onChanged(path);
  }

  Future<void> _togglePlay() async {
    if (_path == null) return;
    if (_playing) {
      await _player.stop();
      if (mounted) setState(() => _playing = false);
    } else {
      await _player.play(DeviceFileSource(_path!));
      if (mounted) setState(() => _playing = true);
    }
  }

  Future<void> _delete() async {
    await _player.stop();
    final old = _path;
    setState(() {
      _path = null;
      _playing = false;
    });
    widget.onChanged(null);
    if (old != null) {
      try {
        File(old).deleteSync();
      } catch (_) {
        // الملف اتمسح قبل كده — مش مشكلة.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recording) {
      return Row(
        children: [
          Icon(Icons.mic, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Text('بيسجّل… $_seconds ث'),
          const Spacer(),
          FilledButton.icon(
            icon: const Icon(Icons.stop),
            label: const Text('كفاية كده'),
            onPressed: _stop,
          ),
        ],
      );
    }
    if (_path != null) {
      return Row(
        children: [
          IconButton(
            tooltip: _playing ? 'إيقاف' : 'اسمع تسجيلك',
            icon: Icon(_playing ? Icons.stop_circle_outlined
                : Icons.play_circle_outlined, size: 32),
            onPressed: _togglePlay,
          ),
          const Text('تسجيلك محفوظ ✓'),
          const Spacer(),
          IconButton(
            tooltip: 'حذف التسجيل',
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      );
    }
    return OutlinedButton.icon(
      icon: const Icon(Icons.mic_none),
      label: const Text('سجّل بصوتك (اختياري)'),
      onPressed: _start,
    );
  }
}

/// مشغّل تسجيل محفوظ — للعرض فقط في الأرشيف (بلا تسجيل ولا حذف).
class VoicePlayback extends StatefulWidget {
  const VoicePlayback({super.key, required this.path});

  final String path;

  @override
  State<VoicePlayback> createState() => _VoicePlaybackState();
}

class _VoicePlaybackState extends State<VoicePlayback> {
  final _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.stop();
      if (mounted) setState(() => _playing = false);
    } else {
      await _player.play(DeviceFileSource(widget.path));
      if (mounted) setState(() => _playing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(_playing
              ? Icons.stop_circle_outlined
              : Icons.play_circle_outlined),
          onPressed: _toggle,
        ),
        const Text('تسجيل صوتي'),
      ],
    );
  }
}
