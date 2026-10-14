import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/tokens.dart';
import '../../data/repositories/album_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../providers.dart';
import '../../services/book_export.dart';
import '../../services/community_api.dart';
import '../../services/export_service.dart';
import '../../services/reel_library.dart';
import '../../widgets/brand_hero.dart';

class WorldScreen extends ConsumerStatefulWidget {
  const WorldScreen({super.key});

  @override
  ConsumerState<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends ConsumerState<WorldScreen> {
  List<CommunityPost> _posts = const [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final posts = await ref.read(communityApiProvider).feed();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _error = null;
        _loading = false;
      });
    } on CommunityException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'The world could not be reached.';
        _loading = false;
      });
    }
  }

  Future<bool> _ensureAccount() async {
    final token = await ref
        .read(settingsRepositoryProvider)
        .get(SettingsRepository.cognitoIdTokenKey);
    if (token != null && token.isNotEmpty) return true;
    if (!mounted) return false;
    await context.push('/account');
    final again = await ref
        .read(settingsRepositoryProvider)
        .get(SettingsRepository.cognitoIdTokenKey);
    return again != null && again.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final signedIn = ref.watch(authSessionProvider).value != null;
    return Scaffold(
      backgroundColor: MbTokens.cream,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            MbHero(
              eyebrow: 'Community',
              title: 'World',
              subtitle: signedIn
                  ? 'Books and reels people chose to share. You can delete yours at any time.'
                  : 'Look around. Sign in when you want to post, love, or ignore.',
              child: FilledButton.icon(
                style: mbInverseButton(),
                onPressed: _choosePost,
                icon: const Icon(Icons.public),
                label: const Text('Post'),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Text(_error!, style: text.bodyLarge)
              else if (_posts.isEmpty)
                const Text(
                  'Nothing here yet. Post a book or a reel from this phone.',
                  style: TextStyle(
                    fontFamily: MbTokens.sans,
                    fontSize: 17,
                    height: 1.4,
                    color: MbTokens.ink,
                  ),
                )
              else
                for (final post in _posts) ...[
                  _PostCard(
                    post: post,
                    onLove: () => _love(post),
                    onIgnore: () => _ignore(post),
                    onDelete: () => _delete(post),
                  ),
                  const SizedBox(height: 16),
                ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _choosePost() async {
    if (!await _ensureAccount() || !mounted) return;
    final kind = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Share with the world',
                style: TextStyle(
                  fontFamily: MbTokens.serif,
                  fontSize: 24,
                  color: MbTokens.ink,
                ),
              ),
            ),
            ListTile(
              title: const Text('A book'),
              subtitle: const Text('Cover and pages. The first 12 pictures.'),
              onTap: () => Navigator.pop(ctx, 'album'),
            ),
            ListTile(
              title: const Text('A reel'),
              subtitle: const Text('A film or clip already on this phone.'),
              onTap: () => Navigator.pop(ctx, 'reel'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || kind == null) return;
    if (kind == 'album') {
      await _postBook();
    } else {
      await _postReel();
    }
  }

  Future<void> _postBook() async {
    final albums = await ref.read(albumRepositoryProvider).watchAll().first;
    if (!mounted) return;
    if (albums.isEmpty) {
      _toast('Make a book on the shelf first.');
      return;
    }
    final albumId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final item in albums)
              ListTile(
                title: Text(item.title),
                onTap: () => Navigator.pop(ctx, item.id),
              ),
          ],
        ),
      ),
    );
    if (albumId == null || !mounted) return;
    final detail = await ref.read(albumRepositoryProvider).getDetail(albumId);
    if (detail == null || !mounted) return;
    var shortened = false;
    final sent = await _sending('Sending this book', () async {
      final rendered = await _albumPages(detail);
      shortened = rendered.truncated;
      final api = ref.read(communityApiProvider);
      final uploads = await api.begin(
        title: detail.album.title,
        kind: 'album',
        count: rendered.pages.length,
      );
      for (var i = 0; i < uploads.length && i < rendered.pages.length; i++) {
        await api.putFile(uploads[i], rendered.pages[i]);
      }
      await api.publish(
        uploads.first.key.split('/')[1],
        [for (final item in uploads) item.key],
      );
    });
    if (sent && shortened) {
      _toast('The first 12 pages are in the world.');
    }
  }

  Future<void> _postReel() async {
    final reels = await ref.read(reelLibraryProvider).load();
    if (!mounted) return;
    if (reels.isEmpty) {
      _toast('Make a reel first.');
      return;
    }
    final reel = await showModalBottomSheet<ReelRecord>(
      context: context,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final item in reels)
              ListTile(
                title: Text(item.title),
                onTap: () => Navigator.pop(ctx, item),
              ),
          ],
        ),
      ),
    );
    if (reel == null || !mounted) return;
    await _sending('Sending this reel', () async {
      final bytes = await File(reel.path).readAsBytes();
      final api = ref.read(communityApiProvider);
      final uploads = await api.begin(title: reel.title, kind: 'reel', count: 1);
      await api.putFile(uploads.first, bytes);
      await api.publish(uploads.first.key.split('/')[1], [uploads.first.key]);
    });
  }

  Future<bool> _sending(String label, Future<void> Function() work) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: MbTokens.cream,
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
    try {
      await work();
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      await _load();
      if (mounted) _toast('It is in the world. You can delete it whenever you want.');
      return true;
    } on CommunityException catch (error) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (mounted) _toast(error.message);
    } catch (error) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (mounted) _toast('Could not post this: $error');
    }
    return false;
  }

  Future<void> _love(CommunityPost post) async {
    if (!await _ensureAccount()) return;
    try {
      final result = await ref.read(communityApiProvider).love(post.id);
      if (!mounted) return;
      setState(() {
        _posts = [
          for (final item in _posts)
            if (item.id == post.id)
              item.copyWith(loved: result.loved, loves: result.loves)
            else
              item,
        ];
      });
    } on CommunityException catch (error) {
      _toast(error.message);
    }
  }

  Future<void> _ignore(CommunityPost post) async {
    if (!await _ensureAccount()) return;
    try {
      await ref.read(communityApiProvider).ignore(post.id);
      if (!mounted) return;
      setState(() => _posts = _posts.where((item) => item.id != post.id).toList());
      _toast('Hidden for you. It is still up for everyone else.');
    } on CommunityException catch (error) {
      _toast(error.message);
    }
  }

  Future<void> _delete(CommunityPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MbTokens.cream,
        title: const Text('Delete this from the world?'),
        content: const Text('It leaves for everyone. The copy on this phone stays.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(communityApiProvider).delete(post.id);
      if (!mounted) return;
      setState(() => _posts = _posts.where((item) => item.id != post.id).toList());
    } on CommunityException catch (error) {
      _toast(error.message);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _RenderedAlbum {
  const _RenderedAlbum(this.pages, this.truncated);
  final List<Uint8List> pages;
  final bool truncated;
}

Future<_RenderedAlbum> _albumPages(AlbumDetail detail) async {
  final painter = BookPainter();
  final export = ExportService(NativeVideoEncoder());
  final pages = <Uint8List>[];
  var truncated = false;

  Future<void> add(ui.Image image) async {
    if (pages.length >= 12) {
      truncated = true;
      image.dispose();
      return;
    }
    pages.add(await export.encodeStill(image: image, format: 'JPEG'));
    image.dispose();
  }

  await add(
    await painter.paintCover(
      title: detail.album.title,
      theme: detail.theme,
      coverPath: detail.album.coverPhotoPath,
      size: const Size(900, 1200),
    ),
  );
  for (var i = 0; i < detail.spreadCount; i++) {
    if (pages.length >= 12) {
      truncated = true;
      break;
    }
    final left = i * 2 < detail.pages.length ? detail.pages[i * 2] : null;
    final right = i * 2 + 1 < detail.pages.length ? detail.pages[i * 2 + 1] : null;
    await add(
      await painter.paintSpread(
        left: left,
        right: right,
        theme: detail.theme,
        size: const Size(1200, 840),
      ),
    );
  }
  if (pages.isEmpty) {
    throw CommunityException('This book has no pages to share.');
  }
  return _RenderedAlbum(pages, truncated);
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onLove,
    required this.onIgnore,
    required this.onDelete,
  });

  final CommunityPost post;
  final VoidCallback onLove;
  final VoidCallback onIgnore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.kind == 'reel')
            _ReelFace(url: post.media.isEmpty ? '' : post.media.first, title: post.title)
          else
            SizedBox(
              height: 280,
              child: PageView(
                children: [
                  for (final url in post.media)
                    Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: MbTokens.paper,
                        child: Center(child: Text('Page unavailable')),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  post.author,
                  style: const TextStyle(
                    fontFamily: MbTokens.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MbTokens.inkSoft,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: post.loved ? 'Loved' : 'Love',
                      onPressed: onLove,
                      icon: Icon(
                        post.loved ? Icons.favorite : Icons.favorite_border,
                        color: post.loved ? MbTokens.oxblood : MbTokens.ink,
                      ),
                    ),
                    Text(
                      '${post.loves}',
                      style: const TextStyle(
                        fontFamily: MbTokens.sans,
                        fontWeight: FontWeight.w700,
                        color: MbTokens.ink,
                      ),
                    ),
                    const Spacer(),
                    TextButton(onPressed: onIgnore, child: const Text('Ignore')),
                    if (post.mine)
                      TextButton(onPressed: onDelete, child: const Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReelFace extends StatelessWidget {
  const _ReelFace({required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: MbTokens.film,
        child: InkWell(
          onTap: url.isEmpty
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _WorldPlayer(url: url, title: title),
                    ),
                  );
                },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill, color: Colors.white, size: 56),
              SizedBox(height: 8),
              Text(
                'Play',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: MbTokens.sans,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldPlayer extends StatefulWidget {
  const _WorldPlayer({required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<_WorldPlayer> createState() => _WorldPlayerState();
}

class _WorldPlayerState extends State<_WorldPlayer> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller.initialize().then((_) async {
      if (!mounted) return;
      setState(() {});
      await _controller.play();
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio == 0
                    ? 9 / 16
                    : _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
