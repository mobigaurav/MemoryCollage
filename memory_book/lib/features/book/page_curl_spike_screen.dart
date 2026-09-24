import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../core/theme/tokens.dart';
import '../../domain/book_models.dart';
import '../../providers.dart';
import '../../services/book_export.dart';
import '../book/page_curl.dart';

/// Isolated spike: two-page spread, haptics, rasterize, 9:16 reel frames.
class PageCurlSpikeScreen extends ConsumerStatefulWidget {
  const PageCurlSpikeScreen({super.key});

  @override
  ConsumerState<PageCurlSpikeScreen> createState() =>
      _PageCurlSpikeScreenState();
}

class _PageCurlSpikeScreenState extends ConsumerState<PageCurlSpikeScreen> {
  final _key = GlobalKey();
  String _status = 'Turn the page, then rasterize.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page-curl spike')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: RepaintBoundary(
                key: _key,
                child: PageCurlSpread(
                  left: const PaperPage(
                    child: ColoredBox(
                      color: MbTokens.paper,
                      child: Center(
                        child: Text(
                          'Left',
                          style: TextStyle(
                            color: MbTokens.ink,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  right: const PaperPage(
                    isLeft: false,
                    child: ColoredBox(
                      color: Color(0xFFE8D9C4),
                      child: Center(
                        child: Text(
                          'Right',
                          style: TextStyle(
                            color: MbTokens.ink,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onTurnForward: () => MbHaptics.pageTurn(),
                  onTurnBack: () {},
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(_status, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _rasterize,
                  child: const Text('Rasterize spread PNG'),
                ),
                FilledButton.tonal(
                  onPressed: _reel,
                  child: const Text('Encode 9:16 flip reel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rasterize() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes =
        await ref.read(exportServiceProvider).encodeStill(
              image: image,
              format: 'PNG',
            );
    final file = await ref.read(exportServiceProvider).writeBytes(bytes, 'png');
    await ref.read(exportServiceProvider).shareFile(file);
    setState(() => _status = 'Wrote ${file.path}');
  }

  Future<void> _reel() async {
    setState(() => _status = 'Painting frames…');
    final painter = BookPainter();
    final cover = await painter.paintCover(
      title: 'Spike',
      theme: BookCoverTheme.leather,
      size: const Size(1080, 1920),
    );
    final spread = await painter.paintSpread(
      left: null,
      right: null,
      theme: BookCoverTheme.leather,
      size: const Size(1080, 1920),
    );
    final frames = <String>[];
    for (final image in [cover, spread]) {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = await ref
          .read(exportServiceProvider)
          .writeBytes(bytes!.buffer.asUint8List(), 'png');
      frames.add(file.path);
    }
    try {
      final out = await ref.read(nativeEncoderProvider).encodeFrames(
            frames: frames,
            outputPath:
                '${frames.first.replaceAll('.png', '')}_reel.mp4',
            width: 1080,
            height: 1920,
            fps: 8,
          );
      setState(() => _status = 'Reel $out');
    } catch (e) {
      setState(() => _status = 'Native encoder: $e');
    }
  }
}
