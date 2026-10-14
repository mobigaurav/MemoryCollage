import 'dart:ui';

import 'collage_library.dart';

/// Normalized 0–1 frames, ported and curated from the original TemplateManager.
class CollageTemplate {
  const CollageTemplate({
    required this.id,
    required this.name,
    required this.kind,
    required this.frames,
    this.premium = false,
    this.group,
  });

  final String id;
  final String name;
  final CollageKind kind;
  final List<Rect> frames;
  final bool premium;
  final CollageShelf? group;

  CollageShelf get shelf {
    if (group != null) return group!;
    if (kind == CollageKind.freeform) return CollageShelf.free;
    if (kind == CollageKind.shape) return CollageShelf.shapes;
    if (kind == CollageKind.grid) return CollageShelf.grids;
    if (id.contains('scrap') || id.contains('polaroid') || id.contains('film')) {
      return CollageShelf.scrap;
    }
    return CollageShelf.stories;
  }

  int get photoCount => frames.length;
}

/// A hairline mat so the paper color shows between template cells.
Rect insetFrame(Rect frame, {double gutter = 0.012}) {
  final next = Rect.fromLTRB(
    frame.left + gutter,
    frame.top + gutter,
    frame.right - gutter,
    frame.bottom - gutter,
  );
  if (next.width < 0.04 || next.height < 0.04) return frame;
  return next;
}

enum CollageKind { grid, mosaic, shape, freeform }

enum CollageShelf { grids, stories, scrap, social, shapes, free }

abstract final class CollageCatalog {
  static List<CollageTemplate>? _cached;

  static List<CollageTemplate> get all =>
      _cached ??= [..._all, ...buildCollageLibrary()];

  static List<CollageTemplate> inShelf(CollageShelf shelf) =>
      all.where((t) => t.shelf == shelf).toList();

  static CollageTemplate byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.first);

  static List<Rect> grid(int columns, int rows) {
    final frames = <Rect>[];
    final w = 1.0 / columns;
    final h = 1.0 / rows;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        frames.add(Rect.fromLTWH(x * w, y * h, w, h));
      }
    }
    return frames;
  }

  static List<Rect> _circle(int count) {
    const center = Offset(0.5, 0.5);
    const radius = 0.32;
    const size = 0.22;
    return List.generate(count, (i) {
      final angle = i * 6.28318530718 / count;
      final x = center.dx + radius * _cos(angle) - size / 2;
      final y = center.dy + radius * _sin(angle) - size / 2;
      return Rect.fromLTWH(x, y, size, size);
    });
  }

  static double _cos(double a) {
    // Enough precision for layout.
    var x = a;
    while (x > 3.14159265) {
      x -= 6.2831853;
    }
    while (x < -3.14159265) {
      x += 6.2831853;
    }
    final x2 = x * x;
    return 1 - x2 / 2 + x2 * x2 / 24 - x2 * x2 * x2 / 720;
  }

  static double _sin(double a) => _cos(a - 1.57079632679);
}

final _all = <CollageTemplate>[
  CollageTemplate(
    id: 'grid_2x2',
    name: 'Grid 2×2',
    kind: CollageKind.grid,
    frames: CollageCatalog.grid(2, 2),
  ),
  CollageTemplate(
    id: 'grid_3x2',
    name: 'Grid 3×2',
    kind: CollageKind.grid,
    frames: CollageCatalog.grid(3, 2),
  ),
  CollageTemplate(
    id: 'grid_3x3',
    name: 'Grid 3×3',
    kind: CollageKind.grid,
    frames: CollageCatalog.grid(3, 3),
  ),
  CollageTemplate(
    id: 'grid_4x2',
    name: 'Grid 4×2',
    kind: CollageKind.grid,
    frames: CollageCatalog.grid(4, 2),
    premium: true,
  ),
  CollageTemplate(
    id: 'grid_4x3',
    name: 'Grid 4×3',
    kind: CollageKind.grid,
    frames: CollageCatalog.grid(4, 3),
    premium: true,
  ),
  const CollageTemplate(
    id: 'two_up',
    name: 'Two-up',
    kind: CollageKind.grid,
    frames: [
      Rect.fromLTWH(0, 0, 0.5, 1),
      Rect.fromLTWH(0.5, 0, 0.5, 1),
    ],
  ),
  const CollageTemplate(
    id: 'three_up',
    name: 'Three-up',
    kind: CollageKind.grid,
    frames: [
      Rect.fromLTWH(0, 0, 1 / 3, 1),
      Rect.fromLTWH(1 / 3, 0, 1 / 3, 1),
      Rect.fromLTWH(2 / 3, 0, 1 / 3, 1),
    ],
  ),
  const CollageTemplate(
    id: 'vertical_3',
    name: 'Vertical 3',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0, 0, 1 / 3, 1),
      Rect.fromLTWH(1 / 3, 0, 1 / 3, 1),
      Rect.fromLTWH(2 / 3, 0, 1 / 3, 1),
    ],
  ),
  const CollageTemplate(
    id: 'vertical_4',
    name: 'Vertical 4',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0, 0, 0.25, 1),
      Rect.fromLTWH(0.25, 0, 0.25, 1),
      Rect.fromLTWH(0.5, 0, 0.25, 1),
      Rect.fromLTWH(0.75, 0, 0.25, 1),
    ],
    premium: true,
  ),
  const CollageTemplate(
    id: 'horizontal_3',
    name: 'Horizontal 3',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0, 0, 1, 1 / 3),
      Rect.fromLTWH(0, 1 / 3, 1, 1 / 3),
      Rect.fromLTWH(0, 2 / 3, 1, 1 / 3),
    ],
  ),
  const CollageTemplate(
    id: 'horizontal_4',
    name: 'Horizontal 4',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0, 0, 1, 0.25),
      Rect.fromLTWH(0, 0.25, 1, 0.25),
      Rect.fromLTWH(0, 0.5, 1, 0.25),
      Rect.fromLTWH(0, 0.75, 1, 0.25),
    ],
    premium: true,
  ),
  const CollageTemplate(
    id: 'mosaic',
    name: 'Mosaic',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0, 0, 0.6, 0.4),
      Rect.fromLTWH(0.6, 0, 0.4, 0.4),
      Rect.fromLTWH(0, 0.4, 0.4, 0.6),
      Rect.fromLTWH(0.4, 0.4, 0.6, 0.6),
    ],
  ),
  const CollageTemplate(
    id: 'magazine',
    name: 'Magazine',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0, 0, 0.65, 0.7),
      Rect.fromLTWH(0.65, 0, 0.35, 0.35),
      Rect.fromLTWH(0.65, 0.35, 0.35, 0.35),
      Rect.fromLTWH(0, 0.7, 1, 0.3),
    ],
    premium: true,
  ),
  const CollageTemplate(
    id: 'hero_strip',
    name: 'Hero + strip',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0, 0, 1, 0.7),
      Rect.fromLTWH(0, 0.7, 0.333, 0.3),
      Rect.fromLTWH(0.333, 0.7, 0.333, 0.3),
      Rect.fromLTWH(0.666, 0.7, 0.334, 0.3),
    ],
  ),
  const CollageTemplate(
    id: 'l_shape',
    name: 'L-shape',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0, 0, 0.6, 1),
      Rect.fromLTWH(0.6, 0, 0.4, 0.5),
      Rect.fromLTWH(0.6, 0.5, 0.4, 0.5),
    ],
    premium: true,
  ),
  const CollageTemplate(
    id: 'cross',
    name: 'Cross',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0.35, 0, 0.3, 1),
      Rect.fromLTWH(0, 0.35, 1, 0.3),
    ],
    premium: true,
  ),
  const CollageTemplate(
    id: 'window_2x3',
    name: 'Window',
    kind: CollageKind.grid,
    frames: [
      Rect.fromLTWH(0, 0, 0.5, 1 / 3),
      Rect.fromLTWH(0.5, 0, 0.5, 1 / 3),
      Rect.fromLTWH(0, 1 / 3, 0.5, 1 / 3),
      Rect.fromLTWH(0.5, 1 / 3, 0.5, 1 / 3),
      Rect.fromLTWH(0, 2 / 3, 0.5, 1 / 3),
      Rect.fromLTWH(0.5, 2 / 3, 0.5, 1 / 3),
    ],
  ),
  const CollageTemplate(
    id: 'postcard',
    name: 'Postcard',
    kind: CollageKind.mosaic,
    frames: [Rect.fromLTWH(0.06, 0.06, 0.88, 0.88)],
  ),
  const CollageTemplate(
    id: 'film_strip',
    name: 'Film strip',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0.08, 0.18, 0.28, 0.64),
      Rect.fromLTWH(0.36, 0.18, 0.28, 0.64),
      Rect.fromLTWH(0.64, 0.18, 0.28, 0.64),
    ],
    premium: true,
  ),
  const CollageTemplate(
    id: 'polaroid_row',
    name: 'Polaroid row',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0.04, 0.18, 0.3, 0.55),
      Rect.fromLTWH(0.35, 0.22, 0.3, 0.55),
      Rect.fromLTWH(0.66, 0.18, 0.3, 0.55),
    ],
  ),
  const CollageTemplate(
    id: 'center_focus',
    name: 'Center focus',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0.18, 0.18, 0.64, 0.64),
      Rect.fromLTWH(0.02, 0.02, 0.28, 0.28),
      Rect.fromLTWH(0.7, 0.02, 0.28, 0.28),
      Rect.fromLTWH(0.02, 0.7, 0.28, 0.28),
      Rect.fromLTWH(0.7, 0.7, 0.28, 0.28),
    ],
    premium: true,
  ),
  const CollageTemplate(
    id: 'diagonal',
    name: 'Diagonal',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0, 0, 0.62, 0.62),
      Rect.fromLTWH(0.38, 0.38, 0.62, 0.62),
    ],
    premium: true,
  ),
  const CollageTemplate(
    id: 'scrap_overlap',
    name: 'Scrapbook',
    kind: CollageKind.mosaic,
    frames: [
      Rect.fromLTWH(0.04, 0.08, 0.5, 0.5),
      Rect.fromLTWH(0.42, 0.16, 0.52, 0.42),
      Rect.fromLTWH(0.12, 0.52, 0.5, 0.4),
      Rect.fromLTWH(0.5, 0.58, 0.44, 0.36),
    ],
    premium: true,
  ),
  CollageTemplate(
    id: 'circle',
    name: 'Circle',
    kind: CollageKind.shape,
    frames: CollageCatalog._circle(8),
    premium: true,
  ),
  CollageTemplate(
    id: 'star',
    name: 'Star',
    kind: CollageKind.shape,
    frames: CollageCatalog._circle(5),
    premium: true,
  ),
  CollageTemplate(
    id: 'flower',
    name: 'Flower',
    kind: CollageKind.shape,
    frames: CollageCatalog._circle(6),
    premium: true,
  ),
  CollageTemplate(
    id: 'heart',
    name: 'Heart',
    kind: CollageKind.shape,
    frames: List.generate(8, (i) {
      final t = i / 8 * 6.2831853;
      final x = 0.5 + 0.28 * _heartX(t) - 0.1;
      final y = 0.48 - 0.28 * _heartY(t) - 0.1;
      return Rect.fromLTWH(x, y, 0.2, 0.2);
    }),
    premium: true,
  ),
  CollageTemplate(
    id: 'spiral',
    name: 'Spiral',
    kind: CollageKind.shape,
    frames: List.generate(8, (i) {
      final angle = i * 0.7;
      final r = 0.08 + i * 0.035;
      return Rect.fromLTWH(
        0.5 + r * CollageCatalog._cos(angle) - 0.09,
        0.5 + r * CollageCatalog._sin(angle) - 0.09,
        0.18,
        0.18,
      );
    }),
    premium: true,
  ),
  const CollageTemplate(
    id: 'diamond',
    name: 'Diamond',
    kind: CollageKind.shape,
    frames: [
      Rect.fromLTWH(0.38, 0.06, 0.24, 0.24),
      Rect.fromLTWH(0.18, 0.3, 0.24, 0.24),
      Rect.fromLTWH(0.58, 0.3, 0.24, 0.24),
      Rect.fromLTWH(0.38, 0.54, 0.24, 0.24),
      Rect.fromLTWH(0.38, 0.72, 0.24, 0.2),
    ],
    premium: true,
  ),
  const CollageTemplate(
    id: 'freeform',
    name: 'Freeform',
    kind: CollageKind.freeform,
    frames: [],
  ),
];

double _heartX(double t) {
  final s = CollageCatalog._sin(t);
  return s * s * s;
}

double _heartY(double t) {
  return (13 * CollageCatalog._cos(t) -
          5 * CollageCatalog._cos(2 * t) -
          2 * CollageCatalog._cos(3 * t) -
          CollageCatalog._cos(4 * t)) /
      16;
}
