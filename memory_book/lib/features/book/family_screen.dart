import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../../core/theme/tokens.dart';
import '../../domain/book_models.dart';
import '../../domain/book_ops.dart';
import '../../providers.dart';
import '../../services/household_api.dart';
import '../../services/photo_files.dart';
import '../../widgets/brand_hero.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key, this.albumId, this.albumTitle});

  final String? albumId;
  final String? albumTitle;

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  final _code = TextEditingController();
  List<HouseholdBook> _books = const [];
  HouseholdBook? _open;
  String? _error;
  String? _progress;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final session = ref.read(authSessionProvider).value;
    if (session == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final books = await ref.read(householdApiProvider).list();
      HouseholdBook? linked;
      final albumId = widget.albumId;
      if (albumId != null) {
        final code = await ref
            .read(settingsRepositoryProvider)
            .get('album-household:$albumId');
        if (code != null && code.isNotEmpty) {
          linked = await ref.read(householdApiProvider).read(code);
        }
      }
      if (!mounted) return;
      setState(() {
        _books = books;
        _open = linked;
        _loading = false;
        _error = null;
      });
    } on HouseholdException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  Future<void> _start() async {
    final title = (widget.albumTitle ?? '').trim().isEmpty
        ? 'Our book'
        : widget.albumTitle!.trim();
    setState(() => _progress = 'Starting the family book');
    try {
      final book = await ref.read(householdApiProvider).create(title);
      await _remember(book);
      if (!mounted) return;
      setState(() {
        _open = book;
        _progress = null;
        _error = null;
      });
    } on HouseholdException catch (e) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _error = e.message;
      });
    }
  }

  Future<void> _join() async {
    final code = _code.text.trim();
    if (code.length < 4) {
      setState(() => _error = 'Enter the code from the person who started the book.');
      return;
    }
    setState(() => _progress = 'Joining');
    try {
      final book = await ref.read(householdApiProvider).join(code);
      await _remember(book);
      if (!mounted) return;
      setState(() {
        _open = book;
        _progress = null;
        _error = null;
      });
    } on HouseholdException catch (e) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _error = e.message;
      });
    }
  }

  Future<void> _remember(HouseholdBook book) async {
    final albumId = widget.albumId;
    if (albumId == null) return;
    final settings = ref.read(settingsRepositoryProvider);
    await settings.set('album-household:$albumId', book.code);
    await settings.set('household-album:${book.code}', albumId);
  }

  Future<void> _invite(HouseholdBook book) async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Join our book in Memory Book. The code is ${book.code}. Only people with the code can add photos.',
      ),
    );
  }

  Future<void> _addPhotos(HouseholdBook book) async {
    final paths = await ref.read(photoServiceProvider).pickImages(limit: 12);
    if (paths.isEmpty) return;
    setState(() => _progress = 'Sending ${paths.length} photos');
    try {
      final api = ref.read(householdApiProvider);
      final uploads = await api.reserve(book.code, paths.length);
      final keys = <String>[];
      for (var i = 0; i < paths.length && i < uploads.length; i++) {
        final bytes = await File(PhotoFiles.resolve(paths[i])).readAsBytes();
        await api.putJpeg(uploads[i], bytes);
        keys.add(uploads[i].key);
      }
      final updated = await api.commit(book.code, keys);
      if (!mounted) return;
      setState(() {
        _open = updated;
        _progress = null;
      });
    } on HouseholdException catch (e) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _error = e.message;
      });
    }
  }

  Future<void> _place(HouseholdBook book) async {
    if (book.photos.isEmpty) {
      setState(() => _error = 'Add a photo before placing them in a book.');
      return;
    }
    setState(() => _progress = 'Bringing the photos onto this phone');
    try {
      final settings = ref.read(settingsRepositoryProvider);
      final paths = <String>[];
      for (final photo in book.photos) {
        final response = await http.get(Uri.parse(photo.url));
        if (response.statusCode >= 400) continue;
        paths.add(await ref.read(photoServiceProvider).persistBytes(response.bodyBytes));
      }
      if (paths.isEmpty) {
        throw HouseholdException('The photos could not be brought onto this phone.');
      }
      final linked = await settings.get('household-album:${book.code}');
      final existing = linked == null
          ? null
          : await ref.read(albumRepositoryProvider).getDetail(linked);
      final String albumId;
      if (existing != null) {
        albumId = existing.album.id;
        await ref.read(albumRepositoryProvider).fillEmptySlots(albumId, paths);
      } else {
        final album = await ref.read(albumRepositoryProvider).createAlbum(
              title: book.title,
              theme: BookCoverTheme.leather,
              pageCount: evenPageCount(paths.length),
              coverPhotoPath: paths.first,
            );
        albumId = album.id;
        await ref.read(albumRepositoryProvider).fillEmptySlots(albumId, paths);
        await settings.set('household-album:${book.code}', albumId);
      }
      if (!mounted) return;
      context.push('/book/$albumId');
    } on HouseholdException catch (e) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _error = e.message;
      });
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(authSessionProvider).value != null;
    final open = _open;
    return Scaffold(
      backgroundColor: MbTokens.cream,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          MbHero(
            onBack: () => mbPop(context),
            eyebrow: 'Family',
            title: open?.title ?? 'Family book',
            subtitle: open == null
                ? 'One person starts it. A few people with the code add photos. This is not the public World.'
                : 'Code ${open.code}. ${open.memberCount} ${open.memberCount == 1 ? 'person' : 'people'}, ${open.photos.length} photos.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : !signedIn
                    ? FilledButton(
                        onPressed: () => context.push('/account'),
                        child: const Text('Sign in to start or join'),
                      )
                    : open == null
                        ? _picker()
                        : _detail(open),
          ),
        ],
      ),
    );
  }

  Widget _picker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) _note(_error!),
        if (_progress != null) _note(_progress!),
        FilledButton(
          onPressed: _progress == null ? _start : null,
          child: Text(_progress ?? 'Start a family book'),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _code,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Code'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _progress == null ? _join : null,
          child: const Text('Join with a code'),
        ),
        if (_books.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text(
            'On this account',
            style: TextStyle(
              fontFamily: MbTokens.sans,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MbTokens.inkSoft,
            ),
          ),
          for (final book in _books)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(book.title),
              subtitle: Text(book.code),
              onTap: () => setState(() => _open = book),
            ),
        ],
      ],
    );
  }

  Widget _detail(HouseholdBook book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) _note(_error!),
        if (_progress != null) _note(_progress!),
        FilledButton(
          onPressed: _progress == null ? () => _invite(book) : null,
          child: const Text('Invite with the code'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _progress == null ? () => _addPhotos(book) : null,
          child: const Text('Add photos'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _progress == null ? () => _place(book) : null,
          child: const Text('Place them in a book on this phone'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _open = null),
          child: const Text('All family books'),
        ),
      ],
    );
  }

  Widget _note(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: MbTokens.sans,
          fontSize: 16,
          height: 1.4,
          color: MbTokens.ink,
        ),
      ),
    );
  }
}
