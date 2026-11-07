/// The surface under a collage. Plain uses the chosen color; the rest are drawn papers.
enum CollagePaper {
  plain('Plain'),
  linen('Linen'),
  kraft('Kraft'),
  cork('Cork board'),
  watercolor('Watercolor'),
  notebook('Notebook'),
  dots('Dot grid'),
  chalk('Chalkboard');

  const CollagePaper(this.label);

  final String label;

  /// Watercolor washes in the chosen color. Plain is the color itself.
  bool get usesColor => this == plain || this == watercolor;

  bool get premium => this == watercolor || this == chalk || this == cork;

  static CollagePaper fromId(String? id) => CollagePaper.values.firstWhere(
        (p) => p.name == id,
        orElse: () => CollagePaper.plain,
      );
}
