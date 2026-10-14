enum PhotoFilterId {
  none,
  sepia,
  noir,
  vignette,
  bloom,
  instant,
  comic,
  enhance;

  String get label => switch (this) {
        PhotoFilterId.none => 'None',
        PhotoFilterId.sepia => 'Sepia',
        PhotoFilterId.noir => 'Noir',
        PhotoFilterId.vignette => 'Vignette',
        PhotoFilterId.bloom => 'Bloom',
        PhotoFilterId.instant => 'Instant',
        PhotoFilterId.comic => 'Comic',
        PhotoFilterId.enhance => 'Enhance',
      };

  static PhotoFilterId fromId(String id) => PhotoFilterId.values.firstWhere(
        (f) => f.name == id,
        orElse: () => PhotoFilterId.none,
      );
}

enum VideoTransitionId {
  crossfade,
  slide,
  zoom,
  none;

  String get label => switch (this) {
        VideoTransitionId.crossfade => 'Crossfade',
        VideoTransitionId.slide => 'Slide',
        VideoTransitionId.zoom => 'Zoom',
        VideoTransitionId.none => 'Cut',
      };

  static VideoTransitionId fromId(String id) =>
      VideoTransitionId.values.firstWhere(
        (t) => t.name == id,
        orElse: () => VideoTransitionId.crossfade,
      );
}

enum VideoAspect {
  reel,
  square,
  landscape;

  String get label => switch (this) {
        VideoAspect.reel => '9:16 Reels',
        VideoAspect.square => '1:1',
        VideoAspect.landscape => '16:9',
      };

  String get id => switch (this) {
        VideoAspect.reel => '9:16',
        VideoAspect.square => '1:1',
        VideoAspect.landscape => '16:9',
      };

  double get ratio => switch (this) {
        VideoAspect.reel => 9 / 16,
        VideoAspect.square => 1,
        VideoAspect.landscape => 16 / 9,
      };

  static VideoAspect fromId(String id) => switch (id) {
        '1:1' => VideoAspect.square,
        '16:9' => VideoAspect.landscape,
        _ => VideoAspect.reel,
      };
}
