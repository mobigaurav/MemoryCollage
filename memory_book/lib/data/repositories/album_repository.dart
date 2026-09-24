import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/book_models.dart';
import '../../domain/book_ops.dart';
import '../db/app_database.dart';

class PageDetail {
  PageDetail({required this.page, required this.slots});
  final BookPage page;
  final List<PhotoSlot> slots;

  PageLayoutId get layout => PageLayoutId.fromId(page.layoutId);
}

class AlbumDetail {
  AlbumDetail({required this.album, required this.pages});
  final Album album;
  final List<PageDetail> pages;

  BookCoverTheme get theme => BookCoverTheme.fromId(album.themeId);
  int get spreadCount => (pages.length / 2).ceil();
}

class AlbumRepository {
  AlbumRepository(this._db);
  final AppDatabase _db;
  final _uuid = const Uuid();

  Stream<List<Album>> watchAll() {
    return (_db.select(_db.albums)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<AlbumDetail?> getDetail(String id) async {
    final album = await (_db.select(_db.albums)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (album == null) return null;
    final pages = await (_db.select(_db.bookPages)
          ..where((t) => t.albumId.equals(id))
          ..orderBy([(t) => OrderingTerm.asc(t.pageIndex)]))
        .get();
    final details = <PageDetail>[];
    for (final page in pages) {
      final slots = await (_db.select(_db.photoSlots)
            ..where((t) => t.pageId.equals(page.id))
            ..orderBy([(t) => OrderingTerm.asc(t.slotIndex)]))
          .get();
      details.add(PageDetail(page: page, slots: slots));
    }
    return AlbumDetail(album: album, pages: details);
  }

  Stream<AlbumDetail?> watchDetail(String id) async* {
    yield await getDetail(id);
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.albums,
            _db.bookPages,
            _db.photoSlots,
          ]),
        )
        .asyncMap((_) => getDetail(id));
  }

  Future<Album> createAlbum({
    required String title,
    BookCoverTheme theme = BookCoverTheme.leather,
    int pageCount = 4,
    String? coverPhotoPath,
    DateTime? dateStart,
    DateTime? dateEnd,
  }) async {
    final now = DateTime.now();
    final album = AlbumsCompanion.insert(
      id: _uuid.v4(),
      title: title,
      themeId: Value(theme.name),
      coverPhotoPath: Value(coverPhotoPath),
      createdAt: now,
      updatedAt: now,
      dateStart: Value(dateStart),
      dateEnd: Value(dateEnd),
    );
    await _db.into(_db.albums).insert(album);
    final evenCount = pageCount.isEven ? pageCount : pageCount + 1;
    for (var i = 0; i < evenCount; i++) {
      await insertPage(albumId: album.id.value, index: i);
    }
    return (await getDetail(album.id.value))!.album;
  }

  Future<BookPage> insertPage({
    required String albumId,
    required int index,
    PageLayoutId layout = PageLayoutId.full,
  }) async {
    final pageId = _uuid.v4();
    await _db.into(_db.bookPages).insert(
          BookPagesCompanion.insert(
            id: pageId,
            albumId: albumId,
            pageIndex: index,
            layoutId: Value(layout.name),
          ),
        );
    await _ensureSlots(pageId, layout);
    await _touch(albumId);
    return (await (_db.select(_db.bookPages)..where((t) => t.id.equals(pageId)))
        .getSingle());
  }

  Future<void> addBlankSpread(String albumId) async {
    final detail = await getDetail(albumId);
    if (detail == null) return;
    final start = detail.pages.length;
    await insertPage(albumId: albumId, index: start, layout: PageLayoutId.blank);
    await insertPage(
      albumId: albumId,
      index: start + 1,
      layout: PageLayoutId.blank,
    );
  }

  Future<void> movePage(String albumId, int from, int to) async {
    final pages = await (_db.select(_db.bookPages)
          ..where((t) => t.albumId.equals(albumId))
          ..orderBy([(t) => OrderingTerm.asc(t.pageIndex)]))
        .get();
    if (from == to || from < 0 || from >= pages.length) return;
    final dest = to.clamp(0, pages.length - 1);
    final reordered = moveItem(pages, from, dest);
    for (var i = 0; i < reordered.length; i++) {
      if (reordered[i].pageIndex != i) {
        await (_db.update(_db.bookPages)
              ..where((t) => t.id.equals(reordered[i].id)))
            .write(BookPagesCompanion(pageIndex: Value(i)));
      }
    }
    await _touch(albumId);
  }

  Future<void> duplicatePage(String pageId) async {
    final page = await (_db.select(_db.bookPages)
          ..where((t) => t.id.equals(pageId)))
        .getSingleOrNull();
    if (page == null) return;
    final later = await (_db.select(_db.bookPages)
          ..where(
            (t) =>
                t.albumId.equals(page.albumId) &
                t.pageIndex.isBiggerThanValue(page.pageIndex),
          ))
        .get();
    for (final other in later) {
      await (_db.update(_db.bookPages)..where((t) => t.id.equals(other.id)))
          .write(BookPagesCompanion(pageIndex: Value(other.pageIndex + 1)));
    }
    final newId = _uuid.v4();
    await _db.into(_db.bookPages).insert(
          BookPagesCompanion.insert(
            id: newId,
            albumId: page.albumId,
            pageIndex: page.pageIndex + 1,
            layoutId: Value(page.layoutId),
          ),
        );
    final slots = await (_db.select(_db.photoSlots)
          ..where((t) => t.pageId.equals(page.id)))
        .get();
    for (final slot in slots) {
      await _db.into(_db.photoSlots).insert(
            PhotoSlotsCompanion.insert(
              id: _uuid.v4(),
              pageId: newId,
              slotIndex: slot.slotIndex,
              imagePath: Value(slot.imagePath),
              caption: Value(slot.caption),
              scale: Value(slot.scale),
              offsetX: Value(slot.offsetX),
              offsetY: Value(slot.offsetY),
              filterId: Value(slot.filterId),
              showDate: Value(slot.showDate),
            ),
          );
    }
    await _touch(page.albumId);
  }

  /// Returns false when the book would drop below one spread.
  Future<bool> deletePage(String pageId) async {
    final page = await (_db.select(_db.bookPages)
          ..where((t) => t.id.equals(pageId)))
        .getSingleOrNull();
    if (page == null) return false;
    final count = await (_db.select(_db.bookPages)
          ..where((t) => t.albumId.equals(page.albumId)))
        .get();
    if (count.length <= 2) return false;
    await (_db.delete(_db.photoSlots)..where((t) => t.pageId.equals(pageId)))
        .go();
    await (_db.delete(_db.bookPages)..where((t) => t.id.equals(pageId))).go();
    await _reindex(page.albumId);
    await _touch(page.albumId);
    return true;
  }

  Future<int> fillEmptySlots(
    String albumId,
    List<String> paths, {
    bool addPages = true,
  }) async {
    var used = 0;
    Future<void> consume(AlbumDetail detail) async {
      for (final page in detail.pages) {
        for (final slot in page.slots) {
          if (used >= paths.length) return;
          if (slot.imagePath != null) continue;
          await updateSlot(
            PhotoSlotsCompanion(
              id: Value(slot.id),
              imagePath: Value(paths[used]),
            ),
          );
          used++;
        }
      }
    }

    var detail = await getDetail(albumId);
    if (detail == null) return 0;
    await consume(detail);
    while (addPages && used < paths.length) {
      await addBlankSpread(albumId);
      detail = await getDetail(albumId);
      if (detail == null) break;
      await consume(detail);
    }
    if (used > 0 && detail?.album.coverPhotoPath == null) {
      await setCover(albumId, paths.first);
    }
    await _touch(albumId);
    return used;
  }

  Future<void> _reindex(String albumId) async {
    final pages = await (_db.select(_db.bookPages)
          ..where((t) => t.albumId.equals(albumId))
          ..orderBy([(t) => OrderingTerm.asc(t.pageIndex)]))
        .get();
    for (var i = 0; i < pages.length; i++) {
      if (pages[i].pageIndex != i) {
        await (_db.update(_db.bookPages)..where((t) => t.id.equals(pages[i].id)))
            .write(BookPagesCompanion(pageIndex: Value(i)));
      }
    }
  }

  Future<void> setLayout(String pageId, PageLayoutId layout) async {
    await (_db.update(_db.bookPages)..where((t) => t.id.equals(pageId)))
        .write(BookPagesCompanion(layoutId: Value(layout.name)));
    await _ensureSlots(pageId, layout);
  }

  Future<void> updateSlot(PhotoSlotsCompanion data) async {
    await (_db.update(_db.photoSlots)..where((t) => t.id.equals(data.id.value)))
        .write(data);
  }

  Future<void> setCover(String albumId, String? path) async {
    await (_db.update(_db.albums)..where((t) => t.id.equals(albumId))).write(
      AlbumsCompanion(
        coverPhotoPath: Value(path),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> rename(String albumId, String title) async {
    await (_db.update(_db.albums)..where((t) => t.id.equals(albumId))).write(
      AlbumsCompanion(title: Value(title), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> setTheme(String albumId, BookCoverTheme theme) async {
    await (_db.update(_db.albums)..where((t) => t.id.equals(albumId))).write(
      AlbumsCompanion(
        themeId: Value(theme.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteAlbum(String id) async {
    final pages = await (_db.select(_db.bookPages)
          ..where((t) => t.albumId.equals(id)))
        .get();
    for (final page in pages) {
      await (_db.delete(_db.photoSlots)..where((t) => t.pageId.equals(page.id)))
          .go();
    }
    await (_db.delete(_db.bookPages)..where((t) => t.albumId.equals(id))).go();
    await (_db.delete(_db.albums)..where((t) => t.id.equals(id))).go();
  }

  Future<int> count() async {
    final rows = await _db.select(_db.albums).get();
    return rows.length;
  }

  Future<void> _ensureSlots(String pageId, PageLayoutId layout) async {
    final existing = await (_db.select(_db.photoSlots)
          ..where((t) => t.pageId.equals(pageId)))
        .get();
    for (final slot in existing) {
      if (slot.slotIndex >= layout.slotCount) {
        await (_db.delete(_db.photoSlots)..where((t) => t.id.equals(slot.id)))
            .go();
      }
    }
    for (var i = 0; i < layout.slotCount; i++) {
      final found = existing.where((s) => s.slotIndex == i);
      if (found.isEmpty) {
        await _db.into(_db.photoSlots).insert(
              PhotoSlotsCompanion.insert(
                id: _uuid.v4(),
                pageId: pageId,
                slotIndex: i,
              ),
            );
      }
    }
  }

  Future<void> _touch(String albumId) async {
    await (_db.update(_db.albums)..where((t) => t.id.equals(albumId))).write(
          AlbumsCompanion(updatedAt: Value(DateTime.now())),
        );
  }
}
