import 'year_film.dart';

/// What the picker needs to know about one library photo.
class EventPhoto<T> {
  const EventPhoto({
    required this.ref,
    required this.taken,
    required this.pixels,
    this.favorite = false,
    this.screenshot = false,
  });

  final T ref;
  final DateTime taken;
  final int pixels;
  final bool favorite;
  final bool screenshot;
}

/// Chooses the photos for an event collage without looking at faces or uploading anything.
/// Screenshots go. A burst keeps one frame. Favorites always make it. The rest spread over the event.
List<T> pickEventPhotos<T>(
  List<EventPhoto<T>> photos, {
  int limit = 9,
  Duration burst = const Duration(seconds: 30),
}) {
  final candidates = photos.where((p) => !p.screenshot).toList()
    ..sort((a, b) => a.taken.compareTo(b.taken));
  final moments = <EventPhoto<T>>[];
  for (final photo in candidates) {
    if (moments.isNotEmpty &&
        photo.taken.difference(moments.last.taken).abs() <= burst) {
      final kept = moments.last;
      final better = (photo.favorite && !kept.favorite) ||
          (photo.favorite == kept.favorite && photo.pixels > kept.pixels);
      if (better) moments[moments.length - 1] = photo;
      continue;
    }
    moments.add(photo);
  }
  if (moments.length <= limit) return [for (final m in moments) m.ref];
  final favorites = moments.where((m) => m.favorite).take(limit).toList();
  final rest = moments.where((m) => !m.favorite).toList();
  final chosen = [...favorites, ...takeEvenly(rest, limit - favorites.length)]
    ..sort((a, b) => a.taken.compareTo(b.taken));
  return [for (final m in chosen) m.ref];
}

/// How many photos a tidy layout wants, given what the event has.
int eventCollageSize(int available) => switch (available) {
      >= 9 => 9,
      >= 6 => 6,
      _ => available,
    };
