import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/theme/tokens.dart';
import '../../domain/media_options.dart';
import '../../providers.dart';
import '../../services/photo_service.dart';
import '../../services/reel_jobs.dart';
import '../../services/slideshow_exporter.dart';
import '../collage/collage_studio_screen.dart';

/// Photos from this date in earlier years. One tap makes a collage or a reel.
class OnThisDayCard extends ConsumerStatefulWidget {
  const OnThisDayCard({super.key});

  @override
  ConsumerState<OnThisDayCard> createState() => _OnThisDayCardState();
}

class _OnThisDayCardState extends ConsumerState<OnThisDayCard> {
  bool _working = false;

  String get _today => DateFormat.MMMMd().format(DateTime.now());

  Future<void> _allow() async {
    final ok = await ref.read(photoServiceProvider).askLibraryAccess();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memory Book needs photo access in Settings to find this day.'),
        ),
      );
      return;
    }
    ref.invalidate(onThisDayProvider);
  }

  Future<void> _collage(OnThisDay day) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      final paths = await ref.read(photoServiceProvider).keepAssets(day.pick(9));
      if (!mounted || paths.isEmpty) return;
      await context.push(
        '/collage',
        extra: CollageSeed(photos: paths, caption: 'On this day'),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _reel(OnThisDay day) {
    final picked = day.pick(20);
    final title = 'On this day · $_today';
    final music = DateTime.now().day % SlideshowExporter.musicNames.length;
    unawaited(
      ref.read(reelJobsProvider.notifier).run(
            label: title,
            failure: 'The On this day reel did not finish',
            work: (ref) async {
              final paths = await ref.read(photoServiceProvider).keepAssets(picked);
              if (paths.isEmpty) throw StateError('No photos could be read');
              final file = await ref.read(slideshowExporterProvider).export(
                    images: paths,
                    aspect: VideoAspect.reel,
                    filter: PhotoFilterId.none,
                    transition: VideoTransitionId.zoom,
                    secondsPerSlide: 2.2,
                    audioPath: await SlideshowExporter.bundledMusicFile(music),
                    title: 'On this day',
                    endCard: _today,
                  );
              return ref.read(reelLibraryProvider).keep(
                    source: file,
                    title: title,
                    kind: 'memory',
                  );
            },
          ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Making your On this day reel. It shows up on Reels. Keep going.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(onThisDayProvider);
    return Material(
      color: MbTokens.glass,
      elevation: 8,
      shadowColor: const Color(0x40301810),
      shape: MbTokens.glassShape(MbTokens.radiusLg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: memories.when(
          loading: () => _frame(
            subtitle: 'Looking through earlier years…',
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, _) => _frame(subtitle: 'Could not read the library: $e'),
          data: (day) {
            if (day == null) {
              return _frame(
                subtitle:
                    'See what you photographed on $_today in earlier years. The photos stay on this phone.',
                actions: [
                  FilledButton.icon(
                    onPressed: _allow,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Show my memories'),
                  ),
                ],
              );
            }
            if (day.years.isEmpty) {
              return _frame(
                subtitle: 'Nothing from this week in earlier years. Check back tomorrow.',
              );
            }
            final span = day.years.length == 1
                ? '${day.years.first.year}'
                : '${day.years.last.year}–${day.years.first.year}';
            return _frame(
              subtitle: day.widened
                  ? '${day.count} photos from this week in $span'
                  : '${day.count} photos from $_today in $span',
              child: _Strip(day: day),
              actions: [
                FilledButton.icon(
                  onPressed: _working ? null : () => _collage(day),
                  icon: const Icon(Icons.grid_view_rounded),
                  label: Text(_working ? 'Gathering…' : 'Collage'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _reel(day),
                  icon: const Icon(Icons.movie_creation_outlined),
                  label: const Text('Reel'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _frame({
    required String subtitle,
    Widget? child,
    List<Widget> actions = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_rounded, color: MbTokens.leather),
            const SizedBox(width: 8),
            Text(
              'ON THIS DAY',
              style: const TextStyle(
                fontFamily: MbTokens.sans,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: MbTokens.leather,
              ),
            ),
            const Spacer(),
            Text(
              _today,
              style: const TextStyle(
                fontFamily: MbTokens.serif,
                fontSize: 20,
                color: MbTokens.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
        if (child != null) ...[const SizedBox(height: 12), child],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 8, children: actions),
        ],
      ],
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip({required this.day});

  final OnThisDay day;

  @override
  Widget build(BuildContext context) {
    final tiles = <(int, AssetEntity)>[
      for (final year in day.years)
        for (final asset in year.assets.take(4)) (year.year, asset),
    ];
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (year, asset) = tiles[i];
          final firstOfYear = i == 0 || tiles[i - 1].$1 != year;
          return _Thumb(asset: asset, year: firstOfYear ? year : null);
        },
      ),
    );
  }
}

class _Thumb extends StatefulWidget {
  const _Thumb({required this.asset, this.year});

  final AssetEntity asset;
  final int? year;

  @override
  State<_Thumb> createState() => _ThumbState();
}

class _ThumbState extends State<_Thumb> {
  late final Future<Uint8List?> _bytes =
      widget.asset.thumbnailDataWithSize(const ThumbnailSize.square(240));

  @override
  Widget build(BuildContext context) {
    final year = widget.year;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 88,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<Uint8List?>(
              future: _bytes,
              builder: (context, snap) {
                final data = snap.data;
                if (data == null) return const ColoredBox(color: MbTokens.paperDeep);
                return Image.memory(data, fit: BoxFit.cover, gaplessPlayback: true);
              },
            ),
            if (year != null)
              Positioned(
                left: 6,
                bottom: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: MbTokens.ink.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      '$year',
                      style: const TextStyle(
                        color: MbTokens.cream,
                        fontFamily: MbTokens.sans,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}