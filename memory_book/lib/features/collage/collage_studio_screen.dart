import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/haptics.dart';
import '../../core/nav.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../domain/collage_craft.dart';
import '../../domain/collage_templates.dart';
import '../../domain/media_options.dart';
import '../../domain/slot_crop.dart';
import '../../providers.dart';
import '../../services/collage_renderer.dart';
import '../../widgets/framed_photo.dart';
import '../../widgets/local_photo.dart';
import '../../widgets/photo_pinch.dart';
import '../ai/cloud_clip.dart';
import 'sticker_painters.dart';

class CollageStudioScreen extends ConsumerStatefulWidget {
  const CollageStudioScreen({super.key});

  @override
  ConsumerState<CollageStudioScreen> createState() => _CollageStudioScreenState();
}

class _CollageStudioScreenState extends ConsumerState<CollageStudioScreen> {
  String _templateId = 'grid_2x2';
  CollageShelf _shelf = CollageShelf.grids;
  Color _background = MbTokens.paper;
  List<PlacedPhoto?> _photos = [];
  final _stickers = <PlacedSticker>[];
  final _texts = <PlacedText>[];
  String _format = 'JPEG';
  String _resolution = 'High';
  bool _busy = false;
  int? _selectedPhoto;
  int? _selectedSticker;
  int? _selectedText;
  Timer? _saveDebounce;
  double _gestureNx = 0.5;
  double _gestureNy = 0.5;
  double _gestureScale = 1;
  Offset _gesturePan = Offset.zero;

  CollageTemplate get _template => CollageCatalog.byId(_templateId);

  Size get _exportSize => switch (_resolution) {
        'Low' => const Size(720, 720),
        'Medium' => const Size(1080, 1080),
        '4K' => const Size(3840, 3840),
        _ => const Size(2160, 2160),
      };

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _restore() async {
    final draft = await ref.read(draftRepositoryProvider).loadCollage();
    if (!mounted || draft == null) return;
    setState(() {
      _templateId = draft.templateId;
      _shelf = CollageCatalog.byId(draft.templateId).shelf;
      _background = Color(draft.background);
      _photos = _slotsFrom(draft.photos);
      _padFrames();
      _stickers
        ..clear()
        ..addAll(draft.stickers);
      _texts
        ..clear()
        ..addAll(draft.texts);
      _format = draft.format;
      _resolution = draft.resolution;
    });
  }

  bool get _hasPhoto => _photos.any((photo) => photo != null);

  List<PlacedPhoto?> _slotsFrom(List<PlacedPhoto> photos) {
    if (_template.kind == CollageKind.freeform) return [...photos];
    final slots = List<PlacedPhoto?>.filled(
      _template.frames.length,
      null,
      growable: true,
    );
    var fallback = 0;
    for (final photo in photos) {
      final slot = photo.slot ?? fallback;
      fallback++;
      if (slot < 0) continue;
      while (slots.length <= slot) {
        slots.add(null);
      }
      slots[slot] = photo;
    }
    return slots;
  }

  void _padFrames() {
    if (_template.kind == CollageKind.freeform) {
      _photos = _photos.whereType<PlacedPhoto>().toList();
      return;
    }
    final count = _template.frames.length;
    if (_photos.length < count) {
      _photos = [
        ..._photos,
        for (var i = _photos.length; i < count; i++) null,
      ];
    }
  }

  String _shelfLabel(CollageShelf shelf) => switch (shelf) {
        CollageShelf.grids => 'Grids',
        CollageShelf.stories => 'Stories',
        CollageShelf.scrap => 'Scrapbook',
        CollageShelf.social => 'Social',
        CollageShelf.shapes => 'Shapes',
        CollageShelf.free => 'Free',
      };

  ColorFilter? _photoFilter(PlacedPhoto photo) {
    if (photo.filter == 'none') return null;
    for (final id in PhotoFilterId.values) {
      if (id.name == photo.filter) return filterFor(id);
    }
    return null;
  }

  Widget _filteredPhoto(PlacedPhoto photo, Size size) {
    final image = LocalPhoto(path: photo.path, cacheSize: size);
    final filter = _photoFilter(photo);
    if (filter == null) return image;
    return ColorFiltered(colorFilter: filter, child: image);
  }

  Future<void> _fitSelected() async {
    final index = _selectedPhoto;
    if (index == null || index >= _photos.length) return;
    final photo = _photos[index];
    if (photo == null) return;
    if (_template.kind == CollageKind.freeform ||
        index >= _template.frames.length) {
      setState(() => photo.scale = 1);
      _scheduleSave();
      return;
    }
    final frame = _template.frames[index];
    final fit = await fitScaleForPhoto(
      path: photo.path,
      frameWidth: frame.width,
      frameHeight: frame.height,
    );
    if (!mounted) return;
    setState(() {
      photo.scale = fit;
      photo.ox = 0;
      photo.oy = 0;
    });
    _scheduleSave();
    MbHaptics.success();
  }

  Future<void> _enhanceSelected() async {
    final index = _selectedPhoto;
    if (index == null || index >= _photos.length || _photos[index] == null) return;
    final photo = _photos[index]!;
    if (!ref.read(premiumControllerProvider).isPremium) {
      context.push('/paywall');
      return;
    }
    setState(() {
      photo.filter = photo.filter == PhotoFilterId.enhance.name
          ? PhotoFilterId.none.name
          : PhotoFilterId.enhance.name;
    });
    _scheduleSave();
    MbHaptics.success();
  }

  Future<void> _bringSelectedToLife() async {
    final index = _selectedPhoto;
    if (index == null || index >= _photos.length || _photos[index] == null) return;
    final path = _photos[index]!.path;
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
                  style: TextStyle(color: MbTokens.inkSoft, height: 1.35),
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
      return;
    }
    if (result.message?.startsWith('Sign in') == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message!)),
      );
      context.push('/account');
      return;
    }
    if (result.fallbackToOnDevice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cloud video is not connected yet. Filming it on this phone.'),
        ),
      );
      await _filmOnDevice(path);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Could not spend a credit')),
    );
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

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(draftRepositoryProvider).saveCollage(
            CollageDraft(
              templateId: _templateId,
              background: _background.toARGB32(),
              photos: [
                for (var i = 0; i < _photos.length; i++)
                  if (_photos[i] != null) (_photos[i]!..slot = i),
              ],
              stickers: _stickers,
              texts: _texts,
              format: _format,
              resolution: _resolution,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumControllerProvider).isPremium;
    return Theme(
      data: MbTheme.studio,
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: shelfBackButton(context),
        title: const Text('Collage studio'),
        actions: [
          if (_selectedPhoto != null) ...[
            IconButton(
              tooltip: 'Fit in frame',
              onPressed: _fitSelected,
              icon: const Icon(Icons.fit_screen),
            ),
            IconButton(
              tooltip: 'Enhance',
              onPressed: _enhanceSelected,
              icon: const Icon(Icons.auto_fix_high),
            ),
            IconButton(
              tooltip: 'Bring to life',
              onPressed: _bringSelectedToLife,
              icon: const Icon(Icons.movie_filter_outlined),
            ),
          ],
          if (_selectedPhoto != null ||
              _selectedSticker != null ||
              _selectedText != null)
            IconButton(
              tooltip: 'Remove selected',
              onPressed: _deleteSelected,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: _background),
                  child: LayoutBuilder(
                    builder: (context, c) => Stack(
                      children: [
                        if (_template.kind != CollageKind.freeform)
                          for (var i = 0; i < _template.frames.length; i++)
                            _framedPhoto(_template.frames[i], i, c.biggest)
                        else
                          for (var i = 0; i < _photos.length; i++)
                            _freeformPhoto(i, c.biggest),
                        for (var i = 0; i < _stickers.length; i++)
                          _sticker(i, c.biggest),
                        for (var i = 0; i < _texts.length; i++)
                          _text(i, c.biggest),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final shelf in CollageShelf.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_shelfLabel(shelf)),
                      selected: _shelf == shelf,
                      onSelected: (_) => setState(() => _shelf = shelf),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: CollageCatalog.inShelf(_shelf).length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final t = CollageCatalog.inShelf(_shelf)[i];
                final locked = t.premium &&
                    !premium &&
                    !AppConfig.freeCollageTemplateIds.contains(t.id);
                final selected = t.id == _templateId;
                return GestureDetector(
                  onTap: () {
                    if (locked) {
                      context.push('/paywall');
                      return;
                    }
                    setState(() {
                      _templateId = t.id;
                      _padFrames();
                    });
                    _scheduleSave();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 112,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? MbTokens.leather : MbTokens.linen,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: locked ? 0.35 : 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: MbTokens.studio,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomPaint(
                                painter: _MiniTemplatePainter(t),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          locked ? 'Premium' : t.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: MbTokens.sans,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: MbTokens.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Photos',
                  onPressed: _pickPhotos,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                ),
                IconButton(
                  tooltip: 'Adjust',
                  onPressed: _openAdjust,
                  icon: const Icon(Icons.tune),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: !_hasPhoto || _busy ? null : _export,
                    child: Text(_busy ? 'Rendering…' : 'Save'),
                  ),
                ),
                IconButton(
                  tooltip: 'Print',
                  onPressed: !_hasPhoto || _busy
                      ? null
                      : () => _export(toPrinter: true),
                  icon: const Icon(Icons.print_outlined),
                ),
                IconButton(
                  tooltip: 'Share',
                  onPressed: !_hasPhoto || _busy
                      ? null
                      : () => _export(share: true),
                  icon: const Icon(Icons.ios_share),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _framedPhoto(Rect frame, int index, Size canvas) {
    final norm = insetFrame(frame);
    final rect = Rect.fromLTWH(
      norm.left * canvas.width,
      norm.top * canvas.height,
      norm.width * canvas.width,
      norm.height * canvas.height,
    );
    final photo = index < _photos.length ? _photos[index] : null;
    if (photo == null) {
      return Positioned.fromRect(
        rect: rect,
        child: Material(
          color: const Color(0x14000000),
          child: InkWell(
            onTap: () => _placeInFrame(index),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: MbTokens.leather),
                SizedBox(height: 4),
                Text(
                  'Add photo',
                  style: TextStyle(
                    fontFamily: MbTokens.sans,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: MbTokens.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Positioned.fromRect(
      rect: rect,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            PhotoPinch(
              crop: SlotCrop(scale: photo.scale, offsetX: photo.ox, offsetY: photo.oy),
              onTap: () => setState(() {
                _selectedPhoto = index;
                _selectedSticker = null;
                _selectedText = null;
              }),
              onChanged: (next) {
                setState(() {
                  _selectedPhoto = index;
                  photo.scale = next.scale;
                  photo.ox = next.offsetX;
                  photo.oy = next.offsetY;
                });
                _scheduleSave();
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: _selectedPhoto == index
                      ? Border.all(color: MbTokens.leather, width: 2)
                      : null,
                ),
                child: FramedPhoto(
                  path: photo.path,
                  crop: SlotCrop(
                    scale: photo.scale,
                    offsetX: photo.ox,
                    offsetY: photo.oy,
                  ),
                  colorFilter: _photoFilter(photo),
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: IconButton(
                tooltip: 'Replace photo',
                onPressed: () => _placeInFrame(index),
                style: IconButton.styleFrom(
                  backgroundColor: MbTokens.cream,
                  foregroundColor: MbTokens.leather,
                  minimumSize: const Size(36, 36),
                ),
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              ),
            ),
            if (_selectedPhoto == index)
              _ResizeHandle(
                onTap: () => _editPhoto(index),
                onDrag: (delta) {
                  setState(() {
                    photo.scale = (photo.scale + delta / 140)
                        .clamp(SlotCrop.minScale, SlotCrop.maxScale);
                  });
                  _scheduleSave();
                },
              ),
          ],
        ),
    );
  }

  Widget _freeformPhoto(int index, Size canvas) {
    final photo = _photos[index];
    if (photo == null) return const SizedBox.shrink();
    final side = canvas.width * 0.28 * photo.scale;
    return _draggable(
      nx: photo.nx,
      ny: photo.ny,
      width: side,
      height: side,
      canvas: canvas,
      startScale: photo.scale,
      selected: _selectedPhoto == index,
      onSelect: () => setState(() {
        _selectedPhoto = index;
        _selectedSticker = null;
        _selectedText = null;
      }),
      onMoveScale: (nx, ny, scale) {
        setState(() {
          photo.nx = nx;
          photo.ny = ny;
          photo.scale = scale.clamp(0.4, 3);
        });
        _scheduleSave();
      },
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          _filteredPhoto(photo, Size(side, side)),
          if (_selectedPhoto == index)
            _ResizeHandle(
              onTap: () => _editPhoto(index),
              onDrag: (delta) {
                setState(() {
                  photo.scale = (photo.scale + delta / 160).clamp(0.45, 3);
                });
                _scheduleSave();
              },
            ),
        ],
      ),
    );
  }

  Widget _sticker(int index, Size canvas) {
    final sticker = _stickers[index];
    final side = canvas.width * 0.22 * sticker.scale;
    return _draggable(
      nx: sticker.nx,
      ny: sticker.ny,
      width: side,
      height: side,
      canvas: canvas,
      startScale: sticker.scale,
      selected: _selectedSticker == index,
      onSelect: () => setState(() {
        _selectedSticker = index;
        _selectedPhoto = null;
        _selectedText = null;
      }),
      onMoveScale: (nx, ny, scale) {
        setState(() {
          sticker.nx = nx;
          sticker.ny = ny;
          sticker.scale = scale.clamp(0.4, 3);
        });
        _scheduleSave();
      },
      child: CustomPaint(
        painter: StickerPainter(sticker.kind),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _text(int index, Size canvas) {
    final text = _texts[index];
    return _draggable(
      nx: text.nx,
      ny: text.ny,
      width: canvas.width * 0.42,
      height: 36,
      canvas: canvas,
      startScale: 1,
      selected: _selectedText == index,
      onSelect: () => setState(() {
        _selectedText = index;
        _selectedPhoto = null;
        _selectedSticker = null;
      }),
      onMoveScale: (nx, ny, _) {
        setState(() {
          text.nx = nx;
          text.ny = ny;
        });
        _scheduleSave();
      },
      child: Text(
        text.text,
        style: TextStyle(
          color: text.color,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _draggable({
    required double nx,
    required double ny,
    required double width,
    required double height,
    required Size canvas,
    required double startScale,
    required bool selected,
    required VoidCallback onSelect,
    required void Function(double nx, double ny, double scale) onMoveScale,
    required Widget child,
  }) {
    return Positioned(
      left: nx * canvas.width - width / 2,
      top: ny * canvas.height - height / 2,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onSelect,
        onScaleStart: (_) {
          onSelect();
          _gestureNx = nx;
          _gestureNy = ny;
          _gestureScale = startScale;
          _gesturePan = Offset.zero;
        },
        onScaleUpdate: (d) {
          _gesturePan += d.focalPointDelta;
          final amplified = 1 + (d.scale - 1) * 2.4;
          onMoveScale(
            (_gestureNx + _gesturePan.dx / canvas.width).clamp(0.05, 0.95),
            (_gestureNy + _gesturePan.dy / canvas.height).clamp(0.05, 0.95),
            _gestureScale * amplified,
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: selected ? Border.all(color: MbTokens.foil, width: 2) : null,
          ),
          child: child,
        ),
      ),
    );
  }

  Future<void> _openAdjust() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.shuffle),
                title: const Text('Shuffle photos'),
                onTap: () {
                  setState(() {
                    final filled = _photos.whereType<PlacedPhoto>().toList()..shuffle();
                    var next = 0;
                    for (var i = 0; i < _photos.length; i++) {
                      if (_photos[i] != null && next < filled.length) {
                        _photos[i] = filled[next++];
                      }
                    }
                  });
                  _scheduleSave();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_color_fill),
                title: const Text('Background'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickBackground();
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Add text'),
                onTap: () {
                  Navigator.pop(ctx);
                  _addText();
                },
              ),
              ListTile(
                leading: const Icon(Icons.sticky_note_2_outlined),
                title: const Text('Add sticker'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickSticker();
                },
              ),
              ListTile(
                title: Text('Export  $_resolution · $_format'),
                subtitle: const Text('High and 4K are Premium'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickExport();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickExport() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final size in ['Low', 'Medium', 'High', '4K'])
              ListTile(
                title: Text(size),
                trailing: _resolution == size ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, 'size:$size'),
              ),
            const Divider(),
            for (final format in ['JPEG', 'PNG', 'HEIC'])
              ListTile(
                title: Text(format),
                trailing: _format == format ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, 'format:$format'),
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    if (choice.startsWith('size:')) {
      final next = choice.substring(5);
      final premium = ref.read(premiumControllerProvider).isPremium;
      if ((next == 'High' || next == '4K') && !premium) {
        if (mounted) context.push('/paywall');
        return;
      }
      setState(() => _resolution = next);
    } else if (choice.startsWith('format:')) {
      setState(() => _format = choice.substring(7));
    }
    _scheduleSave();
  }

  Future<void> _placeInFrame(int index) async {
    final path = await ref.read(photoServiceProvider).pickSingle();
    if (path == null) return;
    setState(() {
      _padFrames();
      while (_photos.length <= index) {
        _photos.add(null);
      }
      final previous = _photos[index];
      _photos[index] = PlacedPhoto(
        path: path,
        nx: previous?.nx ?? 0.5,
        ny: previous?.ny ?? 0.5,
        slot: index,
      );
      _selectedPhoto = index;
      _selectedSticker = null;
      _selectedText = null;
    });
    _scheduleSave();
  }

  Future<void> _pickPhotos() async {
    _padFrames();
    final empty = <int>[
      for (var i = 0; i < _photos.length; i++)
        if (_photos[i] == null) i,
    ];
    final limit = _template.kind == CollageKind.freeform
        ? AppConfig.maxCollagePhotos
        : (empty.isEmpty ? _template.frames.length : empty.length);
    final paths = await ref.read(photoServiceProvider).pickImages(limit: limit);
    if (paths.isEmpty) return;
    setState(() {
      if (_template.kind == CollageKind.freeform) {
        _photos = [..._photos.whereType<PlacedPhoto>(), ...CollageDraft.layoutPhotos(paths)];
      } else if (empty.isEmpty) {
        for (var i = 0; i < paths.length && i < _photos.length; i++) {
          _photos[i] = PlacedPhoto(path: paths[i], slot: i);
        }
      } else {
        for (var i = 0; i < paths.length && i < empty.length; i++) {
          final slot = empty[i];
          _photos[slot] = PlacedPhoto(path: paths[i], slot: slot);
        }
      }
    });
    _scheduleSave();
  }

  void _addText() {
    setState(() {
      _texts.add(PlacedText(text: 'Memory', nx: 0.5, ny: 0.88));
      _selectedText = _texts.length - 1;
    });
    _scheduleSave();
  }

  Future<void> _pickSticker() async {
    final kind = await showModalBottomSheet<StickerKind>(
      context: context,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: StickerKind.values
              .map(
                (kind) => ActionChip(
                  label: Text(kind.label),
                  onPressed: () => Navigator.pop(ctx, kind),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (kind == null) return;
    setState(() {
      _stickers.add(PlacedSticker(kind: kind, nx: 0.72, ny: 0.22));
      _selectedSticker = _stickers.length - 1;
    });
    MbHaptics.snap();
    _scheduleSave();
  }

  Future<void> _editPhoto(int index) async {
    if (index < 0 || index >= _photos.length || _photos[index] == null) return;
    final photo = _photos[index]!;
    var scale = photo.scale;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: MbTokens.cream,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Edit photo', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: LocalPhoto(path: photo.path, cacheSize: const Size(320, 220)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Drag the corner circle to resize. This slider zooms the photo in its frame.'),
                  Slider(
                    value: scale.clamp(SlotCrop.minScale, 3),
                    min: SlotCrop.minScale,
                    max: 3,
                    onChanged: (v) {
                      setSheet(() => scale = v);
                      setState(() => photo.scale = v);
                      _scheduleSave();
                    },
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final path = await ref.read(photoServiceProvider).pickSingle();
                      if (path == null) return;
                      setState(() {
                        _photos[index] = PlacedPhoto(
                          path: path,
                          nx: photo.nx,
                          ny: photo.ny,
                          scale: photo.scale,
                          ox: photo.ox,
                          oy: photo.oy,
                          filter: photo.filter,
                        );
                        _selectedPhoto = index;
                      });
                      _scheduleSave();
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Replace photo'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteSelected() {
    setState(() {
      if (_selectedPhoto != null &&
          _selectedPhoto! < _photos.length &&
          _photos[_selectedPhoto!] != null) {
        if (_template.kind == CollageKind.freeform) {
          _photos.removeAt(_selectedPhoto!);
        } else {
          _photos[_selectedPhoto!] = null;
        }
      } else if (_selectedSticker != null &&
          _selectedSticker! < _stickers.length) {
        _stickers.removeAt(_selectedSticker!);
      } else if (_selectedText != null && _selectedText! < _texts.length) {
        _texts.removeAt(_selectedText!);
      }
      _selectedPhoto = null;
      _selectedSticker = null;
      _selectedText = null;
    });
    _scheduleSave();
  }

  Future<void> _pickBackground() async {
    final colors = MbTokens.collagePapers;
    final picked = await showModalBottomSheet<Color>(
      context: context,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 12,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () => Navigator.pop(ctx, c),
                  child: CircleAvatar(backgroundColor: c, radius: 28),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (picked != null) {
      setState(() => _background = picked);
      _scheduleSave();
    }
  }

  Future<void> _export({bool share = false, bool toPrinter = false}) async {
    setState(() => _busy = true);
    try {
      final image = await CollageRenderer().render(
        CollageRenderRequest(
          template: _template,
          imagePaths: [for (final photo in _photos) photo?.path ?? ''],
          background: _background,
          texts: [
            for (final t in _texts)
              CollageTextOverlay(
                text: t.text,
                nx: t.nx,
                ny: t.ny,
                color: t.color,
              ),
          ],
          stickers: _stickers,
          placedPhotos: [
            for (final photo in _photos) photo ?? PlacedPhoto(path: ''),
          ],
          size: _exportSize,
        ),
      );
      final bytes = await ref.read(exportServiceProvider).encodeStill(
            image: image,
            format: toPrinter ? 'JPEG' : _format,
            watermark: false,
          );
      final ext = _format.toLowerCase() == 'png' ? 'png' : 'jpg';
      final file = await ref.read(exportServiceProvider).writeBytes(bytes, ext);
      await ref.read(exportHistoryProvider).add(
            toPrinter
                ? 'Printed collage'
                : share
                    ? 'Shared collage'
                    : 'Saved collage $_format',
          );
      if (toPrinter) {
        await ref.read(printServiceProvider).printImages(
              [bytes],
              name: 'Memory Book collage',
            );
      } else if (share) {
        await ref.read(exportServiceProvider).shareFile(file);
      } else {
        await ref.read(exportServiceProvider).saveImageToGallery(file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved $_format collage')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({required this.onDrag, this.onTap});

  final ValueChanged<double> onDrag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -4,
      bottom: -4,
      child: GestureDetector(
        onTap: onTap,
        onPanUpdate: (d) => onDrag(d.delta.dx + d.delta.dy),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MbTokens.leather,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.open_in_full, size: 18, color: MbTokens.cream),
        ),
      ),
    );
  }
}

class _MiniTemplatePainter extends CustomPainter {
  _MiniTemplatePainter(this.template);
  final CollageTemplate template;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = MbTokens.leather.withValues(alpha: 0.85);
    if (template.frames.isEmpty) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 8, paint);
      return;
    }
    for (final f in template.frames) {
      canvas.drawRect(
        Rect.fromLTWH(
          f.left * size.width,
          f.top * size.height,
          f.width * size.width,
          f.height * size.height,
        ).deflate(0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniTemplatePainter oldDelegate) => false;
}

Future<ui.Image> renderCollageForTest({
  required CollageTemplate template,
  required List<String> paths,
}) {
  return CollageRenderer().render(
    CollageRenderRequest(
      template: template,
      imagePaths: paths,
      background: MbTokens.paper,
      size: const Size(256, 256),
    ),
  );
}
