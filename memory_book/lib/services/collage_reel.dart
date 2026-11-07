import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/collage_craft.dart';
import '../domain/collage_paper.dart';
import '../domain/collage_templates.dart';
import '../domain/media_options.dart';
import 'collage_renderer.dart';
import 'export_service.dart';
import 'slideshow_exporter.dart';

/// Turns a finished collage into a short film: photos land one by one, then the stickers and words.
class CollageReel {
  CollageReel(this.exporter, this.slides);

  final ExportService exporter;
  final SlideshowExporter slides;

  Future<File> make({
    required CollageTemplate template,
    required List<PlacedPhoto?> photos,
    required Color background,
    required List<PlacedSticker> stickers,
    required List<CollageTextOverlay> texts,
    List<PlacedInk> inks = const [],
    List<PlacedVoice> voices = const [],
    CollagePaper paper = CollagePaper.plain,
    int musicIndex = 0,
  }) async {
    final filled = [
      for (var i = 0; i < photos.length; i++)
        if (photos[i] != null) i,
    ];
    if (filled.isEmpty) throw StateError('Add a photo first');
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final frames = <String>[];

    Future<void> frame(int shown, {required bool finished}) async {
      final visible = filled.take(shown).toSet();
      final image = await CollageRenderer().render(
        CollageRenderRequest(
          template: template,
          imagePaths: [
            for (var i = 0; i < photos.length; i++)
              visible.contains(i) ? photos[i]!.path : '',
          ],
          placedPhotos: [
            for (final photo in photos) photo ?? PlacedPhoto(path: ''),
          ],
          background: background,
          paper: paper,
          stickers: finished ? stickers : const [],
          texts: finished ? texts : const [],
          inks: finished ? inks : const [],
          voices: finished ? voices : const [],
          size: const Size(1080, 1080),
        ),
      );
      final bytes = await exporter.encodeStill(image: image, format: 'JPEG');
      image.dispose();
      final file = File(p.join(dir.path, 'collage-reel-$stamp-${frames.length}.jpg'));
      await file.writeAsBytes(bytes);
      frames.add(file.path);
    }

    for (var shown = 1; shown <= filled.length; shown++) {
      await frame(shown, finished: false);
    }
    await frame(filled.length, finished: true);
    final last = frames.last;
    frames.addAll([last, last]);

    return slides.export(
      images: frames,
      aspect: VideoAspect.square,
      filter: PhotoFilterId.none,
      transition: VideoTransitionId.crossfade,
      secondsPerSlide: filled.length > 8 ? 0.8 : 1.1,
      audioPath: await SlideshowExporter.bundledMusicFile(musicIndex),
    );
  }
}
