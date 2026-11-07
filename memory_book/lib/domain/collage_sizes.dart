/// A finished collage size. Safe insets are fractions of the page, 0 to 1.
/// They are a guide in the editor. They are not drawn into the saved file.
class CollageSize {
  const CollageSize({
    required this.id,
    required this.label,
    required this.group,
    required this.width,
    required this.height,
    this.premium = false,
    this.safeTop = 0,
    this.safeRight = 0,
    this.safeBottom = 0,
    this.safeLeft = 0,
    this.pageInchesWide,
    this.pageInchesTall,
  });

  final String id;
  final String label;
  final String group;
  final int width;
  final int height;
  final bool premium;

  /// What a phone covers, or the strip a printer cannot reach.
  final double safeTop;
  final double safeRight;
  final double safeBottom;
  final double safeLeft;

  /// Set for a real paper size, so Print asks for that page.
  final double? pageInchesWide;
  final double? pageInchesTall;

  double get aspect => width / height;

  bool get hasSafeZone =>
      safeTop > 0 || safeRight > 0 || safeBottom > 0 || safeLeft > 0;

  bool get isPrint => pageInchesWide != null;
}

abstract final class CollageSizes {
  static const low = CollageSize(
    id: 'Low',
    label: 'Low',
    group: 'Screen',
    width: 720,
    height: 720,
  );
  static const medium = CollageSize(
    id: 'Medium',
    label: 'Square',
    group: 'Screen',
    width: 1080,
    height: 1080,
  );
  static const high = CollageSize(
    id: 'High',
    label: 'High',
    group: 'Screen',
    width: 2160,
    height: 2160,
    premium: true,
  );
  static const ultra = CollageSize(
    id: '4K',
    label: '4K',
    group: 'Screen',
    width: 3840,
    height: 3840,
    premium: true,
  );

  static const instagramSquare = CollageSize(
    id: 'ig_square',
    label: 'Square 1:1',
    group: 'Instagram',
    width: 1080,
    height: 1080,
  );

  /// Profile grids crop a 4:5 post back to the center square.
  static const instagramPortrait = CollageSize(
    id: 'ig_portrait',
    label: 'Portrait 4:5',
    group: 'Instagram',
    width: 1080,
    height: 1350,
    safeTop: 0.10,
    safeBottom: 0.10,
  );

  /// Story and reel chrome: name at the top, reply bar at the bottom, a side margin.
  static const instagramStory = CollageSize(
    id: 'ig_story',
    label: 'Story 9:16',
    group: 'Instagram',
    width: 1080,
    height: 1920,
    safeTop: 0.12,
    safeBottom: 0.18,
    safeLeft: 0.06,
    safeRight: 0.06,
  );

  /// A quarter inch is the strip most photo printers cannot reach.
  static const print4x6 = CollageSize(
    id: 'print_4x6',
    label: '4×6',
    group: 'Print',
    width: 1200,
    height: 1800,
    premium: true,
    safeLeft: 0.25 / 4,
    safeRight: 0.25 / 4,
    safeTop: 0.25 / 6,
    safeBottom: 0.25 / 6,
    pageInchesWide: 4,
    pageInchesTall: 6,
  );
  static const print5x7 = CollageSize(
    id: 'print_5x7',
    label: '5×7',
    group: 'Print',
    width: 1500,
    height: 2100,
    premium: true,
    safeLeft: 0.25 / 5,
    safeRight: 0.25 / 5,
    safeTop: 0.25 / 7,
    safeBottom: 0.25 / 7,
    pageInchesWide: 5,
    pageInchesTall: 7,
  );
  static const printA4 = CollageSize(
    id: 'print_a4',
    label: 'A4',
    group: 'Print',
    width: 2480,
    height: 3508,
    premium: true,
    safeLeft: 6.35 / 210,
    safeRight: 6.35 / 210,
    safeTop: 6.35 / 297,
    safeBottom: 6.35 / 297,
    pageInchesWide: 8.27,
    pageInchesTall: 11.69,
  );

  static const all = <CollageSize>[
    low,
    medium,
    high,
    ultra,
    instagramSquare,
    instagramPortrait,
    instagramStory,
    print4x6,
    print5x7,
    printA4,
  ];

  static const groups = ['Screen', 'Instagram', 'Print'];

  static CollageSize byId(String id) {
    for (final size in all) {
      if (size.id == id) return size;
    }
    return high;
  }

  static List<CollageSize> inGroup(String group) =>
      [for (final size in all) if (size.group == group) size];
}
