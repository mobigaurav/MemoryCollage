import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../core/theme/tokens.dart';
import '../../data/repositories/album_repository.dart';
import '../../providers.dart';
import '../../widgets/local_photo.dart';

Future<void> showPageManagerSheet({
  required BuildContext context,
  required String albumId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: MbTokens.leatherDark,
    isScrollControlled: true,
    builder: (_) => PageManagerSheet(albumId: albumId),
  );
}

class PageManagerSheet extends ConsumerWidget {
  const PageManagerSheet({super.key, required this.albumId});
  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(albumDetailProvider(albumId));
    final height = MediaQuery.sizeOf(context).height * 0.82;
    return SizedBox(
      height: height,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (detail) {
          if (detail == null) {
            return const Center(child: Text('Album missing'));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pages',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await ref
                            .read(albumRepositoryProvider)
                            .addBlankSpread(albumId);
                        MbHaptics.success();
                      },
                      icon: const Icon(Icons.note_add_outlined, size: 18),
                      label: const Text('Blank spread'),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Drag the handle to reorder. Duplicate or remove any page.',
                    style: TextStyle(color: MbTokens.paperDeep),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  itemCount: detail.pages.length,
                  onReorderItem: (from, to) async {
                    await ref
                        .read(albumRepositoryProvider)
                        .movePage(albumId, from, to);
                    MbHaptics.snap();
                  },
                  itemBuilder: (context, i) {
                    final page = detail.pages[i];
                    final thumb = page.slots
                        .map((s) => s.imagePath)
                        .whereType<String>()
                        .firstOrNull;
                    return ListTile(
                      key: ValueKey(page.page.id),
                      leading: SizedBox(
                        width: 44,
                        height: 56,
                        child: thumb == null
                            ? const DecoratedBox(
                                decoration: BoxDecoration(color: MbTokens.paper),
                                child: Icon(
                                  Icons.crop_portrait,
                                  color: MbTokens.inkSoft,
                                  size: 18,
                                ),
                              )
                            : LocalPhoto(
                                path: thumb,
                                cacheSize: const Size(44, 56),
                              ),
                      ),
                      title: Text('Page ${i + 1}'),
                      subtitle: Text(page.layout.label),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Duplicate',
                            onPressed: () async {
                              await ref
                                  .read(albumRepositoryProvider)
                                  .duplicatePage(page.page.id);
                              MbHaptics.success();
                            },
                            icon: const Icon(Icons.copy_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () => _delete(context, ref, page),
                            icon: const Icon(Icons.delete_outline),
                          ),
                          ReorderableDragStartListener(
                            index: i,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.drag_handle),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    PageDetail page,
  ) async {
    final ok = await ref.read(albumRepositoryProvider).deletePage(page.page.id);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keep at least one spread')),
      );
      return;
    }
    MbHaptics.success();
  }
}
