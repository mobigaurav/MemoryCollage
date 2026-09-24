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

  return out;
}

double _cos(double a) {
  var x = a;
  while (x > 3.14159265) {
    x -= 6.2831853;
  }
  while (x < -3.14159265) {
    x += 6.2831853;
  }
  final x2 = x * x;
  return 1 - x2 / 2 + x2 * x2 / 24;
}

double _sin(double a) => _cos(a - 1.5707963);
