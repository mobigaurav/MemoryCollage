import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/haptics.dart';
import '../../core/theme/tokens.dart';
import '../../data/db/app_database.dart';
import '../../domain/book_models.dart';
import '../../providers.dart';

Future<void> showAlbumEditSheet({
  required BuildContext context,
  required Album album,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: MbTokens.leatherDark,
    isScrollControlled: true,
    builder: (_) => AlbumEditSheet(album: album),
  );
}

class AlbumEditSheet extends ConsumerStatefulWidget {
  const AlbumEditSheet({super.key, required this.album});
  final Album album;

  @override
  ConsumerState<AlbumEditSheet> createState() => _AlbumEditSheetState();
}

class _AlbumEditSheetState extends ConsumerState<AlbumEditSheet> {
  late final TextEditingController _title;
  late BookCoverTheme _theme;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.album.title);
    _theme = BookCoverTheme.fromId(widget.album.themeId);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Edit book',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              style: const TextStyle(color: MbTokens.cream, fontSize: 20),
            ),
            const SizedBox(height: 16),
            const Text('Cover cloth'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: BookCoverTheme.values
                  .map(
                    (theme) => ChoiceChip(
                      selected: _theme == theme,
                      label: Text(theme.label),
                      selectedColor: MbTokens.foil,
                      onSelected: (_) => setState(() => _theme = theme),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _busy ? null : _coverPhoto,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                widget.album.coverPhotoPath == null
                    ? 'Add cover photo'
                    : 'Replace cover photo',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/book/${widget.album.id}');
              },
              child: const Text('Open the book'),
            ),
            TextButton(
              onPressed: _busy ? null : _delete,
              child: const Text(
                'Delete book',
                style: TextStyle(color: MbTokens.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _coverPhoto() async {
    final path = await ref.read(photoServiceProvider).pickSingle();
    if (path == null) return;
    await ref.read(albumRepositoryProvider).setCover(widget.album.id, path);
    MbHaptics.success();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final repo = ref.read(albumRepositoryProvider);
    await repo.rename(
      widget.album.id,
      _title.text.trim().isEmpty ? 'Untitled' : _title.text.trim(),
    );
    await repo.setTheme(widget.album.id, _theme);
    MbHaptics.success();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MbTokens.leather,
        title: const Text('Delete this book?'),
        content: const Text('Pages and photos copied into it will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(albumRepositoryProvider).deleteAlbum(widget.album.id);
    if (mounted) Navigator.pop(context);
  }
}
