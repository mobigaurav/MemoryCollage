/// Pick a short, even path through a year of photos.
List<T> takeEvenly<T>(List<T> items, int limit) {
  if (limit <= 0 || items.isEmpty) return <T>[];
  if (items.length <= limit) return List<T>.of(items);
  if (limit == 1) return [items.first];
  final step = (items.length - 1) / (limit - 1);
  return [for (var i = 0; i < limit; i++) items[(i * step).round()]];
}

/// This year, then last year, when the camera has enough dated photos.
int? yearWorthFilming(Map<int, int> counts, {int minimum = 4, int? now}) {
  final year = now ?? DateTime.now().year;
  if ((counts[year] ?? 0) >= minimum) return year;
  if ((counts[year - 1] ?? 0) >= minimum) return year - 1;
  return null;
}
