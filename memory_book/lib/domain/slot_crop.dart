import 'dart:ui';

/// Pan/zoom stored on a photo slot. Offsets are normalized to the slot size
/// so a value of `0.1` is 10% of the frame. Matches [PageCanvas] + export.
class SlotCrop {
  const SlotCrop({
    this.scale = 1,
    this.offsetX = 0,
    this.offsetY = 0,
  });

  final double scale;
  final double offsetX;
  final double offsetY;

  static const minScale = 0.2;
  static const maxScale = 4.0;

  /// Size of the photo when it just covers the frame, before [scale].
  /// Scale `1` keeps that cover. Scale below `1` reveals more of the photo
  /// until the whole picture sits inside the frame.
  static Size coverSize({
    required double frameWidth,
    required double frameHeight,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (frameWidth <= 0 || frameHeight <= 0) {
      return Size(frameWidth, frameHeight);
    }
    if (imageWidth <= 0 || imageHeight <= 0) {
      return Size(frameWidth, frameHeight);
    }
    final imageAspect = imageWidth / imageHeight;
    final frameAspect = frameWidth / frameHeight;
    if (imageAspect > frameAspect) {
      return Size(frameHeight * imageAspect, frameHeight);
    }
    return Size(frameWidth, frameWidth / imageAspect);
  }

  /// Scale that shows the entire photo inside the frame.
  static double fitScale({
    required double frameWidth,
    required double frameHeight,
    required double imageWidth,
    required double imageHeight,
  }) {
    final cover = coverSize(
      frameWidth: frameWidth,
      frameHeight: frameHeight,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    if (cover.width <= 0 || cover.height <= 0) return 1;
    final fit = (frameWidth / cover.width) < (frameHeight / cover.height)
        ? frameWidth / cover.width
        : frameHeight / cover.height;
    return fit.clamp(minScale, 1.0);
  }

  double get maxPan => scale >= 1
      ? ((scale - 1) / 2).clamp(0.0, 1.2)
      : ((1 - scale) / 2).clamp(0.0, 0.5);

  SlotCrop clamp() {
    final pan = maxPan;
    return SlotCrop(
      scale: scale.clamp(minScale, maxScale),
      offsetX: offsetX.clamp(-pan, pan),
      offsetY: offsetY.clamp(-pan, pan),
    );
  }

  SlotCrop applyZoom(double factor) {
    return SlotCrop(
      scale: scale * factor,
      offsetX: offsetX,
      offsetY: offsetY,
    ).clamp();
  }

  /// Finger pinch is a small ratio. Stretch it so the photo actually reframes.
  SlotCrop applyGesture({
    required double scaleDelta,
    required double dxNorm,
    required double dyNorm,
  }) {
    final amplified = 1 + (scaleDelta - 1) * 2.4;
    return SlotCrop(
      scale: scale * amplified,
      offsetX: offsetX + dxNorm,
      offsetY: offsetY + dyNorm,
    ).clamp();
  }

  SlotCrop applyPan(double dxNorm, double dyNorm) {
    return SlotCrop(
      scale: scale,
      offsetX: offsetX + dxNorm,
      offsetY: offsetY + dyNorm,
    ).clamp();
  }

  static SlotCrop fromValues({
    required double scale,
    required double offsetX,
    required double offsetY,
  }) {
    return SlotCrop(scale: scale, offsetX: offsetX, offsetY: offsetY).clamp();
  }
}
