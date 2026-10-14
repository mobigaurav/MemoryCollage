import 'package:flutter/services.dart';

abstract final class MbHaptics {
  static void pageTurn() {
    HapticFeedback.mediumImpact();
  }

  static void rustle() {
    HapticFeedback.selectionClick();
    Future<void>.delayed(const Duration(milliseconds: 36), () {
      HapticFeedback.lightImpact();
    });
  }

  static void snap() {
    HapticFeedback.selectionClick();
  }

  static void success() {
    HapticFeedback.lightImpact();
  }
}
