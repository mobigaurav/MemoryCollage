import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../domain/collage_paper.dart';
import '../../domain/theme_packs.dart';
import 'paper_painter.dart';

typedef BackgroundChoice = ({CollagePaper paper, Color color});

Future<ThemePack?> pickThemePack(BuildContext context, {String? current}) {
  return showModalBottomSheet<ThemePack>(
    context: context,
    isScrollControlled: true,
    backgroundColor: MbTokens.cream,
    builder: (ctx) => SizedBox(
      height: MediaQuery.sizeOf(ctx).height * 0.62,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Text(
              'Themes',
              style: TextStyle(fontFamily: MbTokens.serif, fontSize: 26, color: MbTokens.ink),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Paper, a caption and a few stickers. Your photos stay put.',
              style: TextStyle(color: MbTokens.inkSoft),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: ThemePacks.all.length,
              itemBuilder: (context, i) {
                final pack = ThemePacks.all[i];
                return _PackTile(
                  pack: pack,
                  selected: pack.id == current,
                  onTap: () => Navigator.pop(ctx, pack),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _PackTile extends StatelessWidget {
  const _PackTile({required this.pack, required this.selected, required this.onTap});

  final ThemePack pack;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = pack.paper == CollagePaper.chalk;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? MbTokens.leather : MbTokens.glassEdge,
                  width: selected ? 2 : 1,
                ),
              ),
              child: CustomPaint(
                painter: PaperPainter(pack.paper, pack.color),
                child: Stack(
                  children: [
                    Center(child: Text(pack.emoji, style: const TextStyle(fontSize: 34))),
                    Positioned(
                      left: 6,
                      right: 6,
                      bottom: 8,
                      child: Text(
                        pack.caption,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: MbTokens.serif,
                          fontSize: 14,
                          color: dark ? MbTokens.cream : MbTokens.ink,
                        ),
                      ),
                    ),
                    if (pack.premium)
                      const Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(Icons.workspace_premium, size: 16, color: MbTokens.foil),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pack.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: MbTokens.sans,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MbTokens.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Papers first, then colors. A color tints Plain and Watercolor; on other papers it switches to Plain.
Future<BackgroundChoice?> pickBackground(
  BuildContext context, {
  required CollagePaper paper,
  required Color color,
  required bool premium,
}) {
  return showModalBottomSheet<BackgroundChoice>(
    context: context,
    backgroundColor: MbTokens.cream,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paper', style: TextStyle(fontWeight: FontWeight.w600, color: MbTokens.ink)),
            const SizedBox(height: 10),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: CollagePaper.values.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final next = CollagePaper.values[i];
                  return GestureDetector(
                    onTap: () => Navigator.pop<BackgroundChoice>(ctx, (paper: next, color: color)),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: next == paper ? MbTokens.leather : MbTokens.glassEdge,
                              width: next == paper ? 2 : 1,
                            ),
                          ),
                          child: CustomPaint(
                            painter: PaperPainter(next, color),
                            child: next.premium && !premium
                                ? const Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.workspace_premium, size: 14, color: MbTokens.foil),
                                    ),
                                  )
                                : const SizedBox.expand(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(next.label, style: const TextStyle(fontSize: 11, color: MbTokens.inkSoft)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.w600, color: MbTokens.ink)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in MbTokens.collagePapers)
                  GestureDetector(
                    onTap: () => Navigator.pop<BackgroundChoice>(
                      ctx,
                      (paper: paper.usesColor ? paper : CollagePaper.plain, color: c),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: c == color ? MbTokens.leather : MbTokens.glassEdge,
                      child: CircleAvatar(radius: 19, backgroundColor: c),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
