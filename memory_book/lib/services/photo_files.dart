import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Photos are stored under Documents/photos. The iOS container path can
/// change between launches, so the database keeps a relative path and we
/// resolve it against the current documents directory.
class PhotoFiles {
  static String? documentsRoot;

  static Future<void> warm() async {
    documentsRoot = (await getApplicationDocumentsDirectory()).path;
  }

  static String resolve(String stored) {
    if (stored.isEmpty) return stored;
    final root = documentsRoot;
    if (p.isAbsolute(stored)) {
      if (File(stored).existsSync()) return stored;
      if (root == null) return stored;
      final name = p.basename(stored);
      for (final folder in ['photos', 'reels', '']) {
        final candidate = folder.isEmpty
            ? p.join(root, name)
            : p.join(root, folder, name);
        if (File(candidate).existsSync()) return candidate;
      }
      return stored;
    }
    if (root == null) return stored;
    return p.join(root, stored);
  }
}
