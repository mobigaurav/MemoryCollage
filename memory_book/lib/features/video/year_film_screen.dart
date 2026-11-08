import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/chrome.dart';
import '../../core/theme/tokens.dart';
import '../../domain/media_options.dart';
import '../../domain/year_film.dart';
import '../../providers.dart';
import '../../services/reel_jobs.dart';
import '../../widgets/brand_hero.dart';
import '../../widgets/film_player.dart';

class YearFilmScreen extends ConsumerStatefulWidget {
  const YearFilmScreen({super.key});

  @override
  ConsumerState<YearFilmScreen> createState() => _YearFilmScreenState();
}

class _YearFilmScreenState extends ConsumerState<YearFilmScreen> {
  String? _progress;
  String? _note;
  String? _title;
  File? _film;
  VideoPlayerController? _player;
  bool _watching = false;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _make() async {
    if (_progress != null) return;
    setState(() {
      _progress = 'Looking through this year';
      _note = null;
    });
    try {
      var year = DateTime.now().year;
      final photos = ref.read(photoServiceProvider);
      var frames = await photos.photosFromYear(year);
      if (frames.length < 4) {
        setState(() => _progress = 'Looking through last year');
        year -= 1;
        frames = await photos.photosFromYear(year);
      }
      if (frames.length < 4) {
        setState(() {
          _progress = null;
          _note = 'Not enough dated photos yet. A year film needs at least four.';
        });
        return;
      }
      final chosen = takeEvenly(frames, 24);
      setState(() {
        _progress = null;
        _note = 'Filming $year in the background. It shows up on Reels. You can leave this screen.';
      });
      final reel = await ref.read(reelJobsProvider.notifier).run(
            label: '$year',
            failure: 'Could not film this year',
            work: (ref) async {
              final file = await ref.read(slideshowExporterProvider).export(
                    images: chosen,
                    aspect: VideoAspect.reel,
                    filter: PhotoFilterId.none,
                    transition: VideoTransitionId.crossfade,
                    secondsPerSlide: 2.5,
                    title: '$year',
                    endCard: 'Memory Book',
                  );
              return ref.read(reelLibraryProvider).keep(
                    source: file,
                    title: '$year',
                    kind: 'film',
                  );
            },
          );
      if (reel == null || !mounted) return;
      final file = File(reel.path);
      await ref.read(nativeEncoderProvider).preparePlayback();
      final player = VideoPlayerController.file(file);
      await player.initialize();
      await player.setLooping(false);
      await player.pause();
      if (!mounted) {
        await player.dispose();
        return;
      }
      await _player?.dispose();
      setState(() {
        _progress = null;
        _title = reel.title;
        _film = file;
        _player = player;
        _note = 'Saved on Reels.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _note = 'Could not film this year: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = _player;
    if (_watching && player != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: MbFilmPlayer(
          controller: player,
          shorts: true,
          title: _title ?? 'This year',
          onClose: () => setState(() => _watching = false),
          actions: [
            MbFilmAction(
              icon: Icons.ios_share,
              label: 'Share',
              onPressed: _film == null
                  ? null
                  : () => ref.read(exportServiceProvider).shareVideo(
                        _film!,
                        title: _title ?? 'Year film',
                      ),
            ),
            MbFilmAction(
              icon: Icons.download_outlined,
              label: 'Save',
              onPressed: _film == null
                  ? null
                  : () async {
                      await ref.read(exportServiceProvider).saveVideoToGallery(_film!);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to camera roll')),
                      );
                    },
            ),
            MbFilmAction(
              icon: Icons.video_library_outlined,
              label: 'Reels',
              onPressed: () => context.go('/reels'),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          MbHero(
            onBack: () => mbPop(context),
            eyebrow: 'On this phone',
            title: 'This year',
            subtitle:
                'Photos in the order the camera kept them. The phone makes the film. Nothing is uploaded, and it does not spend a credit.',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                FilledButton(
                  onPressed: _progress == null ? _make : null,
                  child: Text(_progress ?? "Make this year's film"),
                ),
                if (_note != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _note!,
                    style: TextStyle(
                      fontFamily: MbTokens.sans,
                      fontSize: 16,
                      height: 1.4,
                      color: context.mbInk,
                    ),
                  ),
                ],
                if (player != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _watching = true),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(_title == null ? 'Watch' : 'Watch $_title'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
