import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../core/theme/tokens.dart';
import '../../data/db/app_database.dart';
import '../../domain/media_options.dart';
import '../../domain/slot_crop.dart';
import '../../providers.dart';
import '../../services/collage_renderer.dart';
import '../../widgets/framed_photo.dart';
import '../../widgets/photo_pinch.dart';

Future<void> showSlotCropEditor({
  required BuildContext context,
  required PhotoSlot slot,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: MbTokens.leatherDark,
    isScrollControlled: true,
    builder: (_) => SlotCropEditor(slot: slot),
  );
}

class SlotCropEditor extends ConsumerStatefulWidget {
  const SlotCropEditor({super.key, required this.slot});
  final PhotoSlot slot;

  @override
  ConsumerState<SlotCropEditor> createState() => _SlotCropEditorState();
}

class _SlotCropEditorState extends ConsumerState<SlotCropEditor> {
  late SlotCrop _crop;

  @override
  void initState() {
    super.initState();
    _crop = SlotCrop.fromValues(
      scale: widget.slot.scale,
      offsetX: widget.slot.offsetX,
      offsetY: widget.slot.offsetY,
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.slot.imagePath;
    final height = MediaQuery.sizeOf(context).height * 0.78;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Position photo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              'Spread fingers to zoom in. Pinch together to shrink the photo until it fits. Drag to place it.',
              style: TextStyle(color: MbTokens.paperDeep),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: MbTokens.paper,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: path == null
                    ? const Center(child: Text('No photo'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LayoutBuilder(
                          builder: (context, _) {
                            return PhotoPinch(
                              crop: _crop,
                              onChanged: (next) => setState(() => _crop = next),
                              child: _CropPreview(
                                path: path,
                                crop: _crop,
                                filterId: widget.slot.filterId,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _crop = const SlotCrop()),
                  child: const Text('Fill'),
                ),
                TextButton(
                  onPressed: _fit,
                  child: const Text('Fit'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Save crop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fit() async {
    final path = widget.slot.imagePath;
    if (path == null) return;
    final size = MediaQuery.sizeOf(context);
    final fit = await fitScaleForPhoto(
      path: path,
      frameWidth: size.width,
      frameHeight: size.height * 0.45,
    );
    if (!mounted) return;
    setState(() => _crop = SlotCrop(scale: fit));
  }

  Future<void> _save() async {
    await ref.read(albumRepositoryProvider).updateSlot(
          PhotoSlotsCompanion(
            id: Value(widget.slot.id),
            scale: Value(_crop.scale),
            offsetX: Value(_crop.offsetX),
            offsetY: Value(_crop.offsetY),
          ),
        );
    MbHaptics.success();
    if (mounted) Navigator.pop(context);
  }
}

class _CropPreview extends StatelessWidget {
  const _CropPreview({
    required this.path,
    required this.crop,
    required this.filterId,
  });

  final String path;
  final SlotCrop crop;
  final String filterId;

  @override
  Widget build(BuildContext context) {
    final filter = filterFor(PhotoFilterId.fromId(filterId));
    return FramedPhoto(path: path, crop: crop, colorFilter: filter);
  }
}
