import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/tokens.dart';
import '../../providers.dart';
import '../../services/analytics.dart';
import '../../services/auth_ai.dart';
import '../../services/slideshow_exporter.dart';

/// Empty string means send the photo with no extra words. Null means cancel.
Future<String?> askClipPrompt(BuildContext context) async {
  final controller = TextEditingController();
  final send = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: MbTokens.cream,
      title: const Text('This photo leaves the device'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'One credit animates this photo. Words only describe the motion, such as a breeze or a smile. They do not replace the picture.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'How should it move? Optional',
              hintText: 'A slow breeze, a small smile',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Keep it here'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Send'),
        ),
      ],
    ),
  );
  final prompt = controller.text.trim();
  controller.dispose();
  if (send != true) return null;
  return prompt;
}

Future<AiJobResult> runCloudClip(
  BuildContext context,
  WidgetRef ref, {
  String? imagePath,
  String? prompt,
}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const AlertDialog(
      backgroundColor: MbTokens.cream,
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Expanded(child: Text('Making the clip. This usually takes a minute.')),
        ],
      ),
    ),
  );
  var progressOpen = true;
  try {
    final client = ref.read(aiVideoClientProvider);
    final started = await client.generate(imagePath: imagePath, prompt: prompt);
    final finished = await client.awaitClip(started);
    final url = finished.videoUrl;
    if (url == null || url.isEmpty) return finished;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode >= 400) {
      return AiJobResult(
        ok: false,
        message: 'The clip was ready, but it could not be saved on this phone.',
        videoUrl: url,
      );
    }
    final file = await ref.read(exportServiceProvider).writeBytes(response.bodyBytes, 'mp4');
    try {
      await ref.read(reelLibraryProvider).keep(
            source: file,
            title: 'AI clip',
            kind: 'ai',
          );
      ref.invalidate(reelsProvider);
    } catch (_) {}
    await ref.read(nativeEncoderProvider).preparePlayback();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      progressOpen = false;
      await showDialog<void>(
        context: context,
        builder: (ctx) => _ClipDialog(file: file),
      );
    }
    return finished;
  } finally {
    if (progressOpen && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

class _ClipDialog extends ConsumerStatefulWidget {
  const _ClipDialog({required this.file});
  final File file;

  @override
  ConsumerState<_ClipDialog> createState() => _ClipDialogState();
}

class _ClipDialogState extends ConsumerState<_ClipDialog> {
  late File _file;
  VideoPlayerController? _controller;
  String? _error;
  String? _note;
  bool _saving = false;
  bool _saved = false;
  bool _scoring = false;

  @override
  void initState() {
    super.initState();
    _file = widget.file;
    _open(_file);
  }

  Future<void> _open(File file) async {
    final previous = _controller;
    if (mounted) setState(() => _controller = null);
    await previous?.dispose();
    final next = VideoPlayerController.file(file);
    try {
      await next.initialize();
      await ref.read(nativeEncoderProvider).preparePlayback();
      await next.setLooping(true);
      await next.setVolume(1);
      if (!mounted) {
        await next.dispose();
        return;
      }
      setState(() => _controller = next);
      await next.play();
    } catch (error) {
      await next.dispose();
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _saved) return;
    setState(() {
      _saving = true;
      _note = null;
    });
    try {
      await ref.read(exportServiceProvider).saveVideoToGallery(_file);
      await ref.read(exportHistoryProvider).add('Cloud clip');
      if (!mounted) return;
      setState(() {
        _saved = true;
        _note = 'Saved to your photo gallery.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to your photo gallery.')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = '$e'.replaceFirst('StateError: ', '');
      setState(() => _note = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    await ref.read(exportServiceProvider).shareVideo(_file, title: 'AI clip');
    await ref.read(exportHistoryProvider).add('Cloud clip');
  }

  Future<void> _addMusic() async {
    if (_scoring) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'The clip is silent. Add a score on this phone.',
                style: TextStyle(
                  fontFamily: MbTokens.serif,
                  fontSize: 22,
                  color: MbTokens.ink,
                ),
              ),
            ),
            for (var i = 1; i <= 11; i++)
              ListTile(
                title: Text('Score $i'),
                onTap: () => Navigator.pop(ctx, 'score:$i'),
              ),
            ListTile(
              title: const Text('A file from this phone'),
              onTap: () => Navigator.pop(ctx, 'file'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    setState(() {
      _scoring = true;
      _note = 'Adding music…';
    });
    try {
      final String audioPath;
      if (choice == 'file') {
        final files = await FilePicker.pickFiles(type: FileType.audio);
        final picked = files.isEmpty ? null : files.first.path;
        if (picked == null) {
          if (mounted) setState(() => _note = null);
          return;
        }
        audioPath = picked;
      } else {
        final index = int.parse(choice.split(':').last) - 1;
        final asset = SlideshowExporter.bundledMusic(index)!;
        final data = await rootBundle.load(asset);
        final dir = await getTemporaryDirectory();
        final audio = File(p.join(dir.path, p.basename(asset)));
        await audio.writeAsBytes(data.buffer.asUint8List());
        audioPath = audio.path;
      }
      final mixedPath = await ref.read(nativeEncoderProvider).mixAudio(
            videoPath: _file.path,
            audioPath: audioPath,
          );
      _file = File(mixedPath);
      await _open(_file);
      await ref.read(reelLibraryProvider).keep(
            source: _file,
            title: 'AI clip',
            kind: 'ai',
          );
      ref.invalidate(reelsProvider);
      analytics.track(AnalyticsEvents.reelScored);
      if (mounted) setState(() => _note = 'Music is on this clip.');
    } catch (error) {
      if (mounted) setState(() => _note = 'Could not add music: $error');
    } finally {
      if (mounted) setState(() => _scoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: MbTokens.cream,
      title: const Text('Your clip'),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                _error != null
                ? Text(_error!)
                : _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio == 0
                            ? 9 / 16
                            : _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      ),
            if (_note != null) ...[
              const SizedBox(height: 12),
              Text(
                _note!,
                style: const TextStyle(
                  fontFamily: MbTokens.sans,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MbTokens.ink,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _scoring ? null : _addMusic,
          child: Text(_scoring ? 'Adding…' : 'Add music'),
        ),
        TextButton(onPressed: _share, child: const Text('Share')),
        FilledButton(
          onPressed: _saving || _saved ? null : _save,
          child: Text(_saved ? 'Saved' : (_saving ? 'Saving…' : 'Save')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
