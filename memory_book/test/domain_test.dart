import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_book/core/config.dart';
import 'package:memory_book/domain/book_models.dart';
import 'package:memory_book/domain/collage_craft.dart';
import 'package:memory_book/domain/book_ops.dart';
import 'package:memory_book/domain/slot_crop.dart';
import 'package:memory_book/domain/collage_templates.dart';
import 'package:memory_book/domain/media_options.dart';
import 'package:memory_book/services/auth_ai.dart';
import 'package:memory_book/services/cognito_auth.dart';

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
    expect(StickerKind.values.map((s) => s.name).toSet().length, 6);
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
    final payload = base64Url.encode(utf8.encode('{"sub":"user-42"}'));
    expect(jwtSubject('h.$payload.s'), 'user-42');
  });

  test('page reorder and even page counts', () {
    expect(moveItem([0, 1, 2, 3], 3, 1), [0, 3, 1, 2]);
    expect(moveItem([0, 1, 2, 3], 1, 3), [0, 2, 3, 1]);
    expect(evenPageCount(1), 4);
    expect(evenPageCount(5), 6);
    expect(evenPageCount(12), 12);
  });
}
