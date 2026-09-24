/// Pure list move used by page reorder (and its tests).
List<T> moveItem<T>(List<T> items, int from, int to) {
  if (items.isEmpty) return items;
  final next = [...items];
  if (from < 0 || from >= next.length) return next;
  final clampedTo = to.clamp(0, next.length);
  final item = next.removeAt(from);
  final insertAt = clampedTo > next.length ? next.length : clampedTo;
  next.insert(insertAt > next.length ? next.length : insertAt, item);
  return next;
}

/// Even page count so the book always closes on a full spread.
int evenPageCount(int photos, {int minimum = 4, int maximum = 40}) {
  var count = photos < minimum ? minimum : photos;
  if (count.isOdd) count++;
  if (count > maximum) count = maximum;
  if (count.isOdd) count--;
  return count < minimum ? minimum : count;
}
