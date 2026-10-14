import 'package:flutter/material.dart';

import '../core/nav.dart';
import '../core/theme/tokens.dart';

/// Full-width leather band. Same job as Arogya's profile and sign-in hero.
class MbHero extends StatelessWidget {
  const MbHero({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.onBack,
    this.child,
    this.footer,
    this.fill = false,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? child;
  final String? footer;

  /// Stretch the leather to the space the parent gives it.
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MbTokens.leather,
      child: Stack(
        fit: fill ? StackFit.expand : StackFit.loose,
        children: [
          const Positioned(
            top: -80,
            right: -60,
            child: IgnorePointer(
              child: _Halo(size: 240, color: Color(0x14FFFFFF)),
            ),
          ),
          const Positioned(
            bottom: -50,
            left: -40,
            child: IgnorePointer(
              child: _Halo(size: 160, color: Color(0x10C4A35A)),
            ),
          ),
          if (fill)
            Positioned.fill(child: _copy())
          else
            _copy(),
        ],
      ),
    );
  }

  Widget _copy() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onBack != null) ...[
              _Back(onBack: onBack!),
              const SizedBox(height: 18),
            ],
            Text(
              eyebrow.toUpperCase(),
              style: const TextStyle(
                fontFamily: MbTokens.sans,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: Color(0xD9F3E6D0),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontFamily: MbTokens.serif,
                fontSize: 36,
                height: 1.05,
                color: MbTokens.cream,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontFamily: MbTokens.sans,
                  fontSize: 17,
                  height: 1.4,
                  color: Color(0xE6FAF4E8),
                ),
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: 20),
              child!,
            ],
            if (fill && footer != null) ...[
              const Spacer(),
              Text(
                footer!,
                style: const TextStyle(
                  fontFamily: MbTokens.sans,
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xB3F3E6D0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x24FFFFFF),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onBack,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back, color: MbTokens.cream),
        ),
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Cream button that sits on the leather band.
ButtonStyle mbInverseButton() {
  return FilledButton.styleFrom(
    backgroundColor: MbTokens.cream,
    foregroundColor: MbTokens.leather,
    minimumSize: const Size.fromHeight(52),
    textStyle: const TextStyle(
      fontFamily: MbTokens.sans,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
  );
}

void mbPop(BuildContext context) => popToShelf(context);
