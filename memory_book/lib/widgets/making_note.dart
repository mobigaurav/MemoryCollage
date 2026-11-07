import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tokens.dart';
import '../services/reel_jobs.dart';

/// A small line, not a blocker: how many reels are still being made.
class MbMakingNote extends ConsumerWidget {
  const MbMakingNote({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(reelJobsProvider).length;
    if (count == 0) return const SizedBox.shrink();
    final ink = onDark ? MbTokens.cream : MbTokens.ink;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: onDark ? const Color(0xF21C1410) : MbTokens.glass,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: MbTokens.glassEdge),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: ink),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                count == 1 ? 'Making 1 reel' : 'Making $count reels',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: MbTokens.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
