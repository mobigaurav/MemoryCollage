import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/chrome.dart';
import '../../core/theme/tokens.dart';
import '../../domain/theme_packs.dart';
import '../../providers.dart';
import '../collage/collage_studio_screen.dart';

typedef _EventChoice = ({DateTimeRange range, ThemePack? pack});

/// "Oct 12–14", "Oct 30 – Nov 2", or "Oct 12".
String eventLabel(DateTimeRange range) {
  final s = range.start;
  final e = range.end;
  final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
  if (sameDay) return DateFormat.MMMd().format(s);
  if (s.year == e.year && s.month == e.month) {
    return '${DateFormat.MMMd().format(s)}–${e.day}';
  }
  return '${DateFormat.MMMd().format(s)} – ${DateFormat.MMMd().format(e)}';
}

DateTime _daysBefore(DateTime day, int days) => DateTime(day.year, day.month, day.day - days);

DateTimeRange lastWeekend(DateTime today) {
  final back = today.weekday % 7;
  return DateTimeRange(start: _daysBefore(today, back + 1), end: _daysBefore(today, back));
}

/// Asks for days and a theme, then opens a collage of the best photos from them.
Future<void> startEventCollage(BuildContext context, WidgetRef ref) async {
  final choice = await showModalBottomSheet<_EventChoice>(
    context: context,
    backgroundColor: context.mbSheet,
    isScrollControlled: true,
    builder: (ctx) => const _EventSheet(),
  );
  if (choice == null || !context.mounted) return;
  final pack = choice.pack;
  if (pack != null && pack.premium && !ref.read(premiumControllerProvider).isPremium) {
    context.push('/paywall');
    return;
  }
  final photos = ref.read(photoServiceProvider);
  if (!await photos.hasLibraryAccess() && !await photos.askLibraryAccess()) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memory Book needs photo access in Settings to find these days.')),
    );
    return;
  }
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    const SnackBar(content: Text('Picking the best photos…'), duration: Duration(seconds: 2)),
  );
  final assets = await photos.eventPhotos(start: choice.range.start, end: choice.range.end);
  if (assets.isEmpty) {
    messenger.showSnackBar(
      SnackBar(content: Text('No photos from ${eventLabel(choice.range)}')),
    );
    return;
  }
  final paths = await photos.keepAssets(assets);
  if (!context.mounted || paths.isEmpty) return;
  messenger.hideCurrentSnackBar();
  await context.push(
    '/collage',
    extra: CollageSeed(
      photos: paths,
      caption: pack == null || pack.id == 'everyday' ? eventLabel(choice.range) : null,
      packId: pack?.id,
    ),
  );
}

class _EventSheet extends StatefulWidget {
  const _EventSheet();

  @override
  State<_EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends State<_EventSheet> {
  ThemePack? _pack;

  void _done(DateTimeRange range) => Navigator.pop<_EventChoice>(context, (range: range, pack: _pack));

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 30),
      lastDate: now,
      initialDateRange: DateTimeRange(start: _daysBefore(now, 2), end: now),
    );
    if (range != null && mounted) _done(range);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final presets = <(String, DateTimeRange)>[
      ('Last weekend', lastWeekend(today)),
      ('Last 7 days', DateTimeRange(start: _daysBefore(today, 6), end: today)),
      ('Last 30 days', DateTimeRange(start: _daysBefore(today, 29), end: today)),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 18, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'From an event',
                style: TextStyle(fontFamily: MbTokens.serif, fontSize: 26, color: context.mbInk),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
              child: Text(
                'The theme only changes the paper and stickers. Photos come from these days: screenshots and near-duplicates go, favorites stay, and the rest are spread across the days. It does not look at what is in the picture.',
                style: TextStyle(color: context.mbMuted, height: 1.35),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('No theme'),
                      selected: _pack == null,
                      onSelected: (_) => setState(() => _pack = null),
                    ),
                  ),
                  for (final pack in ThemePacks.all)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${pack.emoji} ${pack.name}'),
                        selected: _pack?.id == pack.id,
                        onSelected: (_) => setState(() => _pack = pack),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (final (label, range) in presets)
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(label),
                subtitle: Text(eventLabel(range)),
                onTap: () => _done(range),
              ),
            ListTile(
              leading: const Icon(Icons.date_range_outlined),
              title: const Text('Pick the days'),
              onTap: _pickDates,
            ),
          ],
        ),
      ),
    );
  }
}
