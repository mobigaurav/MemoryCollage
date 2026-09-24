import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/media_options.dart';
import 'export_service.dart';

class SlideshowExporter {
  SlideshowExporter(this.encoder);
  final NativeVideoEncoder encoder;
  final _uuid = const Uuid();

  Future<File> export({
    required List<String> images,
    required VideoAspect aspect,
    required PhotoFilterId filter,
    required VideoTransitionId transition,
    required double secondsPerSlide,
    String? audioPath,
    String? title,
    String? endCard,
  }) async {
    final size = switch (aspect) {
      VideoAspect.reel => (1080, 1920),
      VideoAspect.square => (1080, 1080),
      VideoAspect.landscape => (1920, 1080),
    };
    final tmp = await getTemporaryDirectory();
    final out = p.join(tmp.path, 'slide_${_uuid.v4()}.mp4');
    final frames = [...images];
    if (title != null && title.trim().isNotEmpty) {
      frames.insert(0, await _card(title.trim(), size.$1, size.$2, tmp.path));
    }
    if (endCard != null && endCard.trim().isNotEmpty) {
      frames.add(await _card(endCard.trim(), size.$1, size.$2, tmp.path));
    }
    await encoder.encodeSlideshow(
      images: frames,
      outputPath: out,
      width: size.$1,
      height: size.$2,
      secondsPerSlide: secondsPerSlide,
      transition: transition.name,
      audioPath: audioPath,
      filter: filter.name,
    );
    return File(out);
  }

  Future<String> _card(String text, int width, int height, String dir) async {
    final canvas = img.Image(width: width, height: height);
    img.fill(canvas, color: img.ColorRgb8(42, 24, 16));
    img.drawString(
      canvas,
      text,
      font: img.arial48,
      x: 80,
      y: height ~/ 2 - 24,
      color: img.ColorRgb8(196, 163, 90),
    );
    final file = File(p.join(dir, 'card_${_uuid.v4()}.jpg'));
    await file.writeAsBytes(img.encodeJpg(canvas, quality: 90));
    return file.path;
  }

  static String? bundledMusic(int index) {
    final n = (index % 11) + 1;
    return 'assets/audio/$n.mp3';
  }
}
