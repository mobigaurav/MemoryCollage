import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class NativeVideoEncoder {
  static const _channel = MethodChannel('memory_book/video_encoder');

  Future<void> preparePlayback() async {
    try {
      await _channel.invokeMethod<void>('preparePlayback');
    } catch (_) {}
  }

  Future<String> mixAudio({
    required String videoPath,
    required String audioPath,
  }) async {
    final result = await _channel.invokeMethod<String>('mixAudio', {
      'videoPath': videoPath,
      'audioPath': audioPath,
    });
    return result ?? videoPath;
  }

  Future<String> encodeSlideshow({
    required List<String> images,
    required String outputPath,
    required int width,
    required int height,
    required double secondsPerSlide,
    required String transition,
    String? audioPath,
    String filter = 'none',
  }) async {
    final result = await _channel.invokeMethod<String>('encodeSlideshow', {
      'images': images,
      'outputPath': outputPath,
      'width': width,
      'height': height,
      'secondsPerSlide': secondsPerSlide,
      'transition': transition,
      'audioPath': audioPath,
      'filter': filter,
    });
    if (result == null) {
      throw StateError('Native encoder returned nothing');
    }
    return result;
  }

  Future<String> encodeFrames({
    required List<String> frames,
    required String outputPath,
    required int width,
    required int height,
    required int fps,
    String? audioPath,
  }) async {
    final result = await _channel.invokeMethod<String>('encodeFrames', {
      'frames': frames,
      'outputPath': outputPath,
      'width': width,
      'height': height,
      'fps': fps,
      'audioPath': audioPath,
    });
    if (result == null) {
      throw StateError('Native encoder returned nothing');
    }
    return result;
  }

  Future<String> editClip({
    required List<Map<String, Object>> clips,
    required String outputPath,
    required String aspect,
    required bool mute,
  }) async {
    final result = await _channel.invokeMethod<String>('editClip', {
      'clips': clips,
      'outputPath': outputPath,
      'aspect': aspect,
      'mute': mute,
    });
    if (result == null || result.isEmpty) {
      throw StateError('The edit did not produce a video.');
    }
    return result;
  }

  Future<Uint8List> posterFrame({
    required String path,
    required int atMs,
  }) async {
    final result = await _channel.invokeMethod<Uint8List>('posterFrame', {
      'path': path,
      'atMs': atMs,
    });
    if (result == null || result.isEmpty) {
      throw StateError('Could not read a frame from this reel.');
    }
    return result;
  }

  Future<Uint8List> encodeHeic(Uint8List jpegOrPng) async {
    final result = await _channel.invokeMethod<Uint8List>('encodeHeic', {
      'bytes': jpegOrPng,
    });
    return result ?? jpegOrPng;
  }
}

class ExportService {
  ExportService(this.encoder);
  final NativeVideoEncoder encoder;
  final _uuid = const Uuid();

  Future<Directory> _tmp() async {
    final dir = Directory(
      p.join((await getTemporaryDirectory()).path, 'mb_export'),
    );
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> writeBytes(Uint8List bytes, String ext) async {
    final file = File(p.join((await _tmp()).path, '${_uuid.v4()}.$ext'));
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> saveImageToGallery(File file) async {
    await Gal.putImage(file.path);
  }

  Future<void> saveVideoToGallery(File file) async {
    final allowed = await Gal.requestAccess();
    if (!allowed) {
      throw StateError('Allow photo library access to save this reel.');
    }
    await Gal.putVideo(file.path);
  }

  Future<void> shareFile(
    File file, {
    String? mimeType,
    String? name,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(file.path, mimeType: mimeType, name: name),
        ],
      ),
    );
  }

  /// A video file only. Extra caption text makes iOS offer it as a document.
  Future<void> shareVideo(File file, {String? title}) async {
    final named = await _namedCopy(file, title ?? 'Memory Book reel', 'mp4');
    final name = p.basename(named.path);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(named.path, mimeType: 'video/mp4', name: name),
        ],
      ),
    );
  }

  Future<File> _namedCopy(File file, String title, String ext) async {
    final safe = title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
    final base = safe.isEmpty ? 'Memory Book reel' : safe;
    final dest = File(p.join((await _tmp()).path, '$base.$ext'));
    if (file.absolute.path == dest.absolute.path) return file;
    if (await dest.exists()) await dest.delete();
    return file.copy(dest.path);
  }

  Future<Uint8List> encodeStill({
    required ui.Image image,
    required String format,
    bool watermark = false,
  }) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to rasterize');
    }
    var raw = byteData.buffer.asUint8List();
    if (watermark) {
      raw = _stampWatermark(raw);
    }
    switch (format.toUpperCase()) {
      case 'PNG':
        return raw;
      case 'HEIC':
        final jpg = _toJpg(raw);
        try {
          return await encoder.encodeHeic(jpg);
        } catch (_) {
          return jpg;
        }
      default:
        return _toJpg(raw);
    }
  }

  Uint8List _toJpg(Uint8List png) {
    final decoded = img.decodeImage(png);
    if (decoded == null) return png;
    return Uint8List.fromList(img.encodeJpg(decoded, quality: 92));
  }

  Uint8List _stampWatermark(Uint8List png) {
    final decoded = img.decodeImage(png);
    if (decoded == null) return png;
    img.drawString(
      decoded,
      'Memory Book',
      font: img.arial24,
      x: decoded.width - 220,
      y: decoded.height - 48,
      color: img.ColorRgba8(255, 255, 255, 180),
    );
    return Uint8List.fromList(img.encodePng(decoded));
  }
}
