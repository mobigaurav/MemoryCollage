import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../data/db/app_database.dart';
import '../book/page_canvas.dart';

/// Books standing on wooden planks, three to a shelf.
class BookShelf extends StatelessWidget {
  const BookShelf({
    super.key,
    required this.albums,
    required this.onOpen,
    required this.onEdit,
  });

  final List<Album> albums;
  final ValueChanged<Album> onOpen;
  final ValueChanged<Album> onEdit;

  @override
  Widget build(BuildContext context) {
    final rows = <List<Album>>[];
    if (albums.isEmpty) {
      rows.add(const []);
    }
    for (var i = 0; i < albums.length; i += 3) {
      final end = i + 3 > albums.length ? albums.length : i + 3;
      rows.add(albums.sublist(i, end));
    }
    return Column(
      children: [
        for (final row in rows) ...[
          _ShelfRow(albums: row, onOpen: onOpen, onEdit: onEdit),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _ShelfRow extends StatelessWidget {
  const _ShelfRow({
    required this.albums,
    required this.onOpen,
    required this.onEdit,
  });

  final List<Album> albums;
  final ValueChanged<Album> onOpen;
  final ValueChanged<Album> onEdit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final bookWidth = (constraints.maxWidth - gap * 2) / 3;
        final bookHeight = albums.isEmpty ? 8.0 : bookWidth / MbTokens.pageAspect;
        return SizedBox(
          height: bookHeight + 22,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFC4A35A),
                        Color(0xFF6B3E24),
                        Color(0xFF3A2214),
                        Color(0xFF1C100A),
                      ],
                      stops: [0, 0.18, 0.72, 1],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      Expanded(
                        child: i < albums.length
                            ? _StandingBook(
                                album: albums[i],
                                onOpen: () => onOpen(albums[i]),
                                onEdit: () => onEdit(albums[i]),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StandingBook extends StatelessWidget {
  const _StandingBook({
    required this.album,
    required this.onOpen,
    required this.onEdit,
  });

  final Album album;
  final VoidCallback onOpen;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BookCoverView(album: album, onOpen: onOpen, onLongPress: onEdit),
        Positioned(
          top: 4,
          right: 2,
          child: IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: MbTokens.leatherDark.withValues(alpha: 0.82),
              foregroundColor: MbTokens.cream,
              minimumSize: const Size(44, 44),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            tooltip: 'Edit book',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 16),
          ),
        ),
      ],
    );
  }
}
