import 'dart:io';

import 'package:flutter/material.dart';

/// File image decoded at display size so page turns and taps stay responsive.
class LocalPhoto extends StatelessWidget {
  const LocalPhoto({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.cacheSize,
    this.width,
    this.height,
  });

  final String path;
  final BoxFit fit;
  final Size? cacheSize;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final logical = cacheSize?.width ?? width ?? 360;
    final cacheWidth = (logical * dpr).round().clamp(64, 1440);
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.low,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: Color(0x33000000),
      ),
    );
  }
}
