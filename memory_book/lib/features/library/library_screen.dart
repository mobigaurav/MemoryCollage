import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/nav.dart';
import '../../core/theme/chrome.dart';
import '../../core/theme/tokens.dart';
import '../../domain/book_models.dart';
import '../../data/repositories/settings_repository.dart';
import '../../providers.dart';
import '../../services/shelf_sync.dart';
import '../../domain/book_ops.dart';
import '../../widgets/brand_hero.dart';
import 'album_edit_sheet.dart';
import 'book_shelf.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(albumsProvider);
    final session = ref.watch(authSessionProvider).value;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const _WeeklyNudge(),
          Expanded(
            child: albums.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (items) => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: MbHero(
                      eyebrow: 'Books',
                      title: _greeting(),
                      subtitle: session == null
                          ? 'Photo books on this phone. Sign in and they come back with the account.'
                          : 'Photo books on this phone, saved to the account.',
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _AccountChip(
                          guest: session == null,
                          onTap: () => session == null
                              ? context.push('/account')
                              : context.go('/you'),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start a book', style: text.titleMedium),
                            const SizedBox(height: 6),
                            Text(
                              'Pick a cover. Empty pages wait for photos.',
                              style: text.bodyLarge,
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 132,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _bookStyles.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 12),
                                itemBuilder: (context, i) {
                                  final style = _bookStyles[i];
                                  return _StyleCard(
                                    style: style,
                                    onTap: () => context.push(
                                      '/book/new?style=${style.theme.name}&title=${Uri.encodeComponent(style.suggestedTitle)}',
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              items.isEmpty ? 'An empty shelf' : 'The shelf',
                              style: text.titleMedium,
                            ),
                            if (items.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Start with a cover. The book will stand here.',
                                style: text.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      sliver: SliverToBoxAdapter(
                        child: BookShelf(
                          albums: items,
                          onOpen: (album) => context.push('/book/${album.id}'),
                          onEdit: (album) => showAlbumEditSheet(
                            context: context,
                            album: album,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({required this.guest, required this.onTap});

  final bool guest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x24FFFFFF),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  guest ? Icons.person_outline : Icons.person,
                  size: 18,
                  color: MbTokens.cream,
                ),
                const SizedBox(width: 6),
                Text(
                  guest ? 'Guest' : 'Account',
                  style: const TextStyle(
                    fontFamily: MbTokens.sans,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: MbTokens.cream,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookStyle {
  const _BookStyle(this.label, this.blurb, this.theme, this.suggestedTitle);
  final String label;
  final String blurb;
  final BookCoverTheme theme;
  final String suggestedTitle;
}

const _bookStyles = [
  _BookStyle('Blank', 'Empty pages', BookCoverTheme.leather, 'Untitled'),
  _BookStyle('Family', 'The household', BookCoverTheme.linen, 'Family'),
  _BookStyle('Trip', 'A place you went', BookCoverTheme.travel, 'Trip'),
  _BookStyle('Wedding', 'One day', BookCoverTheme.wedding, 'Wedding'),
  _BookStyle('Baby', 'A first year', BookCoverTheme.baby, 'Baby'),
  _BookStyle('Sticky', 'Notes and scraps', BookCoverTheme.polaroid, 'Sticky notes'),
];

class _StyleCard extends StatelessWidget {
  const _StyleCard({required this.style, required this.onTap});

  final _BookStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.mbSurface,
      elevation: 6,
      shadowColor: const Color(0x40301810),
      shape: MbTokens.glassShape(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 128,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: style.theme.coverColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Text(
                  style.label,
                  style: TextStyle(
                    fontFamily: MbTokens.serif,
                    fontSize: 18,
                    color: context.mbInk,
                  ),
                ),
                Text(
                  style.blurb,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: MbTokens.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.mbMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyNudge extends ConsumerStatefulWidget {
  const _WeeklyNudge();

  @override
  ConsumerState<_WeeklyNudge> createState() => _WeeklyNudgeState();
}

class _WeeklyNudgeState extends ConsumerState<_WeeklyNudge> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_maybe);
  }

  Future<void> _maybe() async {
    final settings = ref.read(settingsRepositoryProvider);
    if (!await settings.getBool(SettingsRepository.weeklyNudgeKey)) return;
    await ref.read(localNotifyProvider).scheduleWeekly(
          title: ShelfSync.weeklyTitle,
          body: ShelfSync.weeklyBody,
        );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class NewBookScreen extends ConsumerStatefulWidget {
  const NewBookScreen({super.key, this.styleId, this.suggestedTitle});

  final String? styleId;
  final String? suggestedTitle;

  @override
  ConsumerState<NewBookScreen> createState() => _NewBookScreenState();
}

class _NewBookScreenState extends ConsumerState<NewBookScreen> {
  late final TextEditingController _title;
  late BookCoverTheme _theme;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _theme = BookCoverTheme.fromId(widget.styleId ?? BookCoverTheme.leather.name);
    _title = TextEditingController(text: widget.suggestedTitle ?? 'Untitled');
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New photo book'),
        leading: IconButton(
          tooltip: 'Cancel',
          onPressed: () => popToShelf(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
            style: TextStyle(
              color: context.mbInk,
              fontFamily: MbTokens.sans,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Cover cloth'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
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
          const SizedBox(height: 12),
          Text(
            'Photos are added only when you pick them. Nothing is pulled from the library on its own.',
            style: TextStyle(
              color: context.mbMuted,
              fontFamily: MbTokens.sans,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _busy ? null : () => _create(choosePhotos: true),
            child: Text(_busy ? 'Opening…' : 'Choose photos'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : () => _create(choosePhotos: false),
            child: const Text('Start with empty pages'),
          ),
        ],
      ),
    );
  }

  Future<void> _create({required bool choosePhotos}) async {
    final router = GoRouter.of(context);
    final premium = ref.read(premiumControllerProvider).isPremium;
    final count = await ref.read(albumRepositoryProvider).count();
    if (!premium && count >= AppConfig.freeAlbumLimit) {
      router.push('/paywall');
      return;
    }
    setState(() => _busy = true);
    try {
      final photos = choosePhotos
          ? await ref.read(photoServiceProvider).pickImages(limit: 40)
          : <String>[];
      if (choosePhotos && photos.isEmpty) return;
      final album = await ref.read(albumRepositoryProvider).createAlbum(
            title: _title.text.trim().isEmpty ? 'Untitled' : _title.text.trim(),
            theme: _theme,
            pageCount: evenPageCount(photos.isEmpty ? 4 : photos.length),
            coverPhotoPath: photos.isEmpty ? null : photos.first,
          );
      if (photos.isNotEmpty) {
        await ref
            .read(albumRepositoryProvider)
            .fillEmptySlots(album.id, photos, addPages: false);
      }
      router.pushReplacement('/book/${album.id}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
