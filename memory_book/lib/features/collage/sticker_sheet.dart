import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../domain/collage_craft.dart';
import 'sticker_painters.dart';

typedef StickerChoice = ({StickerKind kind, String? text});

Future<StickerChoice?> pickSticker(BuildContext context) {
  return showModalBottomSheet<StickerChoice>(
    context: context,
    isScrollControlled: true,
    backgroundColor: MbTokens.cream,
    builder: (ctx) => Theme(
      data: MbTheme.studio,
      child: const _StickerSheet(),
    ),
  );
}

class _StickerSheet extends StatefulWidget {
  const _StickerSheet();

  @override
  State<_StickerSheet> createState() => _StickerSheetState();
}

class _StickerSheetState extends State<_StickerSheet> {
  final _word = TextEditingController();

  @override
  void dispose() {
    _word.dispose();
    super.dispose();
  }

  List<StickerChoice> _choices(StickerGroup group) => switch (group) {
        StickerGroup.words => [
            for (final word in StickerSets.words) (kind: StickerKind.word, text: word),
          ],
        StickerGroup.emoji => [
            for (final glyph in StickerSets.emoji) (kind: StickerKind.emoji, text: glyph),
          ],
        _ => [
            for (final kind in StickerKind.values)
              if (kind.group == group) (kind: kind, text: null),
          ],
      };

  @override
  Widget build(BuildContext context) {
    final groups = StickerGroup.values;
    return DefaultTabController(
      length: groups.length,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MbTokens.linen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            TabBar(
              labelColor: MbTokens.leather,
              unselectedLabelColor: MbTokens.inkSoft,
              indicatorColor: MbTokens.leather,
              tabs: [
                for (final group in groups) Tab(text: _title(group)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  for (final group in groups) _grid(group),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title(StickerGroup group) => switch (group) {
        StickerGroup.paper => 'Paper',
        StickerGroup.doodles => 'Doodles',
        StickerGroup.words => 'Words',
        StickerGroup.emoji => 'Emoji',
      };

  Widget _grid(StickerGroup group) {
    final choices = _choices(group);
    final words = group == StickerGroup.words;
    return CustomScrollView(
      slivers: [
        if (words)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _word,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 24,
                decoration: InputDecoration(
                  labelText: 'Your own words',
                  suffixIcon: IconButton(
                    tooltip: 'Add',
                    icon: const Icon(Icons.add_circle),
                    onPressed: _addWord,
                  ),
                ),
                onSubmitted: (_) => _addWord(),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: group == StickerGroup.emoji ? 6 : (words ? 3 : 4),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _tile(choices[i]),
              childCount: choices.length,
            ),
          ),
        ),
      ],
    );
  }

  void _addWord() {
    final text = _word.text.trim();
    if (text.isEmpty) return;
    Navigator.pop<StickerChoice>(context, (kind: StickerKind.word, text: text));
  }

  Widget _tile(StickerChoice choice) {
    return Material(
      color: MbTokens.paper,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.pop<StickerChoice>(context, choice),
        child: Tooltip(
          message: choice.text ?? choice.kind.label,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomPaint(
              painter: StickerPainter(choice.kind, text: choice.text),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
