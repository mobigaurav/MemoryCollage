import 'dart:ui';

import 'collage_craft.dart';
import 'collage_paper.dart';

class PackSticker {
  const PackSticker(this.kind, this.nx, this.ny, {this.text, this.scale = 1});

  final StickerKind kind;
  final String? text;
  final double nx;
  final double ny;
  final double scale;
}

/// One look for an occasion: the paper, a caption banner, and a few stickers.
class ThemePack {
  const ThemePack({
    required this.id,
    required this.name,
    required this.emoji,
    required this.paper,
    required this.color,
    required this.caption,
    required this.stickers,
    this.premium = true,
  });

  final String id;
  final String name;
  final String emoji;
  final CollagePaper paper;
  final Color color;
  final String caption;
  final List<PackSticker> stickers;
  final bool premium;

  List<PlacedSticker> placed({String? caption}) => [
        for (final s in stickers)
          PlacedSticker(
            kind: s.kind,
            text: s.text,
            nx: s.nx,
            ny: s.ny,
            scale: s.scale,
            pack: true,
          ),
        PlacedSticker(
          kind: StickerKind.word,
          text: caption ?? this.caption,
          nx: 0.5,
          ny: 0.92,
          scale: 1.6,
          pack: true,
        ),
      ];
}

abstract final class ThemePacks {
  static final all = <ThemePack>[
    const ThemePack(
      id: 'everyday',
      name: 'Everyday',
      emoji: '☕️',
      paper: CollagePaper.linen,
      color: Color(0xFFEDE3D2),
      caption: 'Little moments',
      premium: false,
      stickers: [
        PackSticker(StickerKind.tape, 0.12, 0.06),
        PackSticker(StickerKind.sparkle, 0.9, 0.08, scale: 0.7),
      ],
    ),
    const ThemePack(
      id: 'travel',
      name: 'Travel',
      emoji: '✈️',
      paper: CollagePaper.kraft,
      color: Color(0xFFBF9A6E),
      caption: 'Wanderlust',
      premium: false,
      stickers: [
        PackSticker(StickerKind.ticket, 0.14, 0.08, scale: 0.9),
        PackSticker(StickerKind.postmark, 0.86, 0.1, scale: 0.9),
        PackSticker(StickerKind.place, 0.92, 0.8, scale: 0.6),
      ],
    ),
    const ThemePack(
      id: 'wedding',
      name: 'Wedding',
      emoji: '💍',
      paper: CollagePaper.watercolor,
      color: Color(0xFFE8C7B8),
      caption: 'Just married',
      stickers: [
        PackSticker(StickerKind.sparkle, 0.1, 0.08, scale: 0.7),
        PackSticker(StickerKind.emoji, 0.9, 0.08, text: '💍', scale: 0.6),
        PackSticker(StickerKind.heart, 0.9, 0.82, scale: 0.5),
      ],
    ),
    const ThemePack(
      id: 'baby',
      name: "Baby's first year",
      emoji: '👶',
      paper: CollagePaper.dots,
      color: Color(0xFFFBF6EE),
      caption: 'Hello little one',
      stickers: [
        PackSticker(StickerKind.moon, 0.1, 0.08, scale: 0.6),
        PackSticker(StickerKind.star, 0.22, 0.06, scale: 0.35),
        PackSticker(StickerKind.cloud, 0.86, 0.08, scale: 0.8),
      ],
    ),
    const ThemePack(
      id: 'birthday',
      name: 'Birthday',
      emoji: '🎂',
      paper: CollagePaper.plain,
      color: Color(0xFFF6E3E0),
      caption: 'Happy birthday',
      stickers: [
        PackSticker(StickerKind.confetti, 0.5, 0.07, scale: 1.4),
        PackSticker(StickerKind.balloon, 0.1, 0.12, scale: 0.8),
        PackSticker(StickerKind.crown, 0.88, 0.08, scale: 0.6),
      ],
    ),
    const ThemePack(
      id: 'diwali',
      name: 'Diwali',
      emoji: '🪔',
      paper: CollagePaper.chalk,
      color: Color(0xFF2E3833),
      caption: 'Happy Diwali',
      stickers: [
        PackSticker(StickerKind.emoji, 0.1, 0.08, text: '🪔', scale: 0.6),
        PackSticker(StickerKind.sparkle, 0.88, 0.08, scale: 0.7),
        PackSticker(StickerKind.star, 0.92, 0.78, scale: 0.35),
      ],
    ),
    const ThemePack(
      id: 'christmas',
      name: 'Christmas',
      emoji: '🎄',
      paper: CollagePaper.linen,
      color: Color(0xFFEDE3D2),
      caption: 'Merry Christmas',
      stickers: [
        PackSticker(StickerKind.emoji, 0.1, 0.08, text: '🎄', scale: 0.6),
        PackSticker(StickerKind.emoji, 0.9, 0.08, text: '❄️', scale: 0.5),
        PackSticker(StickerKind.star, 0.5, 0.05, scale: 0.35),
      ],
    ),
    ThemePack(
      id: 'graduation',
      name: 'Graduation',
      emoji: '🎓',
      paper: CollagePaper.notebook,
      color: const Color(0xFFFDFBF5),
      caption: 'Class of ${DateTime.now().year}',
      stickers: const [
        PackSticker(StickerKind.emoji, 0.1, 0.08, text: '🎓', scale: 0.6),
        PackSticker(StickerKind.crown, 0.88, 0.08, scale: 0.6),
      ],
    ),
    const ThemePack(
      id: 'love',
      name: 'Love',
      emoji: '❤️',
      paper: CollagePaper.watercolor,
      color: Color(0xFFD9867A),
      caption: 'Together',
      stickers: [
        PackSticker(StickerKind.heart, 0.1, 0.08, scale: 0.5),
        PackSticker(StickerKind.heart, 0.9, 0.1, scale: 0.35),
        PackSticker(StickerKind.scribble, 0.86, 0.84, scale: 0.6),
      ],
    ),
    const ThemePack(
      id: 'summer',
      name: 'Summer',
      emoji: '🏖️',
      paper: CollagePaper.watercolor,
      color: Color(0xFF8FB3C9),
      caption: 'Summer',
      stickers: [
        PackSticker(StickerKind.sun, 0.88, 0.08, scale: 0.8),
        PackSticker(StickerKind.leaf, 0.08, 0.1, scale: 0.6),
      ],
    ),
    const ThemePack(
      id: 'home',
      name: 'Home',
      emoji: '🏡',
      paper: CollagePaper.cork,
      color: Color(0xFFC39A6B),
      caption: 'Home',
      stickers: [
        PackSticker(StickerKind.pin, 0.12, 0.05, scale: 0.5),
        PackSticker(StickerKind.pin, 0.88, 0.05, scale: 0.5),
        PackSticker(StickerKind.clip, 0.5, 0.04, scale: 0.5),
      ],
    ),
    const ThemePack(
      id: 'new-year',
      name: 'New Year',
      emoji: '🎉',
      paper: CollagePaper.plain,
      color: Color(0xFFF3E4C8),
      caption: 'New year',
      stickers: [
        PackSticker(StickerKind.confetti, 0.5, 0.07, scale: 1.3),
        PackSticker(StickerKind.sparkle, 0.12, 0.08, scale: 0.7),
        PackSticker(StickerKind.star, 0.88, 0.08, scale: 0.4),
      ],
    ),
    const ThemePack(
      id: 'anniversary',
      name: 'Anniversary',
      emoji: '💐',
      paper: CollagePaper.watercolor,
      color: Color(0xFFE8C7B8),
      caption: 'Our day',
      stickers: [
        PackSticker(StickerKind.heart, 0.1, 0.08, scale: 0.5),
        PackSticker(StickerKind.sparkle, 0.88, 0.08, scale: 0.6),
        PackSticker(StickerKind.heart, 0.9, 0.82, scale: 0.35),
      ],
    ),
    const ThemePack(
      id: 'spring',
      name: 'Spring',
      emoji: '🌸',
      paper: CollagePaper.watercolor,
      color: Color(0xFFD7E2D3),
      caption: 'In bloom',
      stickers: [
        PackSticker(StickerKind.flower, 0.1, 0.08, scale: 0.7),
        PackSticker(StickerKind.sun, 0.88, 0.08, scale: 0.7),
        PackSticker(StickerKind.leaf, 0.9, 0.82, scale: 0.5),
      ],
    ),
    const ThemePack(
      id: 'autumn',
      name: 'Autumn',
      emoji: '🍂',
      paper: CollagePaper.kraft,
      color: Color(0xFFBF9A6E),
      caption: 'Golden days',
      stickers: [
        PackSticker(StickerKind.leaf, 0.1, 0.08, scale: 0.7),
        PackSticker(StickerKind.leaf, 0.9, 0.1, scale: 0.45),
        PackSticker(StickerKind.sun, 0.88, 0.8, scale: 0.6),
      ],
    ),
    const ThemePack(
      id: 'party',
      name: 'Party',
      emoji: '🎈',
      paper: CollagePaper.plain,
      color: Color(0xFFF6E3E0),
      caption: "Let's celebrate",
      stickers: [
        PackSticker(StickerKind.balloon, 0.1, 0.1, scale: 0.8),
        PackSticker(StickerKind.confetti, 0.5, 0.06, scale: 1.2),
        PackSticker(StickerKind.crown, 0.88, 0.08, scale: 0.6),
      ],
    ),
    const ThemePack(
      id: 'friends',
      name: 'Friends',
      emoji: '🤍',
      paper: CollagePaper.notebook,
      color: Color(0xFFFDFBF5),
      caption: 'Good company',
      stickers: [
        PackSticker(StickerKind.tape, 0.12, 0.05),
        PackSticker(StickerKind.heart, 0.88, 0.08, scale: 0.4),
        PackSticker(StickerKind.star, 0.9, 0.8, scale: 0.35),
      ],
    ),
    const ThemePack(
      id: 'thanks',
      name: 'Thank you',
      emoji: '🙏',
      paper: CollagePaper.dots,
      color: Color(0xFFFBF6EE),
      caption: 'Thank you',
      stickers: [
        PackSticker(StickerKind.heart, 0.1, 0.08, scale: 0.4),
        PackSticker(StickerKind.flower, 0.88, 0.08, scale: 0.6),
      ],
    ),
    const ThemePack(
      id: 'film',
      name: 'On film',
      emoji: '🎞️',
      paper: CollagePaper.plain,
      color: Color(0xFF1C1410),
      caption: 'On film',
      stickers: [
        PackSticker(StickerKind.film, 0.14, 0.08, scale: 0.8),
        PackSticker(StickerKind.date, 0.86, 0.08, scale: 0.7),
      ],
    ),
    const ThemePack(
      id: 'holi',
      name: 'Holi',
      emoji: '🌈',
      paper: CollagePaper.watercolor,
      color: Color(0xFFE7B7D4),
      caption: 'Happy Holi',
      stickers: [
        PackSticker(StickerKind.confetti, 0.5, 0.07, scale: 1.3),
        PackSticker(StickerKind.sparkle, 0.12, 0.08, scale: 0.7),
        PackSticker(StickerKind.flower, 0.88, 0.1, scale: 0.6),
      ],
    ),
    const ThemePack(
      id: 'eid',
      name: 'Eid',
      emoji: '🌙',
      paper: CollagePaper.linen,
      color: Color(0xFFF7F1E8),
      caption: 'Eid Mubarak',
      stickers: [
        PackSticker(StickerKind.moon, 0.1, 0.08, scale: 0.7),
        PackSticker(StickerKind.star, 0.22, 0.06, scale: 0.35),
        PackSticker(StickerKind.sparkle, 0.88, 0.08, scale: 0.6),
      ],
    ),
  ];

  static ThemePack? byId(String? id) {
    for (final pack in all) {
      if (pack.id == id) return pack;
    }
    return null;
  }
}
