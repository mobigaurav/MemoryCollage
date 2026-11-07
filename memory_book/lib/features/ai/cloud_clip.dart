import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/config.dart';
import '../../core/theme/tokens.dart';
import '../../providers.dart';
import '../../widgets/film_player.dart';
import '../../services/analytics.dart';
import '../../services/auth_ai.dart';
import '../../services/slideshow_exporter.dart';

/// Empty string means send the photo with no extra words. Null means cancel.
Future<String?> askClipPrompt(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => const _ClipPrompt(),
  );
}

class _ClipPrompt extends ConsumerStatefulWidget {
  const _ClipPrompt();

  @override
  ConsumerState<_ClipPrompt> createState() => _ClipPromptState();
}

class _ClipPromptState extends ConsumerState<_ClipPrompt> {
  final _controller = TextEditingController();
  bool _buying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final credits = ref.watch(creditBalanceProvider).value ?? 0;
    final premium = ref.watch(premiumControllerProvider);
    return AlertDialog(
      backgroundColor: MbTokens.cream,
      title: const Text('This photo leaves the device'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Not free. This spends 1 credit. You have $credits. Premium does not include AI clips.',
            style: const TextStyle(
              fontFamily: MbTokens.sans,
              fontSize: 16,
              height: 1.4,
              color: MbTokens.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Words only describe the motion, such as a breeze or a smile. They do not replace the picture.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'How should it move? Optional',
              hintText: 'A slow breeze, a small smile',
            ),
          ),
          if (premium.error != null) ...[
            const SizedBox(height: 8),
            Text(premium.error!, style: const TextStyle(color: MbTokens.ink)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _buying
              ? null
              : () async {
                  setState(() => _buying = true);
                  await ref.read(premiumControllerProvider.notifier).buyCreditPack();
                  if (mounted) setState(() => _buying = false);
                },
          child: Text(_buying ? 'Buying…' : 'Buy ${AppConfig.creditPackSize} clips'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Keep it here'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Spend 1 credit'),
        ),
      ],
    );
  }
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
      await next.setLooping(false);
      await next.setVolume(1);
      await next.pause();
      if (!mounted) {
        await next.dispose();
        return;
      }
      setState(() => _controller = next);
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
                'The clip is silent. Add music on this phone.',
                style: TextStyle(
                  fontFamily: MbTokens.serif,
                  fontSize: 22,
                  color: MbTokens.ink,
                ),
              ),
            ),
            for (var i = 0; i < SlideshowExporter.musicNames.length; i++)
              ListTile(
                title: Text(SlideshowExporter.musicName(i)),
                onTap: () => Navigator.pop(ctx, 'score:${i + 1}'),
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
                : _controller != null
                    ? MbFilmPlayer(controller: _controller!)
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
        _ClipAction(
          icon: Icons.library_music_outlined,
          label: _scoring ? 'Adding' : 'Music',
          onPressed: _scoring ? null : _addMusic,
        ),
        _ClipAction(
          icon: Icons.ios_share,
          label: 'Share',
          onPressed: _share,
        ),
        _ClipAction(
          icon: _saved ? Icons.check : Icons.download_outlined,
          label: _saved ? 'Saved' : (_saving ? 'Saving' : 'Save'),
          onPressed: _saving || _saved ? null : _save,
        ),
        _ClipAction(
          icon: Icons.close,
          label: 'Close',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _ClipAction extends StatelessWidget {
  const _ClipAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null ? MbTokens.inkSoft : MbTokens.leather;
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: MbTokens.sans,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
