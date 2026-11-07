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
import '../../services/reel_jobs.dart';
import '../../services/slideshow_exporter.dart';
import '../../widgets/making_note.dart';
import '../../widgets/film_player.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            'A film from stills you already chose.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: _photos.isEmpty
                ? const Center(child: Text('Add stills to build a film'))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => LocalPhoto(
                      path: _photos[i],
                      width: 140,
                      height: 180,
                      cacheSize: const Size(140, 180),
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
              dropdownColor: Colors.white,
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
              dropdownColor: Colors.white,
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
              dropdownColor: Colors.white,
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
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _endCard,
            decoration: const InputDecoration(labelText: 'End card'),
          ),
          const SizedBox(height: 8),
          const Text(
            '9:16 keeps a portrait photo tall. 16:9 is a wide film. Photos stay upright either way.',
            style: TextStyle(
              fontFamily: MbTokens.sans,
              color: MbTokens.ink,
              height: 1.4,
            ),
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
                ? SlideshowExporter.musicName(_musicIndex - 1)
                : 'Your track  ${p.basename(_customMusic!)}',
            style: const TextStyle(
              fontFamily: MbTokens.sans,
              fontWeight: FontWeight.w600,
              color: MbTokens.ink,
            ),
          ),
          if (_customMusic == null)
            DropdownButton<int>(
              value: _musicIndex,
              isExpanded: true,
              dropdownColor: Colors.white,
              items: [
                for (var i = 0; i < SlideshowExporter.musicNames.length; i++)
                  DropdownMenuItem(
                    value: i + 1,
                    child: Text(SlideshowExporter.musicName(i)),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _musicIndex = value);
                _scheduleSave();
              },
            ),
          const SizedBox(height: 12),
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
              child: const Text('Use the included music'),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _photos.isEmpty ? null : _generate,
            child: const Text('Generate video'),
          ),
          if (ref.watch(reelJobsProvider).isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Center(child: MbMakingNote()),
            ),
          if (_output != null) ...[
            const SizedBox(height: 16),
            if (_player != null)
              MbFilmPlayer(
                controller: _player!,
                title: _title.text.trim().isEmpty ? 'Memory film' : _title.text.trim(),
                actions: [
                  MbFilmAction(
                    icon: Icons.ios_share,
                    label: 'Share',
                    onPressed: () => ref.read(exportServiceProvider).shareVideo(
                          File(_output!),
                          title: _title.text.trim().isEmpty
                              ? 'Memory film'
                              : _title.text.trim(),
                        ),
                  ),
                  MbFilmAction(
                    icon: Icons.download_outlined,
                    label: 'Save',
                    onPressed: () async {
                      await ref
                          .read(exportServiceProvider)
                          .saveVideoToGallery(File(_output!));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to camera roll')),
                      );
                    },
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
    await ref.read(localNotifyProvider).request();
    final images = [..._photos];
    final aspect = _aspect;
    final filter = _filter;
    final transition = _transition;
    final seconds = _seconds;
    final customMusic = _customMusic;
    final musicIndex = _musicIndex;
    final opening = _title.text;
    final endCard = _endCard.text;
    final title = opening.trim().isEmpty ? 'Memory film' : opening.trim();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Making your film. It shows up on Reels when it is ready. Keep going.'),
      ),
    );
    final reel = await ref.read(reelJobsProvider.notifier).run(
          label: title,
          failure: 'The film did not finish',
          work: (ref) async {
            final musicPath = customMusic ??
                await _materializeAsset(
                  SlideshowExporter.bundledMusic(musicIndex - 1)!,
                );
            final file = await ref.read(slideshowExporterProvider).export(
                  images: images,
                  aspect: aspect,
                  filter: filter,
                  transition: transition,
                  secondsPerSlide: seconds,
                  audioPath: musicPath,
                  title: opening,
                  endCard: endCard,
                );
            await ref.read(exportHistoryProvider).add('Memory film');
            return ref.read(reelLibraryProvider).keep(
                  source: file,
                  title: title,
                  kind: 'film',
                );
          },
        );
    if (reel == null || !mounted) return;
    final player = VideoPlayerController.file(File(reel.path));
    try {
      await ref.read(nativeEncoderProvider).preparePlayback();
      await player.initialize();
      await player.setLooping(false);
      await player.setVolume(1);
      await player.pause();
    } catch (_) {
      await player.dispose();
      return;
    }
    if (!mounted) {
      await player.dispose();
      return;
    }
    final previous = _player;
    setState(() {
      _player = player;
      _output = reel.path;
    });
    await previous?.dispose();
  }

  static Future<String> _materializeAsset(String asset) async {
    final data = await rootBundle.load(asset);
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, p.basename(asset)));
    await file.writeAsBytes(data.buffer.asUint8List());
    return file.path;
  }
}
