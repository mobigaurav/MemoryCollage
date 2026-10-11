# A book, not a gallery

The shelf is a row of covers. Each cover is an album: a title, a cloth, a date range, and an ordered list of pages. A page has a layout and a handful of slots. A slot holds one photo, a caption, a filter, and a crop.

That model is small on purpose. A gallery asks people to scroll. A book asks them to turn one page and look at one picture.

## Where the photo actually lives

The database stores a path, not the pixels. The file is copied into the app’s documents directory as `photos/{id}.jpg`. The path saved in Drift is relative. iOS can change the container UUID between launches, so an absolute path recorded yesterday will not open today. On read, the app resolves the relative path against the current documents directory, and if an old absolute path is still in the database it recovers the file by its name under `photos/`.

A full reinstall still deletes the sandbox. Relative paths fix the next `flutter run`, not a deleted app.

The long edge is reduced when the copy is made. The book does not need a 48-megapixel original to paint a page, and the crop math is stable on a bounded bitmap.

## One page, then the spread

The reader opens on a single page. A portrait photo gets the page. A control in the bar switches to a two-page spread, which is the same page list viewed two at a time. The spread uses a perspective curl. The single page is a swipe. Both are the same slots.

Crop and zoom live on the slot, not on the file. Scale and offset are stored. “Show the whole photo” fits the image inside the frame and does not lock later zoom. The sheet that holds the crop does not compete with the drag-to-dismiss gesture, because a pinch and a sheet drag are the same finger.

Captions, a date line, and a small set of color matrices sit on the slot too. Replacing a photo keeps the frame and clears the crop that belonged to the previous picture.

## Editing the book itself

Pages can be added, reordered, and removed. A date-range fill walks the library and drops pictures into empty slots. Delete is a real button on a light sheet, with a confirm step, because a dark red label on a dark sheet is how people lose a book by accident.

Export of a spread is painted off-screen into an image buffer. It is not a screenshot of the Flutter view. The same painter is what a later print file would call.

The book is the product. Collage and film are ways to take a page out of it. They read the same photo files. They do not keep a second library.

## Diagram

```
  Photo library                 App sandbox                      Drift
  (PhotoKit / picker)           Documents/photos/id.jpg          Albums
        |                              |                         BookPages
        |  copy, long edge limited     |                         PhotoSlots
        +----------------------------->|   store "photos/id.jpg"     |
                                       |---------------------------->|
                                       |                             |
  next launch: container path may change                            |
                                       |                             |
        PhotoFiles.resolve("photos/id.jpg")                          |
                                       |<----------------------------+
                                       |
                                       v
                              +------------------+
                              | one page (default)|
                              | or two-page spread|
                              +--------+---------+
                                       |
                          slot: scale, offset, caption, filter
                                       |
                              crop sheet (zoom does not lock)
```

## Libraries

| Library | Role |
| --- | --- |
| [drift](https://pub.dev/packages/drift) | Albums, pages, slots |
| [photo_manager](https://pub.dev/packages/photo_manager) | Read the library, including a limited selection |
| [image_picker](https://pub.dev/packages/image_picker) | One photo from the picker or camera |
| [path_provider](https://pub.dev/packages/path_provider) | Current documents directory |
| [image](https://pub.dev/packages/image) | Decode and bound the copy |
| [uuid](https://pub.dev/packages/uuid) | File names |

## Source

`memory_book/lib/services/photo_files.dart` is the whole persistence trick. Absolute paths from an older install are recovered by file name.

```dart
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
```

The reader and the crop sheet are `memory_book/lib/features/book/book_reader_screen.dart` and `slot_crop_editor.dart`. `PhotoFiles.warm()` runs in `main.dart` before `runApp`, so the first frame already has a documents root.
