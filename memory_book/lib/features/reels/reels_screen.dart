import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/tokens.dart';
import '../../providers.dart';
import '../../services/reel_library.dart';
import '../../widgets/brand_hero.dart';
import '../../widgets/film_player.dart';

class ReelsScreen extends ConsumerWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reels = ref.watch(reelsProvider);
    return Scaffold(
      backgroundColor: MbTokens.cream,
      body: reels.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (items) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: MbHero(
                  eyebrow: 'Watch',
                  title: 'Reels',
                  subtitle:
                      'Films and photo clips. Tap a frame to watch. Share hands the video to Instagram or Facebook.',
                  child: FilledButton.icon(
                    style: mbInverseButton(),
                    onPressed: () => _create(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('New reel'),
                  ),
                ),
              ),
              if (items.isEmpty)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(child: _EmptyReels()),
                ),
              if (items.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.48,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ReelTile(reel: items[i]),
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          ),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'New reel',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.movie_creation_outlined),
                title: const Text('Memory film'),
                subtitle: const Text(
                  'Stills, music, and titles. Made on this phone.',
                ),
                onTap: () => Navigator.pop(ctx, 'film'),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('This year'),
                subtitle: const Text(
                  'Dated photos, filmed on this phone. No upload and no credit.',
                ),
                onTap: () => Navigator.pop(ctx, 'year'),
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Bring a photo to life'),
                subtitle: const Text(
                  '1 Memory Book credit. A 5-second photo clip uses about 25 Runway credits.',
                ),
                onTap: () => Navigator.pop(ctx, 'ai'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!context.mounted || choice == null) return;
    final route = switch (choice) {
      'ai' => '/ai',
      'year' => '/year',
      _ => '/video',
    };
    await context.push(route);
    if (context.mounted) ref.invalidate(reelsProvider);
  }
}

class _EmptyReels extends StatelessWidget {
  const _EmptyReels();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          'Nothing here yet. Make a memory film in Studio, or bring one photo to life.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _ReelTile extends ConsumerStatefulWidget {
  const _ReelTile({required this.reel});
  final ReelRecord reel;

  @override
  ConsumerState<_ReelTile> createState() => _ReelTileState();
}

class _ReelTileState extends ConsumerState<_ReelTile> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final file = File(widget.reel.path);
    if (!file.existsSync()) return;
    final controller = VideoPlayerController.file(file);
    _controller = controller;
    controller.initialize().then((_) async {
      if (!mounted) return;
      await controller.setVolume(0);
      await controller.seekTo(const Duration(milliseconds: 400));
      await controller.pause();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Material(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _open(context),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (ready)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 28, 10, 10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xCC000000)],
                        ),
                      ),
                      child: Text(
                        widget.reel.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: MbTokens.sans,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.push('/reel/edit?id=${widget.reel.id}'),
            icon: const Icon(Icons.movie_filter_outlined, size: 18),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _FrameButton(
                icon: Icons.ios_share,
                label: 'Share',
                onPressed: () => _share(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FrameButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                onPressed: () => _delete(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _open(BuildContext context) async {
    final file = File(widget.reel.path);
    if (!file.existsSync()) return;
    await ref.read(nativeEncoderProvider).preparePlayback();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ReelStage(reel: widget.reel, file: file),
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    final file = File(widget.reel.path);
    if (!file.existsSync()) return;
    await ref.read(exportServiceProvider).shareVideo(file, title: widget.reel.title);
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MbTokens.cream,
        title: const Text('Delete this reel?'),
        content: const Text('It leaves this phone. A copy you already shared stays where you sent it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(reelLibraryProvider).remove(widget.reel.id);
    ref.invalidate(reelsProvider);
  }
}

class _FrameButton extends StatelessWidget {
  const _FrameButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        foregroundColor: MbTokens.ink,
        side: const BorderSide(color: MbTokens.leather),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _ReelStage extends ConsumerStatefulWidget {
  const _ReelStage({required this.reel, required this.file});
  final ReelRecord reel;
  final File file;

  @override
  ConsumerState<_ReelStage> createState() => _ReelStageState();
}

class _ReelStageState extends ConsumerState<_ReelStage> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file);
    _controller.initialize().then((_) async {
      if (!mounted) return;
      await _controller.setVolume(1);
      await _controller.setLooping(false);
      await _controller.pause();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  MbFilmPlayer(controller: _controller, onDark: true),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  Text(
                    widget.reel.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: MbTokens.sans,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.push('/reel/edit?id=${widget.reel.id}'),
                      icon: const Icon(Icons.movie_filter_outlined),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => ref
                              .read(exportServiceProvider)
                              .shareVideo(widget.file, title: widget.reel.title),
                          icon: const Icon(Icons.ios_share),
                          label: const Text('Share'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                          ),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: MbTokens.cream,
                                title: const Text('Delete this reel?'),
                                content: const Text(
                                  'It leaves this phone. A copy you already shared stays where you sent it.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Keep'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFFC62828),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed != true) return;
                            await ref.read(reelLibraryProvider).remove(widget.reel.id);
                            ref.invalidate(reelsProvider);
                            if (context.mounted) Navigator.pop(context);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
