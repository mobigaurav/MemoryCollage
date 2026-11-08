import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/chrome.dart';
import '../../core/theme/tokens.dart';
import '../../providers.dart';
import '../../services/reel_library.dart';
import '../../widgets/brand_hero.dart';
import '../../widgets/film_player.dart';
import '../../widgets/making_note.dart';
import '../shell/app_shell.dart';

/// Shorts-style feed. The reel on screen plays; swipe up for the next one.
class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen>
    with WidgetsBindingObserver {
  final _pages = PageController();
  int _index = 0;
  bool _foreground = true;
  bool _away = false;
  bool _audioReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    shellTab.addListener(_onTab);
    ref.read(nativeEncoderProvider).preparePlayback().whenComplete(() {
      if (mounted) setState(() => _audioReady = true);
    });
  }

  void _onTab() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    if (foreground != _foreground) setState(() => _foreground = foreground);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    shellTab.removeListener(_onTab);
    _pages.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.mbSheet,
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
    if (!mounted || choice == null) return;
    final route = switch (choice) {
      'ai' => '/ai',
      'year' => '/year',
      _ => '/video',
    };
    setState(() => _away = true);
    await context.push(route);
    if (!mounted) return;
    setState(() => _away = false);
    ref.invalidate(reelsProvider);
    _jumpTo(0);
  }

  void _jumpTo(int index) {
    if (!_pages.hasClients) return;
    _pages.jumpToPage(index);
    setState(() => _index = index);
  }

  Future<void> _openGrid(List<ReelRecord> items) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.mbSheet,
      builder: (ctx) => _ReelGrid(items: items),
    );
    if (picked != null && mounted) _jumpTo(picked);
  }

  @override
  Widget build(BuildContext context) {
    final reels = ref.watch(reelsProvider);
    return reels.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: MbTokens.cream)),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (items) {
        if (items.isEmpty) return _EmptyFeed(onCreate: _create);
        final index = _index.clamp(0, items.length - 1);
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PageView.builder(
                controller: _pages,
                scrollDirection: Axis.vertical,
                allowImplicitScrolling: true,
                itemCount: items.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _FeedPage(
                  key: ValueKey('${items[i].id}/${items[i].fileName}'),
                  reel: items[i],
                  active: _audioReady &&
                      shellTab.value == reelsTabIndex &&
                      _foreground &&
                      !_away &&
                      i == index,
                ),
              ),
              _FeedTopBar(
                count: items.length,
                index: index,
                onGrid: () => _openGrid(items),
                onCreate: _create,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeedTopBar extends StatelessWidget {
  const _FeedTopBar({
    required this.count,
    required this.index,
    required this.onGrid,
    required this.onCreate,
  });

  final int count;
  final int index;
  final VoidCallback onGrid;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x99000000), Color(0x00000000)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
            child: Row(
              children: [
                const Text(
                  'Reels',
                  style: TextStyle(
                    fontFamily: MbTokens.serif,
                    fontSize: 30,
                    color: MbTokens.cream,
                    shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${index + 1} of $count',
                  style: const TextStyle(
                    fontFamily: MbTokens.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MbTokens.cream,
                    shadows: [Shadow(color: Color(0xAA000000), blurRadius: 6)],
                  ),
                ),
                const Spacer(),
                const MbMakingNote(onDark: true),
                const SizedBox(width: 8),
                _TopIcon(
                  tooltip: 'All reels',
                  icon: Icons.grid_view_rounded,
                  onPressed: onGrid,
                ),
                const SizedBox(width: 6),
                _TopIcon(
                  tooltip: 'New reel',
                  icon: Icons.add,
                  onPressed: onCreate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF21C1410),
      shape: const CircleBorder(side: BorderSide(color: MbTokens.glassEdge)),
      elevation: 6,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: MbTokens.cream, size: 22),
          ),
        ),
      ),
    );
  }
}

class _FeedPage extends ConsumerStatefulWidget {
  const _FeedPage({super.key, required this.reel, required this.active});

  final ReelRecord reel;
  final bool active;

  @override
  ConsumerState<_FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<_FeedPage> {
  late final VideoPlayerController _controller =
      VideoPlayerController.file(File(widget.reel.path));
  late String _title = widget.reel.title;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) async {
      if (!mounted) return;
      await _controller.setLooping(true);
      await _controller.setVolume(1);
      setState(() => _ready = true);
      _follow();
    }).catchError((_) {});
  }

  @override
  void didUpdateWidget(_FeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _follow();
  }

  void _follow() {
    if (!_ready) return;
    if (widget.active) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _rename() async {
    final field = TextEditingController(text: _title);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.mbSheet,
        title: const Text('Rename reel'),
        content: TextField(
          controller: field,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, field.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    field.dispose();
    final clean = name?.trim() ?? '';
    if (clean.isEmpty || clean == _title || !mounted) return;
    await ref.read(reelLibraryProvider).rename(widget.reel.id, clean);
    if (mounted) setState(() => _title = clean);
    ref.invalidate(reelsProvider);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.mbSheet,
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
    if (confirmed != true || !mounted) return;
    await _controller.pause();
    await ref.read(reelLibraryProvider).remove(widget.reel.id);
    ref.invalidate(reelsProvider);
  }

  Future<void> _edit() async {
    await _controller.pause();
    if (!mounted) return;
    await context.push('/reel/edit?id=${widget.reel.id}');
    if (!mounted) return;
    ref.invalidate(reelsProvider);
    _follow();
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.reel.path);
    return MbFilmPlayer(
      controller: _controller,
      shorts: true,
      autoplay: true,
      actions: [
        MbFilmAction(
          icon: Icons.ios_share,
          label: 'Share',
          onPressed: () => ref.read(exportServiceProvider).shareVideo(
                file,
                title: _title,
              ),
        ),
        MbFilmAction(
          icon: Icons.drive_file_rename_outline,
          label: 'Rename',
          onPressed: _rename,
        ),
        MbFilmAction(
          icon: Icons.download_outlined,
          label: 'Save',
          onPressed: () async {
            await ref.read(exportServiceProvider).saveVideoToGallery(file);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved to camera roll')),
            );
          },
        ),
        MbFilmAction(
          icon: Icons.movie_filter_outlined,
          label: 'Edit',
          onPressed: _edit,
        ),
        MbFilmAction(
          icon: Icons.delete_outline,
          label: 'Delete',
          onPressed: _delete,
        ),
      ],
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MbHero(
              eyebrow: 'Watch',
              title: 'Reels',
              subtitle:
                  'Films and photo clips. They play here one after another. Swipe up for the next.',
              child: FilledButton.icon(
                style: mbInverseButton(),
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('New reel'),
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: MbMakingNote(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Material(
                color: context.mbSurface,
                elevation: 6,
                shadowColor: const Color(0x40301810),
                shape: MbTokens.glassShape(24),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Nothing here yet. Make a memory film in Studio, or bring one photo to life.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReelGrid extends StatelessWidget {
  const _ReelGrid({required this.items});

  final List<ReelRecord> items;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
            child: Row(
              children: [
                Text(
                  'All reels',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.6,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => _ReelTile(
                key: ValueKey('${items[i].id}/${items[i].fileName}'),
                reel: items[i],
                onTap: () => Navigator.pop(context, i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReelTile extends StatefulWidget {
  const _ReelTile({super.key, required this.reel, required this.onTap});

  final ReelRecord reel;
  final VoidCallback onTap;

  @override
  State<_ReelTile> createState() => _ReelTileState();
}

class _ReelTileState extends State<_ReelTile> {
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
      if (mounted) setState(() {});
    }).catchError((_) {});
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
    return Material(
      color: Colors.black,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
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
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: MbTokens.ink.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: MbTokens.glassEdge),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      widget.reel.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MbTokens.cream,
                        fontFamily: MbTokens.sans,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.2,
                      ),
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
