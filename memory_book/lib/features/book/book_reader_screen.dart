import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/haptics.dart';
import '../../core/theme/tokens.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/album_repository.dart';
import '../../domain/book_models.dart';
import '../../domain/slot_crop.dart';
import '../../domain/media_options.dart';
import '../../providers.dart';
import '../../services/book_export.dart';
import '../../widgets/framed_photo.dart';
import '../ai/cloud_clip.dart';
import '../library/album_edit_sheet.dart';
import 'page_canvas.dart';
import 'page_curl.dart';
import 'page_manager_sheet.dart';
import 'slot_crop_editor.dart';

class BookReaderScreen extends ConsumerStatefulWidget {
  const BookReaderScreen({super.key, required this.albumId});
  final String albumId;

  @override
  ConsumerState<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends ConsumerState<BookReaderScreen> {
  bool _coverOpen = false;
  bool _onePage = true;
  int _spread = 0;
  int _page = 0;
  bool _busy = false;
  String? _progress;
  Offset _coverTilt = Offset.zero;

  Future<void> _showProgress(String text) async {
    setState(() {
      _busy = true;
      _progress = text;
    });
    await WidgetsBinding.instance.endOfFrame;
  }

  void _hideProgress() {
    if (!mounted || _progress == null) return;
    setState(() => _progress = null);
  }

  void _leave() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go('/library');
    }
  }

  void _handleBack() {
    if (_coverOpen) {
      setState(() => _coverOpen = false);
      return;
    }
    _leave();
  }

  Future<void> _cropSlot(PhotoSlot slot) async {
    if (slot.imagePath == null) return;
    await showSlotCropEditor(context: context, slot: slot);
  }

  Future<void> _menu(String value, AlbumDetail? detail) async {
    switch (value) {
      case 'pages':
        await showPageManagerSheet(context: context, albumId: widget.albumId);
      case 'fill':
        await _choosePhotos();
      case 'cover':
        if (detail != null) {
          await showAlbumEditSheet(context: context, album: detail.album);
        }
      case 'spread':
        await ref.read(albumRepositoryProvider).addBlankSpread(widget.albumId);
        MbHaptics.success();
      case 'share':
        await _shareSpread(detail);
      case 'shareBook':
        await _shareBook(detail);
      case 'print':
        await _printBook(detail, whole: false);
      case 'printBook':
        await _printBook(detail, whole: true);
      case 'reel':
        await _exportReel(detail);
      case 'family':
        final title = Uri.encodeComponent(detail?.album.title ?? 'Our book');
        if (mounted) {
          context.push('/family?album=${widget.albumId}&title=$title');
        }
      case 'year':
        if (mounted) context.push('/year');
    }
  }

  Future<void> _choosePhotos() async {
    final photos = await ref.read(photoServiceProvider).pickImages(limit: 40);
    if (photos.isEmpty) return;
    await _showProgress('Placing the photos');
    try {
      final used = await ref
          .read(albumRepositoryProvider)
          .fillEmptySlots(widget.albumId, photos);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            used == 0
                ? 'No photos in that range'
                : 'Placed $used photo${used == 1 ? '' : 's'}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(albumDetailProvider(widget.albumId));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: _coverOpen ? 'Close book' : 'Back to shelf',
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          title: Text(async.value?.album.title ?? 'Album'),
          actions: [
            if (_coverOpen)
              IconButton(
                tooltip: _onePage ? 'Open as two pages' : 'One page',
                onPressed: () => setState(() {
                  if (_onePage) {
                    _spread = _page ~/ 2;
                  } else {
                    _page = _spread * 2;
                  }
                  _onePage = !_onePage;
                }),
                icon: Icon(_onePage ? Icons.auto_stories_outlined : Icons.crop_portrait),
              ),
            PopupMenuButton<String>(
              tooltip: 'Book',
              onSelected: (value) => _menu(value, async.value),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'shareBook', child: Text('Share this book')),
                PopupMenuItem(value: 'share', child: Text('Share this page')),
                PopupMenuItem(value: 'printBook', child: Text('Print this book')),
                PopupMenuItem(value: 'print', child: Text('Print this page')),
                PopupMenuItem(value: 'family', child: Text('Share with family')),
                PopupMenuItem(value: 'year', child: Text('Film this year')),
                PopupMenuItem(value: 'reel', child: Text('Flip the book as a reel')),
                PopupMenuItem(value: 'pages', child: Text('Manage pages')),
                PopupMenuItem(value: 'fill', child: Text('Choose photos')),
                PopupMenuItem(value: 'cover', child: Text('Edit cover')),
                PopupMenuItem(value: 'spread', child: Text('Add blank spread')),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (detail) {
            if (detail == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Album missing'),
                    TextButton(
                      onPressed: _leave,
                      child: const Text('Back to shelf'),
                    ),
                  ],
                ),
              );
            }
            if (!_coverOpen) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Listener(
                          onPointerMove: (e) {
                            final box = context.size;
                            if (box == null) return;
                            setState(() {
                              _coverTilt = Offset(
                                ((e.localPosition.dx / 280) - 0.5) * 0.18,
                                ((e.localPosition.dy / 400) - 0.5) * 0.1,
                              );
                            });
                          },
                          onPointerUp: (_) =>
                              setState(() => _coverTilt = Offset.zero),
                          child: BookCoverView(
                            album: detail.album,
                            tilt: _coverTilt,
                            onOpen: () {
                              MbHaptics.pageTurn();
                              setState(() => _coverOpen = true);
                            },
                            onLongPress: () => showAlbumEditSheet(
                              context: context,
                              album: detail.album,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () {
                          MbHaptics.pageTurn();
                          setState(() => _coverOpen = true);
                        },
                        child: const Text('Open the book'),
                      ),
                      TextButton(
                        onPressed: _leave,
                        child: const Text('Back to shelf'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (_onePage) {
              final pageIndex = detail.pages.isEmpty
                  ? 0
                  : _page.clamp(0, detail.pages.length - 1);
              final page = detail.pages.isEmpty ? null : detail.pages[pageIndex];
              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxW = constraints.maxWidth;
                          final maxH = constraints.maxHeight;
                          var pageW = maxW;
                          var pageH = pageW / MbTokens.pageAspect;
                          if (pageH > maxH) {
                            pageH = maxH;
                            pageW = pageH * MbTokens.pageAspect;
                          }
                          return Center(
                            child: SizedBox(
                              width: pageW,
                              height: pageH,
                              child: GestureDetector(
                                onHorizontalDragEnd: (d) {
                                  final v = d.primaryVelocity ?? 0;
                                  if (v < -200 && pageIndex < detail.pages.length - 1) {
                                    setState(() => _page = pageIndex + 1);
                                  } else if (v > 200 && pageIndex > 0) {
                                    setState(() => _page = pageIndex - 1);
                                  }
                                },
                                child: page == null
                                    ? const ColoredBox(color: MbTokens.paper)
                                    : PaperPage(
                                        child: PageCanvas(
                                          page: page,
                                          onSlotTap: (slot) => _editSlot(page, slot),
                                          onSlotLongPress: _cropSlot,
                                          onCropCommit: _commitCrop,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 18),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Previous page',
                          onPressed: pageIndex > 0
                              ? () => setState(() => _page = pageIndex - 1)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Text(
                            'Page ${pageIndex + 1} of ${detail.pages.length}\n'
                            'One photo gets the whole page. Tap the book icon for a two-page spread.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: MbTokens.ink,
                              fontFamily: MbTokens.sans,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Next page',
                          onPressed: pageIndex < detail.pages.length - 1
                              ? () => setState(() => _page = pageIndex + 1)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            final spread = _spread.clamp(0, detail.spreadCount - 1);
            final leftIndex = spread * 2;
            final rightIndex = leftIndex + 1;
            final left = leftIndex < detail.pages.length
                ? detail.pages[leftIndex]
                : null;
            final right = rightIndex < detail.pages.length
                ? detail.pages[rightIndex]
                : null;
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: AspectRatio(
                      aspectRatio: MbTokens.spreadAspect,
                      child: PageCurlSpread(
                        left: PaperPage(
                          child: left == null
                              ? const SizedBox.expand()
                              : PageCanvas(
                                  page: left,
                                  onSlotTap: (slot) => _editSlot(left, slot),
                                  onSlotLongPress: _cropSlot,
                                  onCropCommit: _commitCrop,
                                ),
                        ),
                        right: PaperPage(
                          isLeft: false,
                          child: right == null
                              ? const SizedBox.expand()
                              : PageCanvas(
                                  page: right,
                                  onSlotTap: (slot) => _editSlot(right, slot),
                                  onSlotLongPress: _cropSlot,
                                  onCropCommit: _commitCrop,
                                ),
                        ),
                        canTurnBack: spread > 0,
                        canTurnForward: spread < detail.spreadCount - 1,
                        onTurnForward: () {
                          if (_spread < detail.spreadCount - 1) {
                            setState(() => _spread++);
                          }
                        },
                        onTurnBack: () {
                          if (_spread > 0) setState(() => _spread--);
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 18),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Previous spread',
                        onPressed: spread > 0
                            ? () => setState(() => _spread--)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          'Spread ${spread + 1} of ${detail.spreadCount}\n'
                          'Swipe to turn. Spread fingers to zoom in. Pinch together to shrink a photo into the frame.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: MbTokens.ink,
                            fontFamily: MbTokens.sans,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next spread',
                        onPressed: spread < detail.spreadCount - 1
                            ? () => setState(() => _spread++)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
            if (_progress != null)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0x99000000),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Material(
                        color: MbTokens.cream,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                          child: Row(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _progress!,
                                  style: const TextStyle(
                                    fontFamily: MbTokens.sans,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: MbTokens.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  void _commitCrop(PhotoSlot slot, SlotCrop crop) {
    ref.read(albumRepositoryProvider).updateSlot(
          PhotoSlotsCompanion(
            id: Value(slot.id),
            scale: Value(crop.scale),
            offsetX: Value(crop.offsetX),
            offsetY: Value(crop.offsetY),
          ),
        );
  }

  Future<void> _editSlot(PageDetail page, PhotoSlot slot) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: MbTokens.cream,
      isScrollControlled: true,
      builder: (ctx) => SlotEditorSheet(
        albumId: widget.albumId,
        page: page,
        slot: slot,
      ),
    );
  }

  Future<void> _shareSpread(AlbumDetail? detail) async {
    if (detail == null || _busy) return;
    await _showProgress('Preparing this page to share');
    try {
      final left = _spread * 2 < detail.pages.length
          ? detail.pages[_spread * 2]
          : null;
      final right = _spread * 2 + 1 < detail.pages.length
          ? detail.pages[_spread * 2 + 1]
          : null;
      final image = await BookPainter().paintSpread(
        left: left,
        right: right,
        theme: detail.theme,
        size: const Size(2160, 1500),
      );
      final bytes = await ref.read(exportServiceProvider).encodeStill(
            image: image,
            format: 'JPEG',
            watermark: false,
          );
      final file = await ref.read(exportServiceProvider).writeBytes(bytes, 'jpg');
      await ref.read(exportHistoryProvider).add('Shared spread');
      _hideProgress();
      await ref.read(exportServiceProvider).shareFile(
            file,
            mimeType: 'image/jpeg',
            name: '${detail.album.title}.jpg',
          );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  Future<void> _shareBook(AlbumDetail? detail) async {
    if (detail == null || _busy) return;
    await _showProgress('Preparing this book to share');
    try {
      final pages = await _pageImages(detail, whole: true);
      final pdf = await ref.read(printServiceProvider).pdfFromImages(pages);
      final file = await ref.read(exportServiceProvider).writeBytes(pdf, 'pdf');
      await ref.read(exportHistoryProvider).add('Shared book');
      _hideProgress();
      await ref.read(exportServiceProvider).shareFile(
            file,
            mimeType: 'application/pdf',
            name: '${detail.album.title}.pdf',
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share this book: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  Future<List<Uint8List>> _pageImages(
    AlbumDetail detail, {
    required bool whole,
  }) async {
    final painter = BookPainter();
    final export = ref.read(exportServiceProvider);
    final pages = <Uint8List>[];
    Future<void> addImage(ui.Image image) async {
      pages.add(
        await export.encodeStill(
          image: image,
          format: 'JPEG',
          watermark: false,
        ),
      );
    }

    if (whole) {
      await addImage(
        await painter.paintCover(
          title: detail.album.title,
          theme: detail.theme,
          coverPath: detail.album.coverPhotoPath,
          size: const Size(1600, 2000),
        ),
      );
      final spreads = detail.spreadCount;
      for (var i = 0; i < spreads; i++) {
        final left = i * 2 < detail.pages.length ? detail.pages[i * 2] : null;
        final right =
            i * 2 + 1 < detail.pages.length ? detail.pages[i * 2 + 1] : null;
        await addImage(
          await painter.paintSpread(
            left: left,
            right: right,
            theme: detail.theme,
            size: const Size(2000, 1400),
          ),
        );
      }
    } else {
      final left = _spread * 2 < detail.pages.length
          ? detail.pages[_spread * 2]
          : null;
      final right = _spread * 2 + 1 < detail.pages.length
          ? detail.pages[_spread * 2 + 1]
          : null;
      await addImage(
        await painter.paintSpread(
          left: left,
          right: right,
          theme: detail.theme,
          size: const Size(2000, 1400),
        ),
      );
    }
    return pages;
  }

  Future<void> _printBook(AlbumDetail? detail, {required bool whole}) async {
    if (detail == null || _busy) return;
    await _showProgress(whole ? 'Preparing this book to print' : 'Preparing this page to print');
    try {
      final pages = await _pageImages(detail, whole: whole);
      _hideProgress();
      await ref.read(exportHistoryProvider).add(
            whole ? 'Printed book' : 'Printed page',
          );
      await ref.read(printServiceProvider).printImages(
            pages,
            name: detail.album.title,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the printer: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  Future<void> _exportReel(AlbumDetail? detail) async {
    if (detail == null || _busy) return;
    await _showProgress('Filming this book as a reel');
    try {
      final file = await ref.read(flipReelExporterProvider).exportAlbum(
            detail: detail,
          );
      if (!ref.read(premiumControllerProvider).isPremium) {
        _hideProgress();
        if (mounted) context.push('/paywall');
        return;
      }
      await ref.read(exportHistoryProvider).add('Album reel');
      await ref.read(exportServiceProvider).saveVideoToGallery(file);
      _hideProgress();
      await ref.read(exportServiceProvider).shareVideo(
            file,
            title: detail.album.title,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reel saved to your library')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not encode reel yet: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }
}

class SlotEditorSheet extends ConsumerStatefulWidget {
  const SlotEditorSheet({
    super.key,
    required this.albumId,
    required this.page,
    required this.slot,
  });

  final String albumId;
  final PageDetail page;
  final PhotoSlot slot;

  @override
  ConsumerState<SlotEditorSheet> createState() => _SlotEditorSheetState();
}

class _SlotEditorSheetState extends ConsumerState<SlotEditorSheet> {
  late final TextEditingController _caption;
  late String _filter;
  late PageLayoutId _layout;

  @override
  void initState() {
    super.initState();
    _caption = TextEditingController(text: widget.slot.caption);
    _filter = widget.slot.filterId;
    _layout = widget.page.layout;
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Edit photo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _action(Icons.add_photo_alternate_outlined, 'Replace photo', _pick),
            if (widget.slot.imagePath != null) ...[
              _action(Icons.fit_screen, 'Show the whole photo', _fitInFrame),
              _action(Icons.crop, 'Crop and zoom', () {
                Navigator.pop(context);
                showSlotCropEditor(context: context, slot: widget.slot);
              }),
              _action(Icons.auto_fix_high, 'Enhance', _enhance),
              _action(Icons.movie_filter_outlined, 'Bring this photo to life', _bringToLife),
            ],
            _action(Icons.delete_outline, 'Remove', _clear),
            const SizedBox(height: 12),
            TextField(
              controller: _caption,
              decoration: const InputDecoration(
                labelText: 'Caption',
              ),
              style: const TextStyle(
                color: MbTokens.ink,
                fontFamily: MbTokens.sans,
                fontSize: 16,
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _filter,
              dropdownColor: Colors.white,
              items: PhotoFilterId.values
                  .map(
                    (f) => DropdownMenuItem(
                      value: f.name,
                      child: Text(f.label),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _filter = v ?? 'none'),
            ),
            const SizedBox(height: 8),
            Text('Page layout', style: Theme.of(context).textTheme.bodyMedium),
            Wrap(
              spacing: 8,
              children: PageLayoutId.values
                  .map(
                    (layout) => ChoiceChip(
                      label: Text(layout.label),
                      selected: _layout == layout,
                      onSelected: (_) => setState(() => _layout = layout),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: MbTokens.foil),
      title: Text(label),
      onTap: onTap,
    );
  }

  Future<void> _fitInFrame() async {
    final path = widget.slot.imagePath;
    if (path == null) return;
    final index = widget.slot.slotIndex;
    final frames = widget.page.layout.slots;
    if (index < 0 || index >= frames.length) return;
    final frame = frames[index];
    final fit = await fitScaleForPhoto(
      path: path,
      frameWidth: frame.width,
      frameHeight: frame.height,
    );
    await ref.read(albumRepositoryProvider).updateSlot(
          PhotoSlotsCompanion(
            id: Value(widget.slot.id),
            scale: Value(fit),
            offsetX: const Value(0),
            offsetY: const Value(0),
          ),
        );
    MbHaptics.success();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _enhance() async {
    if (!ref.read(premiumControllerProvider).isPremium) {
      Navigator.pop(context);
      context.push('/paywall');
      return;
    }
    setState(() => _filter = PhotoFilterId.enhance.name);
    await ref.read(albumRepositoryProvider).updateSlot(
          PhotoSlotsCompanion(
            id: Value(widget.slot.id),
            filterId: Value(PhotoFilterId.enhance.name),
          ),
        );
    MbHaptics.success();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _bringToLife() async {
    final path = widget.slot.imagePath;
    if (path == null) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Bring this photo to life'),
                subtitle: Text(
                  'A credit sends it to make a short clip. On this phone, we can pan across it without uploading.',
                  style: TextStyle(
                    color: MbTokens.inkSoft,
                    fontFamily: MbTokens.sans,
                    height: 1.35,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.phone_iphone),
                title: const Text('Film it on this phone'),
                subtitle: const Text('Included with Premium'),
                onTap: () => Navigator.pop(ctx, 'device'),
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Use 1 credit'),
                subtitle: const Text('Cloud clip. The photo leaves the device.'),
                onTap: () => Navigator.pop(ctx, 'credit'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'device') {
      if (!ref.read(premiumControllerProvider).isPremium) {
        context.push('/paywall');
        return;
      }
      await _filmOnDevice(path);
      if (mounted) Navigator.pop(context);
      return;
    }
    final prompt = await askClipPrompt(context);
    if (prompt == null || !mounted) return;
    final result = await runCloudClip(
      context,
      ref,
      imagePath: path,
      prompt: prompt,
    );
    if (!mounted) return;
    if (result.ok && result.videoUrl != null && result.videoUrl!.isNotEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }
    if (result.message?.startsWith('Sign in') == true) {
      final router = GoRouter.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message!)),
      );
      Navigator.pop(context);
      router.push('/account');
      return;
    }
    if (result.fallbackToOnDevice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cloud video is not connected yet. Filming it on this phone.'),
        ),
      );
      await _filmOnDevice(path);
      if (mounted) Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Could not spend a credit')),
    );
    Navigator.pop(context);
  }

  Future<void> _filmOnDevice(String path) async {
    try {
      final file = await ref.read(slideshowExporterProvider).export(
            images: [path],
            aspect: VideoAspect.reel,
            filter: PhotoFilterId.enhance,
            transition: VideoTransitionId.zoom,
            secondsPerSlide: 4,
            title: 'A memory',
          );
      await ref.read(exportHistoryProvider).add('Photo brought to life');
      await ref.read(exportServiceProvider).saveVideoToGallery(file);
      await ref.read(localNotifyProvider).show(
            title: 'Your photo is a film',
            body: 'Saved to your library.',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved a short film of this photo')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not film this photo: $e')),
      );
    }
  }

  Future<void> _pick() async {
    final path = await ref.read(photoServiceProvider).pickSingle();
    if (path == null) return;
    await ref.read(albumRepositoryProvider).updateSlot(
          PhotoSlotsCompanion(
            id: Value(widget.slot.id),
            imagePath: Value(path),
          ),
        );
    if (widget.page.slots.every((s) => s.imagePath == null) ||
        widget.slot.slotIndex == 0) {
      await ref.read(albumRepositoryProvider).setCover(widget.albumId, path);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _clear() async {
    await ref.read(albumRepositoryProvider).updateSlot(
          PhotoSlotsCompanion(
            id: Value(widget.slot.id),
            imagePath: const Value(null),
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _save() async {
    await ref.read(albumRepositoryProvider).setLayout(
          widget.page.page.id,
          _layout,
        );
    await ref.read(albumRepositoryProvider).updateSlot(
          PhotoSlotsCompanion(
            id: Value(widget.slot.id),
            caption: Value(_caption.text),
            filterId: Value(_filter),
          ),
        );
    if (mounted) Navigator.pop(context);
  }
}
