import 'dart:math' as math;
import 'dart:ui';

import 'collage_templates.dart';

/// Layouts beyond the hand-built set: grids, stories, scrapbook, social, shapes.
List<CollageTemplate> buildCollageLibrary() {
  final out = <CollageTemplate>[];

  void add({
    required String id,
    required String name,
    required CollageKind kind,
    required CollageShelf group,
    required List<Rect> frames,
    bool premium = false,
  }) {
    out.add(
      CollageTemplate(
        id: id,
        name: name,
        kind: kind,
        frames: frames,
        group: group,
        premium: premium,
      ),
    );
  }

  List<Rect> grid(int columns, int rows) {
    final frames = <Rect>[];
    final w = 1 / columns;
    final h = 1 / rows;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        frames.add(Rect.fromLTWH(x * w, y * h, w, h));
      }
    }
    return frames;
  }

  for (var columns = 1; columns <= 5; columns++) {
    for (var rows = 1; rows <= 4; rows++) {
      final count = columns * rows;
      if (count < 2 || count > 16) continue;
      add(
        id: 'lib_g${columns}x$rows',
        name: '$columns×$rows',
        kind: CollageKind.grid,
        group: CollageShelf.grids,
        frames: grid(columns, rows),
        premium: count > 9,
      );
    }
  }

  for (final left in [0.38, 0.45, 0.55, 0.62, 0.7]) {
    final id = (left * 100).round();
    add(
      id: 'lib_split_$id',
      name: 'Split $id',
      kind: CollageKind.grid,
      group: CollageShelf.grids,
      frames: [
        Rect.fromLTWH(0, 0, left, 1),
        Rect.fromLTWH(left, 0, 1 - left, 1),
      ],
      premium: left >= 0.7,
    );
    add(
      id: 'lib_stack_$id',
      name: 'Stack $id',
      kind: CollageKind.mosaic,
      group: CollageShelf.stories,
      frames: [
        Rect.fromLTWH(0, 0, 1, left),
        Rect.fromLTWH(0, left, 1, 1 - left),
      ],
    );
  }

  for (final hero in [0.58, 0.68]) {
    for (final count in [2, 3, 4]) {
      final rest = 1 - hero;
      final w = 1 / count;
      add(
        id: 'lib_hero_${(hero * 100).round()}_$count',
        name: 'Hero $count',
        kind: CollageKind.mosaic,
        group: CollageShelf.stories,
        frames: [
          Rect.fromLTWH(0, 0, 1, hero),
          for (var i = 0; i < count; i++)
            Rect.fromLTWH(i * w, hero, w, rest),
        ],
        premium: count == 4,
      );
    }
  }

  for (final count in [2, 3, 4, 5, 6]) {
    final w = 0.84 / count;
    add(
      id: 'lib_film_$count',
      name: 'Film $count',
      kind: CollageKind.mosaic,
      group: CollageShelf.stories,
      frames: [
        for (var i = 0; i < count; i++)
          Rect.fromLTWH(0.08 + i * w, 0.16, w * 0.92, 0.68),
      ],
      premium: count > 4,
    );
    add(
      id: 'lib_story_$count',
      name: 'Story $count',
      kind: CollageKind.mosaic,
      group: CollageShelf.social,
      frames: [
        for (var i = 0; i < count; i++)
          Rect.fromLTWH(0, i / count, 1, 1 / count),
      ],
      premium: count > 4,
    );
  }

  const scraps = <(String, List<Rect>)>[
    (
      'Pinned 3',
      [
        Rect.fromLTWH(0.06, 0.08, 0.46, 0.42),
        Rect.fromLTWH(0.4, 0.2, 0.5, 0.4),
        Rect.fromLTWH(0.14, 0.5, 0.62, 0.4),
      ],
    ),
    (
      'Pinned 5',
      [
        Rect.fromLTWH(0.04, 0.06, 0.4, 0.36),
        Rect.fromLTWH(0.38, 0.1, 0.36, 0.32),
        Rect.fromLTWH(0.62, 0.28, 0.32, 0.3),
        Rect.fromLTWH(0.08, 0.46, 0.42, 0.36),
        Rect.fromLTWH(0.42, 0.54, 0.48, 0.38),
      ],
    ),
    (
      'Tape row',
      [
        Rect.fromLTWH(0.05, 0.22, 0.28, 0.5),
        Rect.fromLTWH(0.36, 0.16, 0.28, 0.5),
        Rect.fromLTWH(0.66, 0.24, 0.28, 0.5),
      ],
    ),
    (
      'Journal',
      [
        Rect.fromLTWH(0.08, 0.08, 0.84, 0.46),
        Rect.fromLTWH(0.1, 0.58, 0.38, 0.32),
        Rect.fromLTWH(0.52, 0.58, 0.38, 0.32),
      ],
    ),
  ];
  for (var i = 0; i < scraps.length; i++) {
    add(
      id: 'lib_scrap_$i',
      name: scraps[i].$1,
      kind: CollageKind.mosaic,
      group: CollageShelf.scrap,
      frames: scraps[i].$2,
      premium: i > 0,
    );
  }

  for (final margin in [0.04, 0.08, 0.12]) {
    final side = 1 - margin * 2;
    add(
      id: 'lib_card_${(margin * 100).round()}',
      name: 'Card ${(margin * 100).round()}',
      kind: CollageKind.mosaic,
      group: CollageShelf.social,
      frames: [Rect.fromLTWH(margin, margin, side, side)],
    );
  }

  for (final left in [0.42, 0.5, 0.62]) {
    for (final count in [2, 3, 4]) {
      final h = 1 / count;
      final id = '${(left * 100).round()}_$count';
      add(
        id: 'lib_side_$id',
        name: 'Side $count',
        kind: CollageKind.mosaic,
        group: CollageShelf.stories,
        frames: [
          Rect.fromLTWH(0, 0, left, 1),
          for (var i = 0; i < count; i++)
            Rect.fromLTWH(left, i * h, 1 - left, h),
        ],
        premium: count > 2,
      );
      add(
        id: 'lib_base_$id',
        name: 'Base $count',
        kind: CollageKind.mosaic,
        group: CollageShelf.grids,
        frames: [
          for (var i = 0; i < count; i++)
            Rect.fromLTWH(i * (1 / count), 0, 1 / count, left),
          Rect.fromLTWH(0, left, 1, 1 - left),
        ],
        premium: count > 3,
      );
    }
  }

  for (final count in [2, 3, 4, 5, 6, 8]) {
    final w = 1 / count;
    add(
      id: 'lib_carousel_$count',
      name: 'Carousel $count',
      kind: CollageKind.mosaic,
      group: CollageShelf.social,
      frames: [
        for (var i = 0; i < count; i++) Rect.fromLTWH(i * w, 0.18, w, 0.64),
      ],
      premium: count > 4,
    );
  }

  for (final count in [2, 3, 4, 6]) {
    add(
      id: 'lib_polaroid_$count',
      name: 'Polaroids $count',
      kind: CollageKind.mosaic,
      group: CollageShelf.scrap,
      frames: [
        for (var i = 0; i < count; i++)
          Rect.fromLTWH(
            0.06 + (i % 3) * 0.3,
            0.08 + (i ~/ 3) * 0.42 + (i.isEven ? 0 : 0.04),
            0.28,
            0.34,
          ),
      ],
      premium: count > 3,
    );
  }

  for (final top in [0.28, 0.34, 0.42]) {
    final mid = (1 - top) / 2;
    for (final columns in [2, 3, 4]) {
      final w = 1 / columns;
      add(
        id: 'lib_band_${(top * 100).round()}_$columns',
        name: 'Band $columns',
        kind: CollageKind.mosaic,
        group: CollageShelf.stories,
        frames: [
          Rect.fromLTWH(0, 0, 1, top),
          for (var i = 0; i < columns; i++)
            Rect.fromLTWH(i * w, top, w, mid),
          for (var i = 0; i < columns; i++)
            Rect.fromLTWH(i * w, top + mid, w, 1 - top - mid),
        ],
        premium: columns > 2,
      );
    }
  }

  for (final inset in [0.06, 0.1, 0.14]) {
    final inner = 1 - inset * 2;
    for (final columns in [2, 3]) {
      final w = inner / columns;
      add(
        id: 'lib_window_${(inset * 100).round()}_$columns',
        name: 'Window $columns',
        kind: CollageKind.grid,
        group: CollageShelf.social,
        frames: [
          for (var i = 0; i < columns; i++)
            Rect.fromLTWH(inset + i * w, inset, w, inner),
        ],
        premium: inset > 0.1,
      );
    }
  }

  const clusters = <(String, List<Rect>)>[
    (
      'Overlap 4',
      [
        Rect.fromLTWH(0.04, 0.06, 0.48, 0.48),
        Rect.fromLTWH(0.42, 0.12, 0.5, 0.42),
        Rect.fromLTWH(0.08, 0.46, 0.44, 0.46),
        Rect.fromLTWH(0.46, 0.5, 0.48, 0.42),
      ],
    ),
    (
      'Corner stack',
      [
        Rect.fromLTWH(0.06, 0.06, 0.62, 0.62),
        Rect.fromLTWH(0.52, 0.52, 0.4, 0.4),
        Rect.fromLTWH(0.08, 0.7, 0.36, 0.24),
      ],
    ),
    (
      'Diary',
      [
        Rect.fromLTWH(0.08, 0.06, 0.4, 0.36),
        Rect.fromLTWH(0.5, 0.1, 0.4, 0.28),
        Rect.fromLTWH(0.12, 0.46, 0.76, 0.22),
        Rect.fromLTWH(0.16, 0.7, 0.32, 0.22),
        Rect.fromLTWH(0.52, 0.68, 0.36, 0.24),
      ],
    ),
    (
      'Postcard row',
      [
        Rect.fromLTWH(0.04, 0.28, 0.22, 0.44),
        Rect.fromLTWH(0.28, 0.2, 0.22, 0.44),
        Rect.fromLTWH(0.52, 0.26, 0.22, 0.44),
        Rect.fromLTWH(0.74, 0.18, 0.22, 0.44),
      ],
    ),
  ];
  for (var i = 0; i < clusters.length; i++) {
    add(
      id: 'lib_cluster_$i',
      name: clusters[i].$1,
      kind: CollageKind.mosaic,
      group: CollageShelf.scrap,
      frames: clusters[i].$2,
      premium: true,
    );
  }

  for (final gutter in [0.015, 0.03, 0.05]) {
    for (final columns in [2, 3]) {
      for (final rows in [2, 3]) {
        final w = (1 - gutter * (columns + 1)) / columns;
        final h = (1 - gutter * (rows + 1)) / rows;
        add(
          id: 'lib_pad_${(gutter * 1000).round()}_${columns}x$rows',
          name: 'Padded $columns×$rows',
          kind: CollageKind.grid,
          group: CollageShelf.grids,
          frames: [
            for (var y = 0; y < rows; y++)
              for (var x = 0; x < columns; x++)
                Rect.fromLTWH(
                  gutter + x * (w + gutter),
                  gutter + y * (h + gutter),
                  w,
                  h,
                ),
          ],
          premium: gutter > 0.03,
        );
      }
    }
  }

  for (final count in [3, 4, 7, 9, 12]) {
    const size = 0.2;
    add(
      id: 'lib_ring_$count',
      name: 'Ring $count',
      kind: CollageKind.shape,
      group: CollageShelf.shapes,
      premium: true,
      frames: [
        for (var i = 0; i < count; i++)
          Rect.fromLTWH(
            0.5 + 0.3 * _cos(i * 6.2831853 / count) - size / 2,
            0.5 + 0.3 * _sin(i * 6.2831853 / count) - size / 2,
            size,
            size,
          ),
      ],
    );
  }

  _addDesigned(add);

  return out;
}

typedef _Add = void Function({
  required String id,
  required String name,
  required CollageKind kind,
  required CollageShelf group,
  required List<Rect> frames,
  bool premium,
});

/// Hand-drawn layouts with a reason to exist: bento boxes, booth strips, journals.
void _addDesigned(_Add add) {
  Rect r(double x, double y, double w, double h) => Rect.fromLTWH(x, y, w, h);

  const stories = CollageShelf.stories;
  const scrap = CollageShelf.scrap;
  const social = CollageShelf.social;
  const grids = CollageShelf.grids;
  const shapes = CollageShelf.shapes;

  final designed = <(String, String, CollageShelf, bool, List<Rect>)>[
    ('bento_5', 'Bento 5', stories, false, [
      r(0, 0, 0.6, 0.6), r(0.6, 0, 0.4, 0.3), r(0.6, 0.3, 0.4, 0.3),
      r(0, 0.6, 0.35, 0.4), r(0.35, 0.6, 0.65, 0.4),
    ]),
    ('bento_6', 'Bento 6', stories, true, [
      r(0, 0, 0.5, 0.4), r(0.5, 0, 0.5, 0.6), r(0, 0.4, 0.5, 0.3),
      r(0, 0.7, 0.25, 0.3), r(0.25, 0.7, 0.25, 0.3), r(0.5, 0.6, 0.5, 0.4),
    ]),
    ('bento_7', 'Bento 7', stories, true, [
      r(0, 0, 0.4, 0.4), r(0.4, 0, 0.6, 0.25), r(0.4, 0.25, 0.3, 0.35),
      r(0.7, 0.25, 0.3, 0.35), r(0, 0.4, 0.4, 0.6), r(0.4, 0.6, 0.6, 0.2),
      r(0.4, 0.8, 0.6, 0.2),
    ]),
    ('pinwheel', 'Pinwheel', stories, true, [
      r(0, 0, 0.62, 0.38), r(0.62, 0, 0.38, 0.62), r(0.38, 0.62, 0.62, 0.38),
      r(0, 0.38, 0.38, 0.62), r(0.38, 0.38, 0.24, 0.24),
    ]),
    ('golden', 'Golden ratio', stories, false, [
      r(0, 0, 0.618, 1), r(0.618, 0, 0.382, 0.618),
      r(0.764, 0.618, 0.236, 0.382), r(0.618, 0.618, 0.146, 0.382),
    ]),
    ('brick_7', 'Brick wall', grids, true, [
      r(0, 0, 0.5, 0.33), r(0.5, 0, 0.5, 0.33),
      r(0, 0.33, 0.25, 0.34), r(0.25, 0.33, 0.5, 0.34), r(0.75, 0.33, 0.25, 0.34),
      r(0, 0.67, 0.5, 0.33), r(0.5, 0.67, 0.5, 0.33),
    ]),
    ('hero_6', 'Hero + 6', stories, true, [
      r(0, 0, 1, 0.6),
      for (var i = 0; i < 6; i++) r((i % 3) / 3, 0.6 + (i ~/ 3) * 0.2, 1 / 3, 0.2),
    ]),
    ('triptych', 'Triptych', stories, false, [
      r(0, 0.15, 0.3, 0.7), r(0.3, 0, 0.4, 1), r(0.7, 0.15, 0.3, 0.7),
    ]),
    ('cover', 'Magazine cover', stories, false, [
      r(0, 0, 1, 0.76), r(0.05, 0.79, 0.43, 0.18), r(0.52, 0.79, 0.43, 0.18),
    ]),
    ('timeline_5', 'Timeline', stories, true, [
      for (var i = 0; i < 5; i++) r(i.isEven ? 0.04 : 0.46, 0.02 + i * 0.196, 0.5, 0.18),
    ]),
    ('center_stamp', 'Center stamp', stories, true, [
      ...CollageCatalog.grid(2, 2),
      r(0.3, 0.3, 0.4, 0.4),
    ]),
    ('year_12', 'Year in 12', grids, true, [
      for (var i = 0; i < 12; i++)
        r(0.02 + (i % 3) * 0.32667, 0.02 + (i ~/ 3) * 0.245, 0.30667, 0.225),
    ]),
    ('before_after', 'Before / after', social, false, [
      r(0.03, 0.1, 0.455, 0.8), r(0.515, 0.1, 0.455, 0.8),
    ]),
    ('quote_card', 'Quote card', social, false, [r(0.06, 0.06, 0.88, 0.62)]),
    ('story_frame', 'Story frame', social, false, [r(0.1, 0.14, 0.8, 0.72)]),
    ('story_trio', 'Story trio', social, true, [
      r(0.06, 0.04, 0.88, 0.3), r(0.06, 0.35, 0.88, 0.3), r(0.06, 0.66, 0.88, 0.3),
    ]),
    ('booth_4', 'Photo booth', scrap, false, [
      for (var i = 0; i < 4; i++) r(0.3, 0.04 + i * 0.235, 0.4, 0.21),
    ]),
    ('contact_sheet', 'Contact sheet', scrap, true, [
      for (var i = 0; i < 20; i++)
        r(0.03 + (i % 4) * 0.2375, 0.03 + (i ~/ 4) * 0.19, 0.2175, 0.17),
    ]),
    ('fridge_6', 'Fridge door', scrap, true, [
      r(0.04, 0.05, 0.4, 0.3), r(0.5, 0.03, 0.44, 0.34), r(0.08, 0.38, 0.36, 0.28),
      r(0.5, 0.4, 0.42, 0.26), r(0.06, 0.69, 0.44, 0.27), r(0.54, 0.7, 0.38, 0.26),
    ]),
    ('ticket_stubs', 'Ticket stubs', scrap, false, [
      r(0.08, 0.1, 0.84, 0.24), r(0.08, 0.38, 0.84, 0.24), r(0.08, 0.66, 0.84, 0.24),
    ]),
    ('frame_in_frame', 'Frame in frame', scrap, true, [
      r(0, 0, 1, 1), r(0.54, 0.54, 0.4, 0.4),
    ]),
    ('staircase', 'Staircase', scrap, false, [
      r(0.02, 0.02, 0.5, 0.32), r(0.25, 0.34, 0.5, 0.32), r(0.48, 0.66, 0.5, 0.32),
    ]),
    ('honeycomb_7', 'Honeycomb', shapes, true, [
      r(0.37, 0.37, 0.26, 0.26),
      for (var i = 0; i < 6; i++)
        r(
          0.37 + 0.28 * _cos(i * 1.0471976),
          0.37 + 0.28 * _sin(i * 1.0471976),
          0.26,
          0.26,
        ),
    ]),
    ('triangle_6', 'Triangle', shapes, true, [
      r(0.39, 0.1, 0.22, 0.22),
      r(0.26, 0.38, 0.22, 0.22), r(0.52, 0.38, 0.22, 0.22),
      r(0.13, 0.66, 0.22, 0.22), r(0.39, 0.66, 0.22, 0.22), r(0.65, 0.66, 0.22, 0.22),
    ]),
    ('arch_5', 'Arch', shapes, true, [
      for (var i = 0; i < 5; i++)
        r(
          0.4 + 0.36 * _cos(3.14159265 + i * 0.785398),
          0.5 + 0.36 * _sin(3.14159265 + i * 0.785398),
          0.2,
          0.2,
        ),
    ]),
    ('wave_5', 'Wave', shapes, true, [
      for (var i = 0; i < 5; i++) r(0.02 + i * 0.196, 0.38 + 0.18 * _sin(i * 1.5707963), 0.18, 0.24),
    ]),
  ];

  for (final (id, name, group, premium, frames) in designed) {
    add(
      id: 'lib_d_$id',
      name: name,
      kind: group == shapes
          ? CollageKind.shape
          : (group == grids ? CollageKind.grid : CollageKind.mosaic),
      group: group,
      frames: frames,
      premium: premium,
    );
  }
}

double _cos(double a) => math.cos(a);

double _sin(double a) => math.sin(a);
