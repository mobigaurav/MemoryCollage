import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/tokens.dart';

/// Records up to twenty seconds. Returns the file, or null if they back out.
Future<File?> recordVoiceNote(BuildContext context) {
  return showModalBottomSheet<File>(
    context: context,
    isScrollControlled: true,
    backgroundColor: MbTokens.cream,
    builder: (ctx) => const _VoiceSheet(),
  );
}

class _VoiceSheet extends StatefulWidget {
  const _VoiceSheet();

  @override
  State<_VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends State<_VoiceSheet> {
  final _recorder = AudioRecorder();
  VideoPlayerController? _player;
  String? _path;
  var _recording = false;
  var _seconds = 0;
  var _playing = false;
  String? _error;
  Timer? _tick;

  @override
  void dispose() {
    _tick?.cancel();
    unawaited(_recorder.dispose());
    unawaited(_player?.dispose());
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_recording) {
      await _stop();
      return;
    }
    final allowed = await _recorder.hasPermission();
    if (!allowed) {
      setState(() => _error = 'Memory Book needs the microphone in Settings to record a voice note.');
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, 'voice-${DateTime.now().millisecondsSinceEpoch}.m4a');
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds += 1);
      if (_seconds >= 20) unawaited(_stop());
    });
    setState(() {
      _recording = true;
      _path = path;
      _seconds = 0;
      _error = null;
    });
  }

  Future<void> _stop() async {
    _tick?.cancel();
    final path = await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _recording = false;
      _path = path ?? _path;
    });
  }

  Future<void> _play() async {
    final path = _path;
    if (path == null) return;
    await _player?.dispose();
    final player = VideoPlayerController.file(File(path));
    _player = player;
    await player.initialize();
    await player.play();
    if (!mounted) return;
    setState(() => _playing = true);
    player.addListener(() {
      if (!mounted || player.value.isPlaying || !_playing) return;
      setState(() => _playing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final path = _path;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Voice note',
              style: TextStyle(fontFamily: MbTokens.serif, fontSize: 28, color: MbTokens.ink),
            ),
            const SizedBox(height: 4),
            const Text(
              'Up to 20 seconds. A QR mark goes on the page, and a scan plays this.',
              style: TextStyle(color: MbTokens.inkSoft, height: 1.35),
            ),
            const SizedBox(height: 16),
            Text(
              _recording ? 'Recording $_seconds s' : (path == null ? 'Ready' : 'Recorded $_seconds s'),
              style: const TextStyle(fontFamily: MbTokens.sans, fontWeight: FontWeight.w600),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: MbTokens.oxblood, height: 1.35)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _toggle,
                  icon: Icon(_recording ? Icons.stop : Icons.mic_none),
                  label: Text(_recording ? 'Stop' : 'Record'),
                ),
                const SizedBox(width: 12),
                if (path != null && !_recording)
                  OutlinedButton.icon(
                    onPressed: _playing ? null : _play,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: path == null || _recording ? null : () => Navigator.pop(context, File(path)),
              child: const Text('Put it on the page'),
            ),
          ],
        ),
      ),
    );
  }
}
