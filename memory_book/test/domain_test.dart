import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_book/core/config.dart';
import 'package:memory_book/domain/book_models.dart';
import 'package:memory_book/domain/collage_craft.dart';
import 'package:memory_book/domain/book_ops.dart';
import 'package:memory_book/domain/slot_crop.dart';
import 'package:memory_book/domain/collage_templates.dart';
import 'package:memory_book/domain/media_options.dart';
import 'package:memory_book/services/auth_ai.dart';
import 'package:memory_book/services/photo_files.dart';
import 'package:memory_book/services/cognito_auth.dart';
import 'package:memory_book/domain/year_film.dart';
import 'package:memory_book/services/reel_library.dart';
import 'package:memory_book/services/photo_service.dart';
import 'package:memory_book/domain/collage_paper.dart';
import 'package:memory_book/domain/collage_sizes.dart';
import 'package:memory_book/domain/event_pick.dart';
import 'package:memory_book/domain/family_collage.dart';
import 'package:memory_book/domain/theme_packs.dart';
import 'package:memory_book/features/collage/collage_studio_screen.dart';
import 'package:memory_book/features/memories/event_collage.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:photo_manager/photo_manager.dart';

void main() {
  test('catalog has a deep unique template library', () {
    final ids = CollageCatalog.all.map((t) => t.id).toSet();
    expect(CollageCatalog.all.length, greaterThanOrEqualTo(140));
    expect(CollageCatalog.inShelf(CollageShelf.grids).length, greaterThan(8));
    expect(ids.length, CollageCatalog.all.length);
  });

  test('premium templates are actually gated in config', () {
    final premium = CollageCatalog.all.where((t) => t.premium).map((t) => t.id);
    for (final id in premium) {
      expect(AppConfig.freeCollageTemplateIds.contains(id), isFalse);
    }
  });

  test('page layouts expose matching slot frames', () {
    for (final layout in PageLayoutId.values) {
      expect(layout.slots.length, layout.slotCount);
    }
  });

  test('video aspects are store-ready', () {
    expect(VideoAspect.reel.ratio, closeTo(9 / 16, 0.001));
    expect(VideoAspect.fromId('9:16'), VideoAspect.reel);
  });

  test('credit ledger math', () {
    var balance = 0;
    balance += 3;
    balance -= 1;
    expect(balance, 2);
    expect(AiJobResult(ok: false, fallbackToOnDevice: true).fallbackToOnDevice, isTrue);
  });

  test('free users are limited to three books', () {
    expect(AppConfig.freeAlbumLimit, 3);
  });

  test('slot crop clamps pan to the zoomed frame', () {
    final tight = const SlotCrop().applyPan(2, 2);
    expect(tight.offsetX.abs(), lessThanOrEqualTo(tight.maxPan));
    expect(tight.scale, 1);
    final zoomed = const SlotCrop().applyZoom(3).applyPan(2, 0);
    expect(zoomed.scale, 3);
    expect(zoomed.offsetX, closeTo(zoomed.maxPan, 0.0001));
    expect(const SlotCrop().applyZoom(10).scale, SlotCrop.maxScale);
    expect(const SlotCrop().applyZoom(0.1).scale, SlotCrop.minScale);
    final fit = SlotCrop.fitScale(
      frameWidth: 2,
      frameHeight: 1,
      imageWidth: 1,
      imageHeight: 2,
    );
    expect(fit, lessThan(1));
    expect(fit, greaterThanOrEqualTo(SlotCrop.minScale));
    final pinched = const SlotCrop().applyGesture(
      scaleDelta: 1.5,
      dxNorm: 0,
      dyNorm: 0,
    );
    expect(pinched.scale, greaterThan(1.8));
  });

  test('collage drafts and stickers round-trip', () {
    final draft = CollageDraft(
      templateId: 'freeform',
      background: 0xFFF3E6D0,
      photos: CollageDraft.layoutPhotos(['a.jpg', 'b.jpg']),
      stickers: [PlacedSticker(kind: StickerKind.film, nx: 0.2, ny: 0.3)],
      texts: [PlacedText(text: 'June')],
    );
    final copy = CollageDraft.fromJson(draft.toJson());
    expect(copy!.photos.length, 2);
    expect(copy.stickers.single.kind, StickerKind.film);
    expect(copy.texts.single.text, 'June');
    expect(StickerKind.values.map((s) => s.name).toSet().length, StickerKind.values.length);
    for (final group in StickerGroup.values) {
      expect(StickerKind.values.where((s) => s.group == group), isNotEmpty);
    }
    final word = PlacedSticker.fromJson(
      PlacedSticker(kind: StickerKind.word, text: 'Best day').toJson(),
    );
    expect(word.text, 'Best day');
  });

  test('cognito errors stay readable', () {
    expect(
      friendlyCognitoError('UserNotConfirmedException'),
      contains('Confirm the code'),
    );
    expect(
      friendlyCognitoError('NotAuthorizedException'),
      'That email or password does not match.',
    );
    expect(
      friendlyCognitoError(
        'Cannot reset password for the user as there is no registered/verified email',
      ),
      contains('Confirm the code'),
    );
    expect(
      friendlyCognitoError('ExpiredCodeException'),
      contains('expired'),
    );
    final payload = base64Url.encode(
      utf8.encode('{"sub":"user-42","email_verified":true}'),
    );
    expect(jwtSubject('h.$payload.s'), 'user-42');
    expect(jwtEmailVerified('h.$payload.s'), isTrue);
    final unverified = base64Url.encode(
      utf8.encode('{"sub":"user-7","email_verified":false}'),
    );
    expect(jwtEmailVerified('h.$unverified.s'), isFalse);
  });

  test('page reorder and even page counts', () {
    expect(moveItem([0, 1, 2, 3], 3, 1), [0, 3, 1, 2]);
    expect(moveItem([0, 1, 2, 3], 1, 3), [0, 2, 3, 1]);
    expect(evenPageCount(1), 4);
    expect(evenPageCount(5), 6);
    expect(evenPageCount(12), 12);
  });

  test('a moved container still finds a photo by its file name', () {
    final root = Directory.systemTemp.createTempSync('mb_photos');
    final photos = Directory('${root.path}/photos')..createSync();
    final file = File('${photos.path}/kept.jpg')..writeAsStringSync('jpg');
    PhotoFiles.documentsRoot = root.path;
    expect(
      PhotoFiles.resolve('/var/old-container/Documents/photos/kept.jpg'),
      file.path,
    );
    expect(PhotoFiles.resolve('photos/kept.jpg'), file.path);
    root.deleteSync(recursive: true);
    PhotoFiles.documentsRoot = null;
  });

  test('Cognito social sign-in asks the hosted UI for that provider', () {
    final uri = cognitoAuthorizeUri(
      host: 'memorybook-dev.auth.us-east-1.amazoncognito.com',
      clientId: 'client',
      redirectUri: AppConfig.cognitoRedirectUri,
      identityProvider: 'Google',
      codeChallenge: cognitoCodeChallenge('verifier'),
    );
    expect(uri.host, 'memorybook-dev.auth.us-east-1.amazoncognito.com');
    expect(uri.path, '/oauth2/authorize');
    expect(uri.queryParameters['identity_provider'], 'Google');
    expect(uri.queryParameters['redirect_uri'], 'memorybook://auth');
    expect(uri.queryParameters['code_challenge_method'], 'S256');
    expect(
      cognitoAuthorizationCode(Uri.parse('memorybook://auth?code=abc')),
      'abc',
    );
    expect(
      () => cognitoAuthorizationCode(
        Uri.parse('memorybook://auth?error=invalid_request'),
      ),
      throwsA(
        predicate(
          (e) => e is StateError && e.message.contains('Cognito does not have'),
        ),
      ),
    );
  });

  test('unnamed reels get a number and stay unique', () {
    ReelRecord clip(String id, String title) => ReelRecord(
          id: id,
          title: title,
          fileName: '$id.mp4',
          createdAt: DateTime.utc(2026, 1, int.parse(id)),
          kind: 'ai',
        );
    final settled = settleReelTitles([
      clip('3', 'AI clip'),
      clip('1', 'AI clip'),
      clip('2', 'AI clip'),
    ]);
    expect(settled.map((row) => row.title).toList(), [
      'AI clip 3',
      'AI clip 1',
      'AI clip 2',
    ]);
    expect(nextReelTitle(settled, 'AI clip'), 'AI clip 4');
    expect(nextReelTitle(settled, 'Sunday picnic'), 'Sunday picnic');
    expect(
      nextReelTitle([...settled, clip('4', 'Sunday picnic')], 'Sunday picnic'),
      'Sunday picnic (2)',
    );
  });

  test('a year film keeps an even path and prefers a full year', () {
    expect(takeEvenly([1, 2, 3], 24), [1, 2, 3]);
    expect(takeEvenly(List.generate(80, (i) => i), 24).length, 24);
    expect(takeEvenly(List.generate(80, (i) => i), 24).first, 0);
    expect(takeEvenly(List.generate(80, (i) => i), 24).last, 79);
    expect(
      yearWorthFilming({2026: 2, 2025: 12}, now: 2026),
      2025,
    );
    expect(yearWorthFilming({2026: 1, 2025: 2}, now: 2026), isNull);
  });

  test('on this day picks across the years, oldest first', () {
    AssetEntity a(String id) => AssetEntity(id: id, typeInt: 1, width: 1, height: 1);
    final day = OnThisDay(
      widened: false,
      years: [
        DayMemory(year: 2025, assets: [a('25a'), a('25b'), a('25c')]),
        DayMemory(year: 2020, assets: [a('20a')]),
      ],
    );
    expect(day.count, 4);
    expect(day.pick(3).map((e) => e.id), ['20a', '25a', '25b']);
    expect(day.pick(10).length, 4);
  });

  test('a seeded collage lands on a free layout that exists', () {
    for (var count = 1; count <= 9; count++) {
      final id = seedTemplateFor(count);
      final template = CollageCatalog.byId(id);
      expect(template.id, id);
      expect(template.premium, isFalse);
    }
  });

  test('an event keeps one frame per burst, drops screenshots, keeps favorites', () {
    final start = DateTime(2026, 10, 10, 9);
    EventPhoto<String> at(String id, int seconds,
            {int pixels = 100, bool favorite = false, bool screenshot = false}) =>
        EventPhoto(
          ref: id,
          taken: start.add(Duration(seconds: seconds)),
          pixels: pixels,
          favorite: favorite,
          screenshot: screenshot,
        );
    expect(
      pickEventPhotos([
        at('burst-small', 0),
        at('burst-big', 5, pixels: 400),
        at('burst-late', 20),
        at('screen', 600, screenshot: true),
        at('lunch', 3600),
      ]),
      ['burst-big', 'lunch'],
    );
    expect(
      pickEventPhotos([at('a', 0), at('b', 10, favorite: true)]),
      ['b'],
    );
    final day = [for (var i = 0; i < 40; i++) at('p$i', i * 600, favorite: i == 17)];
    final picked = pickEventPhotos(day);
    expect(picked.length, 9);
    expect(picked, contains('p17'));
    expect(picked.first, 'p0');
    expect(eventCollageSize(8), 6);
    expect(eventCollageSize(4), 4);
  });

  test('theme packs use real stickers and papers, and switching swaps only pack stickers', () {
    expect(ThemePacks.all.where((p) => !p.premium).length, greaterThanOrEqualTo(2));
    expect(ThemePacks.all.map((p) => p.id).toSet().length, ThemePacks.all.length);
    for (final pack in ThemePacks.all) {
      final placed = pack.placed();
      expect(placed.every((s) => s.pack), isTrue);
      expect(placed.last.text, pack.caption);
      for (final s in placed) {
        expect(s.nx, inInclusiveRange(0, 1));
        expect(s.ny, inInclusiveRange(0, 1));
      }
    }
    final mine = PlacedSticker(kind: StickerKind.heart);
    final round = PlacedSticker.fromJson(ThemePacks.byId('travel')!.placed().first.toJson());
    expect(round.pack, isTrue);
    expect(PlacedSticker.fromJson(mine.toJson()).pack, isFalse);
    final draft = CollageDraft.fromJson(
      CollageDraft(
        templateId: 'grid_2x2',
        background: 0,
        photos: const [],
        stickers: const [],
        texts: const [],
        paper: 'kraft',
        packId: 'travel',
      ).toJson(),
    )!;
    expect(CollagePaper.fromId(draft.paper), CollagePaper.kraft);
    expect(draft.packId, 'travel');
    expect(CollagePaper.fromId('nope'), CollagePaper.plain);
    final ink = PlacedInk.fromJson(
      PlacedInk(strokes: const [
        [InkDot(0.1, 0.2), InkDot(0.4, 0.8)],
      ]).toJson(),
    );
    expect(ink.strokes.single.last.x, 0.4);
    final voice = PlacedVoice.fromJson(PlacedVoice(url: 'https://example.test/v1/notes/1').toJson());
    expect(voice.url, endsWith('/1'));
  });

  test('print and instagram sizes keep their shape and their guides', () {
    expect(CollageSizes.byId('High').width, 2160);
    expect(CollageSizes.byId('High').premium, isTrue);
    expect(CollageSizes.byId('missing').id, 'High');
    final story = CollageSizes.instagramStory;
    expect(story.aspect, closeTo(1080 / 1920, 0.001));
    expect(story.safeTop, greaterThan(0));
    expect(story.safeBottom, greaterThan(story.safeTop));
    final photo = CollageSizes.print4x6;
    expect(photo.width, 1200);
    expect(photo.height, 1800);
    expect(photo.pageInchesWide, 4);
    expect(photo.hasSafeZone, isTrue);
    expect(CollageSizes.instagramSquare.hasSafeZone, isFalse);
    expect(CollageSizes.instagramPortrait.safeTop, closeTo(0.10, 0.001));
  });

  test('a family collage keeps empty frames open', () {
    expect(openCollageSlots(frameCount: 4, taken: [0, null, 2, 9]), [1, 3]);
    expect(openCollageSlots(frameCount: 2, taken: [0, 1]), isEmpty);
    final layout = SharedCollageLayout.fromJson({
      'templateId': 'grid_2x2',
      'background': 1,
      'paper': 'linen',
      'frames': 4,
      'packId': 'travel',
    })!;
    expect(SharedCollageLayout.fromJson(layout.toJson())!.packId, 'travel');
    expect(SharedCollageLayout.fromJson(null), isNull);
  });

  test('event labels read like a calendar', () {
    expect(
      eventLabel(DateTimeRange(start: DateTime(2026, 10, 12), end: DateTime(2026, 10, 14))),
      'Oct 12–14',
    );
    expect(
      eventLabel(DateTimeRange(start: DateTime(2026, 10, 30), end: DateTime(2026, 11, 2))),
      'Oct 30 – Nov 2',
    );
    final weekend = lastWeekend(DateTime(2026, 11, 6));
    expect(weekend.start, DateTime(2026, 10, 31));
    expect(weekend.end, DateTime(2026, 11, 1));
  });
}
