import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config.dart';
import '../../data/repositories/draft_repository.dart';
import '../../core/haptics.dart';
import '../../core/nav.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../domain/collage_craft.dart';
import '../../domain/collage_paper.dart';
import '../../domain/collage_sizes.dart';
import '../../domain/collage_templates.dart';
import '../../domain/family_collage.dart';
import '../../domain/media_options.dart';
import '../../domain/slot_crop.dart';
import '../../domain/theme_packs.dart';
import '../../providers.dart';
import '../../services/collage_renderer.dart';
import '../../services/household_api.dart';
import '../../services/photo_files.dart';
import '../../services/reel_jobs.dart';
import '../../services/voice_notes.dart';
import '../../services/slideshow_exporter.dart';
import '../../widgets/framed_photo.dart';
import '../../widgets/local_photo.dart';
import '../../widgets/photo_pinch.dart';
import '../ai/cloud_clip.dart';
import 'ink_pad.dart';
import 'voice_mark.dart';
import 'voice_sheet.dart';
import 'paper_painter.dart';
import 'safe_zone.dart';
import 'paper_sheets.dart';
import 'sticker_painters.dart';
import 'sticker_sheet.dart';

/// Photos to start a fresh collage with, such as On this day.
class CollageSeed {
  const CollageSeed({
    required this.photos,
    this.caption,
    this.packId,
    this.slots = const [],
    this.remoteKeys = const [],
    this.templateId,
    this.paper,
    this.background,
    this.householdCode,
  });

  final List<String> photos;
  final String? caption;
  final String? packId;

  /// Frame index for each photo. Empty means the photos fill frames in order.
  final List<int> slots;
  final List<String> remoteKeys;
  final String? templateId;
  final String? paper;
  final int? background;
  final String? householdCode;
}

/// A layout that fits [count] photos well.
String seedTemplateFor(int count) => switch (count) {
      <= 1 => 'postcard',
      2 => 'two_up',
      3 => 'lib_d_triptych',
      4 => 'grid_2x2',
      5 => 'lib_d_bento_5',
      6 => 'window_2x3',
      _ => 'grid_3x3',
    };

class CollageStudioScreen extends ConsumerStatefulWidget {
  const CollageStudioScreen({
    super.key,
    this.initialPhotos = const [],
    this.caption,
    this.packId,
    this.slots = const [],
    this.remoteKeys = const [],
    this.templateId,
    this.paper,
    this.background,
    this.householdCode,
  });

  final List<String> initialPhotos;
  final String? caption;
  final String? packId;
  final List<int> slots;
  final List<String> remoteKeys;
  final String? templateId;
  final String? paper;
  final int? background;
  final String? householdCode;

  @override
  ConsumerState<CollageStudioScreen> createState() => _CollageStudioScreenState();
}

class _CollageStudioScreenState extends ConsumerState<CollageStudioScreen> {
  String _templateId = 'grid_2x2';
  CollageShelf _shelf = CollageShelf.grids;
  Color _background = MbTokens.paper;
  CollagePaper _paper = CollagePaper.plain;
  String? _packId;
  String? _householdCode;
  List<PlacedPhoto?> _photos = [];
  final _stickers = <PlacedSticker>[];
  final _texts = <PlacedText>[];
  final _inks = <PlacedInk>[];
  final _voices = <PlacedVoice>[];
  String _format = 'JPEG';
  String _resolution = 'High';
  bool _busy = false;
  int? _selectedPhoto;
  int? _selectedSticker;
  int? _selectedText;
  int? _selectedInk;
  int? _selectedVoice;
  Timer? _saveDebounce;
  double _gestureNx = 0.5;
  double _gestureNy = 0.5;
  double _gestureScale = 1;
  Offset _gesturePan = Offset.zero;

  CollageTemplate get _template => CollageCatalog.byId(_templateId);

  CollageSize get _size => CollageSizes.byId(_resolution);

  Size get _exportSize => Size(_size.width.toDouble(), _size.height.toDouble());

  @override
  void initState() {
    super.initState();
    if (widget.initialPhotos.isNotEmpty ||
        widget.templateId != null ||
        widget.householdCode != null) {
      _seed();
    } else {
      _restore();
    }
  }

  void _seed() {
    final photos = widget.initialPhotos.take(AppConfig.maxCollagePhotos).toList();
    _templateId = widget.templateId ?? seedTemplateFor(photos.length);
    _shelf = _template.shelf;
    _householdCode = widget.householdCode;
    if (widget.paper != null) _paper = CollagePaper.fromId(widget.paper);
    if (widget.background != null) _background = Color(widget.background!);
    final slots = widget.slots;
    final keys = widget.remoteKeys;
    if (slots.length == photos.length && slots.isNotEmpty && _template.frames.isNotEmpty) {
      _photos = [];
      _padFrames();
      for (var i = 0; i < photos.length; i++) {
        final slot = slots[i];
        if (slot < 0 || slot >= _photos.length) continue;
        _photos[slot] = PlacedPhoto(
          path: photos[i],
          slot: slot,
          remoteKey: i < keys.length && keys[i].isNotEmpty ? keys[i] : null,
        );
      }
    } else {
      _photos = [
        for (var i = 0; i < photos.length; i++) PlacedPhoto(path: photos[i], slot: i),
      ];
      _padFrames();
    }
    final caption = widget.caption;
    final pack = ThemePacks.byId(widget.packId);
    final keepLook = widget.paper != null || widget.background != null;
    if (pack != null && !keepLook) {
      _usePack(pack, caption: caption);
    } else if (pack != null) {
      _packId = pack.id;
      _stickers.addAll(pack.placed(caption: caption));
    } else if (caption != null && caption.isNotEmpty) {
      _stickers.add(
        PlacedSticker(kind: StickerKind.word, text: caption, nx: 0.5, ny: 0.92, scale: 1.6),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleSave());
  }

  void _usePack(ThemePack pack, {String? caption}) {
    _packId = pack.id;
    _paper = pack.paper;
    _background = pack.color;
    _stickers
      ..removeWhere((s) => s.pack)
      ..addAll(pack.placed(caption: caption));
    _selectedSticker = null;
  }

  void _clearPack() {
    _packId = null;
    _paper = CollagePaper.plain;
    _background = MbTokens.paper;
    _stickers.removeWhere((s) => s.pack);
    _selectedSticker = null;
  }

  Future<void> _pickPack() async {
    final choice = await pickThemePack(context, current: _packId);
    if (choice == null || !mounted) return;
    final pack = choice.pack;
    if (pack != null && pack.premium && !ref.read(premiumControllerProvider).isPremium) {
      context.push('/paywall');
      return;
    }
    setState(() {
      if (pack == null) {
        _clearPack();
      } else {
        _usePack(pack);
      }
    });
    MbHaptics.snap();
    _scheduleSave();
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
      _paper = CollagePaper.fromId(draft.paper);
      _packId = draft.packId;
      _householdCode = draft.householdCode;
      _photos = _slotsFrom(draft.photos);
      _padFrames();
      _stickers
        ..clear()
        ..addAll(draft.stickers);
      _texts
        ..clear()
        ..addAll(draft.texts);
      _inks
        ..clear()
        ..addAll(draft.inks);
      _voices
        ..clear()
        ..addAll(draft.voices);
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
        CollageShelf.bento => 'Bento',
        CollageShelf.film => 'Film',
        CollageShelf.journal => 'Journal',
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
      builder: (ctx) => Theme(
        data: MbTheme.studio,
        child: SafeArea(
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
    if (result.ok) return;
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
              inks: _inks,
              voices: _voices,
              format: _format,
              resolution: _resolution,
              paper: _paper.name,
              packId: _packId,
              householdCode: _householdCode,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumControllerProvider).isPremium;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final chrome = dark ? MbTokens.cream : MbTokens.ink;
    return Theme(
      data: MbTheme.studio,
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: dark ? const Color(0xF21A120E) : Colors.transparent,
        foregroundColor: chrome,
        iconTheme: IconThemeData(color: chrome),
        titleTextStyle: TextStyle(
          fontFamily: MbTokens.serif,
          fontSize: 22,
          color: chrome,
        ),
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
              _selectedText != null ||
              _selectedInk != null ||
              _selectedVoice != null)
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
                aspectRatio: _size.aspect,
                child: CustomPaint(
                  painter: PaperPainter(_paper, _background),
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
                        for (var i = 0; i < _inks.length; i++)
                          _ink(i, c.biggest),
                        for (var i = 0; i < _voices.length; i++)
                          _voice(i, c.biggest),
                        SafeZoneGuide(size: _size),
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
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.auto_awesome, size: 16),
                    label: Text(ThemePacks.byId(_packId)?.name ?? 'None'),
                    onPressed: _pickPack,
                  ),
                ),
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
                      color: MbTokens.glass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? MbTokens.leather : MbTokens.glassEdge,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33301810),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
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
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: IconTheme(
              data: IconThemeData(color: chrome),
              child: Row(
                children: [
                  _StudioTool(
                    icon: Icons.add_photo_alternate_outlined,
                    label: 'Photos',
                    color: chrome,
                    onPressed: _pickPhotos,
                  ),
                  _StudioTool(
                    icon: Icons.tune,
                    label: 'Adjust',
                    color: chrome,
                    onPressed: _openAdjust,
                  ),
                  _StudioTool(
                    icon: Icons.photo_library_outlined,
                    label: _busy ? 'Saving' : 'Save',
                    color: chrome,
                    onPressed: !_hasPhoto || _busy ? null : _export,
                  ),
                  _StudioTool(
                    icon: Icons.movie_creation_outlined,
                    label: 'Reel',
                    color: chrome,
                    onPressed: !_hasPhoto ? null : _makeReel,
                  ),
                  _StudioTool(
                    icon: Icons.group_add_outlined,
                    label: 'Family',
                    color: chrome,
                    onPressed: _shareWithFamily,
                  ),
                  _StudioTool(
                    icon: Icons.print_outlined,
                    label: 'Print',
                    color: chrome,
                    onPressed: !_hasPhoto || _busy ? null : () => _export(toPrinter: true),
                  ),
                  _StudioTool(
                    icon: Icons.ios_share,
                    label: 'Share',
                    color: chrome,
                    onPressed: !_hasPhoto || _busy ? null : () => _export(share: true),
                  ),
                ],
              ),
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
            child: const DecoratedBox(
              decoration: BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(color: MbTokens.slotDash),
                ),
              ),
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
              onTap: () => _placeInFrame(index),
              onLongPress: () => setState(() {
                _selectedPhoto = index;
                _selectedSticker = null;
                _selectedText = null;
                _selectedInk = null;
                _selectedVoice = null;
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
        _selectedInk = null;
                _selectedVoice = null;
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
        _selectedInk = null;
                _selectedVoice = null;
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
        painter: StickerPainter(sticker.kind, text: sticker.text),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _ink(int index, Size canvas) {
    final ink = _inks[index];
    final width = canvas.width * 0.72 * ink.scale;
    final height = width * PlacedInk.aspect;
    return _draggable(
      nx: ink.nx,
      ny: ink.ny,
      width: width,
      height: height,
      canvas: canvas,
      startScale: ink.scale,
      selected: _selectedInk == index,
      onSelect: () => setState(() {
        _selectedInk = index;
        _selectedPhoto = null;
        _selectedSticker = null;
        _selectedText = null;
        _selectedVoice = null;
      }),
      onMoveScale: (nx, ny, scale) {
        setState(() {
          ink.nx = nx;
          ink.ny = ny;
          ink.scale = scale.clamp(0.4, 2.4);
        });
        _scheduleSave();
      },
      child: CustomPaint(
        painter: InkMark(ink),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _voice(int index, Size canvas) {
    final voice = _voices[index];
    final side = canvas.width * 0.22 * voice.scale;
    return _draggable(
      nx: voice.nx,
      ny: voice.ny,
      width: side,
      height: side,
      canvas: canvas,
      startScale: voice.scale,
      selected: _selectedVoice == index,
      onSelect: () => setState(() {
        _selectedVoice = index;
        _selectedPhoto = null;
        _selectedSticker = null;
        _selectedText = null;
        _selectedInk = null;
      }),
      onMoveScale: (nx, ny, scale) {
        setState(() {
          voice.nx = nx;
          voice.ny = ny;
          voice.scale = scale.clamp(0.5, 2.2);
        });
        _scheduleSave();
      },
      child: CustomPaint(
        painter: VoiceMark(voice.url),
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
        _selectedInk = null;
                _selectedVoice = null;
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
      builder: (ctx) => Theme(
        data: MbTheme.studio,
        child: SafeArea(
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
                leading: const Icon(Icons.mic_none),
                title: const Text('Voice note'),
                subtitle: const Text('A QR mark. A scan of the print plays it.'),
                onTap: () {
                  Navigator.pop(ctx);
                  _addVoice();
                },
              ),
              ListTile(
                leading: const Icon(Icons.draw_outlined),
                title: const Text('Handwritten caption'),
                onTap: () {
                  Navigator.pop(ctx);
                  _addHandwriting();
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
                title: Text('Export  ${_size.label} · $_format'),
                subtitle: Text(
                  _size.hasSafeZone
                      ? (_size.isPrint
                          ? 'Shaded edge is the printer margin'
                          : 'Shaded edge is what a phone covers')
                      : 'Large files and print sizes are Premium',
                ),
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
      ),
    );
  }

  Future<void> _pickExport() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: MbTokens.cream,
      isScrollControlled: true,
      builder: (ctx) => Theme(
        data: MbTheme.studio,
        child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * 0.72,
          child: ListView(
            children: [
              for (final group in CollageSizes.groups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Text(
                    group.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: MbTokens.sans,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: MbTokens.leather,
                    ),
                  ),
                ),
                for (final size in CollageSizes.inGroup(group))
                  ListTile(
                    title: Text(size.label),
                    subtitle: Text(_sizeDetail(size)),
                    trailing: _resolution == size.id ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(ctx, 'size:${size.id}'),
                  ),
              ],
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
        ),
      ),
    );
    if (choice == null) return;
    if (choice.startsWith('size:')) {
      final next = CollageSizes.byId(choice.substring(5));
      final premium = ref.read(premiumControllerProvider).isPremium;
      if (next.premium && !premium) {
        if (mounted) context.push('/paywall');
        return;
      }
      setState(() => _resolution = next.id);
    } else if (choice.startsWith('format:')) {
      setState(() => _format = choice.substring(7));
    }
    _scheduleSave();
  }

  String _sizeDetail(CollageSize size) {
    final shape = '${size.width}×${size.height}';
    if (size.premium) return '$shape · Premium';
    if (size.hasSafeZone) return '$shape · with a guide';
    return shape;
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
      _selectedInk = null;
                _selectedVoice = null;
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

  Future<void> _addVoice() async {
    if (ref.read(authSessionProvider).value == null) {
      context.push('/account');
      return;
    }
    final file = await recordVoiceNote(context);
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    final api = ref.read(voiceNoteApiProvider);
    final repo = ref.read(draftRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Sending the voice note. You can keep editing.')),
    );
    unawaited(() async {
      try {
        final url = await api.publish(bytes);
        final voice = PlacedVoice(url: url);
        if (mounted) {
          setState(() {
            _voices.add(voice);
            _selectedVoice = _voices.length - 1;
            _selectedPhoto = null;
            _selectedSticker = null;
            _selectedText = null;
            _selectedInk = null;
          });
          _scheduleSave();
        } else {
          final draft = await repo.loadCollage();
          if (draft != null) {
            await repo.saveCollage(
              CollageDraft(
                templateId: draft.templateId,
                background: draft.background,
                photos: draft.photos,
                stickers: draft.stickers,
                texts: draft.texts,
                inks: draft.inks,
                voices: [...draft.voices, voice],
                format: draft.format,
                resolution: draft.resolution,
                paper: draft.paper,
                packId: draft.packId,
                householdCode: draft.householdCode,
              ),
            );
          }
        }
        messenger.showSnackBar(
          const SnackBar(content: Text('The QR is on the page. A scan plays the note.')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              e is VoiceNoteException ? e.message : 'The voice note could not be sent.',
            ),
          ),
        );
      }
    }());
  }

  Future<void> _addHandwriting() async {
    final ink = await drawCaption(context, onDark: _paper == CollagePaper.chalk);
    if (ink == null || !mounted) return;
    setState(() {
      _inks.add(ink);
      _selectedInk = _inks.length - 1;
      _selectedPhoto = null;
      _selectedSticker = null;
      _selectedText = null;
      _selectedVoice = null;
    });
    MbHaptics.snap();
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
    final choice = await pickSticker(context);
    if (choice == null || !mounted) return;
    setState(() {
      _stickers.add(
        PlacedSticker(kind: choice.kind, text: choice.text, nx: 0.72, ny: 0.22),
      );
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
        return Theme(
          data: MbTheme.studio,
          child: Padding(
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
      } else if (_selectedInk != null && _selectedInk! < _inks.length) {
        _inks.removeAt(_selectedInk!);
      } else if (_selectedVoice != null && _selectedVoice! < _voices.length) {
        _voices.removeAt(_selectedVoice!);
      }
      _selectedPhoto = null;
      _selectedSticker = null;
      _selectedText = null;
      _selectedInk = null;
                _selectedVoice = null;
    });
    _scheduleSave();
  }

  Future<void> _pickBackground() async {
    final premium = ref.read(premiumControllerProvider).isPremium;
    final picked = await pickBackground(
      context,
      paper: _paper,
      color: _background,
      premium: premium,
    );
    if (picked == null || !mounted) return;
    if (picked.paper.premium && !premium) {
      context.push('/paywall');
      return;
    }
    setState(() {
      _paper = picked.paper;
      _background = picked.color;
    });
    _scheduleSave();
  }

  Future<void> _shareWithFamily() async {
    if (ref.read(authSessionProvider).value == null) {
      context.push('/account');
      return;
    }
    if (_template.kind == CollageKind.freeform || _template.frames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a framed layout. Family fills those frames.')),
      );
      return;
    }
    var code = _householdCode;
    String? title;
    if (code == null) {
      title = await _askFamilyTitle();
      if (title == null || !mounted) return;
    }
    final layout = SharedCollageLayout(
      templateId: _templateId,
      background: _background.toARGB32(),
      paper: _paper.name,
      frames: _template.frames.length,
      packId: _packId,
    );
    final pending = <({String path, int slot})>[];
    for (var i = 0; i < _photos.length && i < layout.frames; i++) {
      final photo = _photos[i];
      if (photo == null || (photo.remoteKey != null && photo.remoteKey!.isNotEmpty)) continue;
      pending.add((path: photo.path, slot: i));
    }
    final api = ref.read(householdApiProvider);
    final repo = ref.read(draftRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Sending this collage to your family. You can keep editing.')),
    );
    unawaited(() async {
      try {
        final String familyCode;
        if (code == null) {
          final book = await api.create(title!, kind: 'collage', layout: layout);
          familyCode = book.code;
        } else {
          familyCode = code;
          await api.setLayout(familyCode, layout);
        }
        final sent = <String, String>{};
        if (pending.isNotEmpty) {
          final uploads = await api.reserve(familyCode, pending.length);
          final keys = <String>[];
          final slots = <int>[];
          for (var i = 0; i < pending.length && i < uploads.length; i++) {
            final bytes = await File(PhotoFiles.resolve(pending[i].path)).readAsBytes();
            await api.putJpeg(uploads[i], bytes);
            keys.add(uploads[i].key);
            slots.add(pending[i].slot);
            sent[pending[i].path] = uploads[i].key;
          }
          if (keys.isNotEmpty) await api.commit(familyCode, keys, slots: slots);
        }
        await _stampFamily(repo, familyCode, sent);
        if (mounted) {
          setState(() {
            _householdCode = familyCode;
            for (final photo in _photos) {
              if (photo == null) continue;
              final key = sent[photo.path];
              if (key != null) photo.remoteKey = key;
            }
          });
          _scheduleSave();
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text('The family code is $familyCode. Anyone with it can add a photo.'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text:
                        'Join our collage in Memory Book. The code is $familyCode. Only people with the code can add a photo to an empty frame.',
                  ),
                );
              },
            ),
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              e is HouseholdException ? e.message : 'The family collage could not be reached.',
            ),
          ),
        );
      }
    }());
  }

  Future<String?> _askFamilyTitle() async {
    final controller = TextEditingController(text: 'Family collage');
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => Theme(
        data: MbTheme.studio,
        child: AlertDialog(
        backgroundColor: MbTokens.cream,
        title: const Text('Share with family'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 40,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (value) => Navigator.pop(ctx, value.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Share'),
          ),
        ],
        ),
      ),
    );
    controller.dispose();
    final trimmed = title?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _stampFamily(
    DraftRepository repo,
    String code,
    Map<String, String> sent,
  ) async {
    final draft = await repo.loadCollage();
    if (draft == null) return;
    await repo.saveCollage(
      CollageDraft(
        templateId: draft.templateId,
        background: draft.background,
        photos: [
          for (final photo in draft.photos) photo.copyWith(remoteKey: sent[photo.path]),
        ],
        stickers: draft.stickers,
        texts: draft.texts,
        inks: draft.inks,
        voices: draft.voices,
        format: draft.format,
        resolution: draft.resolution,
        paper: draft.paper,
        packId: draft.packId,
        householdCode: code,
      ),
    );
  }

  void _makeReel() {
    final template = _template;
    final photos = [
      for (final photo in _photos)
        photo == null
            ? null
            : PlacedPhoto(
                path: photo.path,
                nx: photo.nx,
                ny: photo.ny,
                scale: photo.scale,
                ox: photo.ox,
                oy: photo.oy,
                filter: photo.filter,
                slot: photo.slot,
              ),
    ];
    final background = _background;
    final paper = _paper;
    final stickers = [
      for (final s in _stickers)
        PlacedSticker(kind: s.kind, text: s.text, nx: s.nx, ny: s.ny, scale: s.scale),
    ];
    final texts = [
      for (final t in _texts)
        CollageTextOverlay(text: t.text, nx: t.nx, ny: t.ny, color: t.color),
    ];
    final inks = [
      for (final ink in _inks)
        PlacedInk(
          strokes: ink.strokes,
          nx: ink.nx,
          ny: ink.ny,
          scale: ink.scale,
          color: ink.color,
        ),
    ];
    final voices = [
      for (final voice in _voices)
        PlacedVoice(url: voice.url, nx: voice.nx, ny: voice.ny, scale: voice.scale),
    ];
    final music = DateTime.now().day % SlideshowExporter.musicNames.length;
    unawaited(
      ref.read(reelJobsProvider.notifier).run(
            label: 'Collage reel',
            failure: 'The collage reel did not finish',
            work: (ref) async {
              final file = await ref.read(collageReelProvider).make(
                    template: template,
                    photos: photos,
                    background: background,
                    paper: paper,
                    stickers: stickers,
                    texts: texts,
                    inks: inks,
                    voices: voices,
                    musicIndex: music,
                  );
              return ref.read(reelLibraryProvider).keep(
                    source: file,
                    title: 'Collage',
                    kind: 'collage',
                  );
            },
          ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Making a reel of this collage. It shows up on Reels. Keep going.'),
      ),
    );
  }

  Future<void> _export({bool share = false, bool toPrinter = false}) async {
    setState(() => _busy = true);
    try {
      final image = await CollageRenderer().render(
        CollageRenderRequest(
          template: _template,
          imagePaths: [for (final photo in _photos) photo?.path ?? ''],
          background: _background,
          paper: _paper,
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
          inks: _inks,
          voices: _voices,
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
              pageWidthInches: _size.pageInchesWide,
              pageHeightInches: _size.pageInchesTall,
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

class _StudioTool extends StatelessWidget {
  const _StudioTool({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ink = onPressed == null ? color.withValues(alpha: 0.35) : color;
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: ink),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: MbTokens.sans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
