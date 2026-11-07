import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/tokens.dart';
import '../../domain/media_options.dart';
import '../../domain/year_film.dart';
import '../../providers.dart';
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
  VideoPlayerController? _player;

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
      setState(() => _progress = 'Filming $year on this phone');
      final file = await ref.read(slideshowExporterProvider).export(
            images: chosen,
            aspect: VideoAspect.reel,
            filter: PhotoFilterId.none,
            transition: VideoTransitionId.crossfade,
            secondsPerSlide: 2.5,
            title: '$year',
            endCard: 'Memory Book',
          );
      await ref.read(reelLibraryProvider).keep(
            source: file,
            title: '$year',
            kind: 'film',
          );
      ref.invalidate(reelsProvider);
      await ref.read(nativeEncoderProvider).preparePlayback();
      final player = VideoPlayerController.file(File(file.path));
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
        _title = '$year';
        _player = player;
        _note = 'Saved on Reels. Press play when you want it.';
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
    return Scaffold(
      backgroundColor: MbTokens.cream,
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
                    style: const TextStyle(
                      fontFamily: MbTokens.sans,
                      fontSize: 16,
                      height: 1.4,
                      color: MbTokens.ink,
                    ),
                  ),
                ],
                if (_player != null) ...[
                  const SizedBox(height: 16),
                  MbFilmPlayer(controller: _player!),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go('/reels'),
                    child: Text(_title == null ? 'Open Reels' : 'Open $_title in Reels'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
