# Collage as a canvas

A collage in Memory Book is a project: a list of placed photos, optional text, and a template or a freeform board. It is saved locally, next to the albums, and it renders to a still image when someone exports.

The mistake to avoid is treating the screen as the export. A screenshot includes the status bar, the selection handles, and whatever the phone’s pixel ratio happened to be. The export walks the same placement model through a `PictureRecorder` at a chosen long edge: 720, 1080, or 2160. Filters and the crop are applied in that buffer. A free user gets a watermark drawn into the pixels, not a widget floating above them.

## Templates are rectangles

Each template is a list of frames in normalized coordinates, from zero to one on each axis. A 2×2 grid, a hero with a strip, a polaroid row, and a window are the same kind of object. The catalog is large, and a subset is free. The gate is checked in the studio and again at export, so a premium template cannot be saved by skipping the button that looked locked.

Placing a photo into a frame stores the image path and the crop. The corner handle is outside the pinch gesture. Drag resizes. Tap opens an edit sheet: preview, zoom, replace. Replace keeps the placement and swaps the file. That distinction matters. People expect the hole in the layout to stay put.

Freeform is the same renderer with frames the person dragged into place. Stickers and frames sit on the canvas as their own layers, still in the project, still painted at export size rather than at screen size.

## What the collage is for

The collage is a still. It can be saved to the photo library or handed to the system share sheet. It is not a video, and it is not an AI job. If the picture should move, that is a film or a clip, started from the photo the person already chose.

The paper theme still wraps the studio. The canvas itself stays neutral so the photos, not the chrome, are what get rendered.

## Diagram

```
  Template (frames in 0..1)          Freeform (dragged frames)
           \                               /
            +-------------+---------------+
                          |
                   Collage project
                   photos, crops, text, stickers
                          |
            +-------------+--------------+
            |                            |
     screen (handles, pinch)      CollageRenderer
                                  PictureRecorder
                                  720 / 1080 / 2160
                                          |
                                  JPEG, PNG, or HEIC
                                  watermark in the pixels
                                  if the shelf is free
```

A frame is four numbers, not a widget:

```
  (0,0) ------------------------- (1,0)
    |  nx, ny, nw, nh             |
    |  +--------+                 |
    |  | photo  |                 |
    |  +--------+                 |
  (0,1) ------------------------- (1,1)
```

## Libraries

| Library | Role |
| --- | --- |
| Flutter `dart:ui` `PictureRecorder` | Rasterize the board off-screen |
| [image](https://pub.dev/packages/image) | Encode JPEG and PNG |
| [gal](https://pub.dev/packages/gal) | Save to the photo library |
| [share_plus](https://pub.dev/packages/share_plus) | System share sheet |
| Drift | `CollageProjects` and placed items |

HEIC on iOS goes through a small platform channel. Android export falls back to JPEG.

## Source

`memory_book/lib/services/collage_renderer.dart` takes a size, not the screen.

```dart
class CollageRenderRequest {
  const CollageRenderRequest({
    required this.template,
    required this.imagePaths,
    required this.background,
    this.size = const Size(2160, 2160),
  });
}
```

Frames live in `memory_book/lib/domain/collage_templates.dart`. Which of them are free is `AppConfig.freeCollageTemplateIds` in `memory_book/lib/core/config.dart`. The studio is `memory_book/lib/features/collage/collage_studio_screen.dart`.
