import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/nav.dart';
import '../../core/theme/tokens.dart';
import '../../domain/collage_craft.dart';
import '../../domain/media_options.dart';
import '../../providers.dart';
import '../../services/slideshow_exporter.dart';
import '../../widgets/local_photo.dart';

class VideoStudioScreen extends ConsumerStatefulWidget {
  const VideoStudioScreen({super.key, this.initialPhotos = const []});

  final List<String> initialPhotos;

  @override
  ConsumerState<VideoStudioScreen> createState() => _VideoStudioScreenState();
}

class _VideoStudioScreenState extends ConsumerState<VideoStudioScreen> {
  late List<String> _photos = [...widget.initialPhotos];
  PhotoFilterId _filter = PhotoFilterId.none;
  VideoTransitionId _transition = VideoTransitionId.crossfade;
  VideoAspect _aspect = VideoAspect.reel;
  double _seconds = 3;
  int _musicIndex = 1;
  String? _customMusic;
  final _title = TextEditingController();
  final _endCard = TextEditingController(text: 'Memory Book');
  bool _busy = false;
  String? _output;
  VideoPlayerController? _player;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _player?.dispose();
    _title.dispose();
    _endCard.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    if (widget.initialPhotos.isNotEmpty) return;
    final draft = await ref.read(draftRepositoryProvider).loadVideo();
    if (!mounted || draft == null) return;
    setState(() {
      _photos = draft.photos;
      _aspect = VideoAspect.fromId(draft.aspect);
      _filter = PhotoFilterId.fromId(draft.filter);
      _transition = VideoTransitionId.fromId(draft.transition);
      _seconds = draft.seconds;
      _musicIndex = draft.musicIndex;
      _customMusic = draft.customMusicPath;
    });
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(draftRepositoryProvider).saveVideo(
            VideoDraft(
              photos: _photos,
              aspect: _aspect.id,
              filter: _filter.name,
              transition: _transition.name,
              seconds: _seconds,
              musicIndex: _musicIndex,
              customMusicPath: _customMusic,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: shelfBackButton(context),
        title: const Text('Memory film'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'A film from stills you already chose.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: _photos.isEmpty
                ? const Center(child: Text('Add stills to build a film'))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => LocalPhoto(
                      path: _photos[i],
                      width: 88,
                      height: 88,
                      cacheSize: const Size(88, 88),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final photos =
                  await ref.read(photoServiceProvider).pickImages(limit: 24);
              setState(() => _photos = photos);
              _scheduleSave();
            },
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose photos'),
          ),
          const SizedBox(height: 16),
          _labeled(
            'Aspect',
            DropdownButton<VideoAspect>(
              value: _aspect,
              dropdownColor: MbTokens.leather,
              items: VideoAspect.values
                  .map(
                    (a) => DropdownMenuItem(value: a, child: Text(a.label)),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() => _aspect = v ?? VideoAspect.reel);
                _scheduleSave();
              },
            ),
          ),
          _labeled(
            'Filter',
            DropdownButton<PhotoFilterId>(
              value: _filter,
              dropdownColor: MbTokens.leather,
              items: PhotoFilterId.values
                  .map(
                    (f) => DropdownMenuItem(value: f, child: Text(f.label)),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() => _filter = v ?? PhotoFilterId.none);
                _scheduleSave();
              },
            ),
          ),
          _labeled(
            'Transition',
            DropdownButton<VideoTransitionId>(
              value: _transition,
              dropdownColor: MbTokens.leather,
              items: VideoTransitionId.values
                  .map(
                    (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                  )
                  .toList(),
              onChanged: (v) {
                setState(
                  () => _transition = v ?? VideoTransitionId.crossfade,
                );
                _scheduleSave();
              },
            ),
          ),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Opening title (optional)',
            ),
            style: const TextStyle(color: MbTokens.cream),
          ),
          TextField(
            controller: _endCard,
            decoration: const InputDecoration(labelText: 'End card'),
            style: const TextStyle(color: MbTokens.cream),
          ),
          const SizedBox(height: 8),
          const Text(
            '9:16 keeps the film inside a Reels frame. Leave faces off the top and bottom bands.',
            style: TextStyle(color: MbTokens.paperDeep),
          ),
          Text('Seconds per still  ${_seconds.toStringAsFixed(1)}'),
          Slider(
            value: _seconds,
            min: 1,
            max: 6,
            onChanged: (v) {
              setState(() => _seconds = v);
              _scheduleSave();
            },
          ),
          Text(
            _customMusic == null
                ? 'Score  $_musicIndex.mp3'
                : 'Your track  ${p.basename(_customMusic!)}',
          ),
          if (_customMusic == null)
            Slider(
              value: _musicIndex.toDouble(),
              min: 1,
              max: 11,
              divisions: 10,
              onChanged: (v) {
                setState(() => _musicIndex = v.round());
                _scheduleSave();
              },
            ),
          OutlinedButton.icon(
            onPressed: _pickMusic,
            icon: const Icon(Icons.library_music_outlined),
            label: Text(_customMusic == null ? 'Use my music' : 'Change music'),
          ),
          if (_customMusic != null)
            TextButton(
              onPressed: () {
                setState(() => _customMusic = null);
                _scheduleSave();
              },
              child: const Text('Back to bundled scores'),
            ),
          FilledButton(
            onPressed: _photos.isEmpty || _busy ? null : _generate,
            child: Text(_busy ? 'Cutting the film…' : 'Generate video'),
          ),
          if (_output != null) ...[
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: _aspect.ratio,
              child: _player == null
                  ? const ColoredBox(color: Colors.black)
                  : VideoPlayer(_player!),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(exportServiceProvider)
                        .saveVideoToGallery(File(_output!));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved to camera roll')),
                    );
                  },
                  child: const Text('Save'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => ref
                      .read(exportServiceProvider)
                      .shareFile(File(_output!)),
                  child: const Text('Share'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _labeled(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(child: child),
        ],
      ),
    );
  }

  Future<void> _pickMusic() async {
    final files = await FilePicker.pickFiles(type: FileType.audio);
    final path = files.isEmpty ? null : files.first.path;
    if (path == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(p.join(dir.path, 'music_${p.basename(path)}'));
    await File(path).copy(dest.path);
    setState(() => _customMusic = dest.path);
    _scheduleSave();
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    await ref.read(localNotifyProvider).request();
    try {
      final musicPath = _customMusic ??
          await _materializeAsset(
            SlideshowExporter.bundledMusic(_musicIndex - 1)!,
          );
      final file = await ref.read(slideshowExporterProvider).export(
            images: _photos,
            aspect: _aspect,
            filter: _filter,
            transition: _transition,
            secondsPerSlide: _seconds,
            audioPath: musicPath,
            title: _title.text,
            endCard: _endCard.text,
          );
      await ref.read(exportHistoryProvider).add('Memory film');
      await _player?.dispose();
      _player = VideoPlayerController.file(file);
      await _player!.initialize();
      await _player!.setLooping(true);
      await _player!.play();
      setState(() => _output = file.path);
      await ref.read(localNotifyProvider).show(
            title: 'Your reel is ready',
            body: 'Open Memory Book to watch or save the film.',
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String> _materializeAsset(String asset) async {
    final data = await rootBundle.load(asset);
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, p.basename(asset)));
    await file.writeAsBytes(data.buffer.asUint8List());
    return file.path;
  }
}
