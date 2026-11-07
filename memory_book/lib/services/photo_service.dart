import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:photo_manager/photo_manager.dart';
import 'package:uuid/uuid.dart';

import '../domain/event_pick.dart';
import 'photo_files.dart';

/// Photos taken around this date in one earlier year.
class DayMemory {
  const DayMemory({required this.year, required this.assets});

  final int year;
  final List<AssetEntity> assets;
}

class OnThisDay {
  const OnThisDay({required this.years, required this.widened});

  final List<DayMemory> years;

  /// True when the exact day was empty and the week around it was used.
  final bool widened;

  int get count => years.fold(0, (sum, y) => sum + y.assets.length);

  /// A few from every year, oldest first, so a collage spans the years.
  List<AssetEntity> pick(int limit) {
    final out = <AssetEntity>[];
    final ordered = years.reversed.toList();
    for (var round = 0; out.length < limit; round++) {
      var added = false;
      for (final year in ordered) {
        if (round < year.assets.length && out.length < limit) {
          out.add(year.assets[round]);
          added = true;
        }
      }
      if (!added) break;
    }
    return out;
  }
}

class PhotoService {
  PhotoService();

  /// Asks nothing. The On this day card waits for a tap before it asks.
  Future<bool> hasLibraryAccess() async {
    final state = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(),
    );
    return state.isAuth || state.hasAccess;
  }

  Future<bool> askLibraryAccess() async {
    final state = await PhotoManager.requestPermissionExtend();
    return state.isAuth || state.hasAccess;
  }

  Future<OnThisDay> onThisDay({DateTime? today, int yearsBack = 15}) async {
    final now = today ?? DateTime.now();
    var years = await _sameDay(now, yearsBack, 0);
    if (years.isNotEmpty) return OnThisDay(years: years, widened: false);
    years = await _sameDay(now, yearsBack, 3);
    return OnThisDay(years: years, widened: true);
  }

  Future<List<DayMemory>> _sameDay(DateTime now, int yearsBack, int spread) async {
    final out = <DayMemory>[];
    for (var back = 1; back <= yearsBack; back++) {
      final year = now.year - back;
      final day = DateTime(year, now.month, now.day);
      final option = FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        createTimeCond: DateTimeCond(
          min: day.subtract(Duration(days: spread)),
          max: day.add(Duration(days: spread + 1)).subtract(const Duration(seconds: 1)),
        ),
        orders: [const OrderOption(type: OrderOptionType.createDate, asc: true)],
      );
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: option,
      );
      if (albums.isEmpty) continue;
      final assets = await albums.first.getAssetListPaged(page: 0, size: 24);
      if (assets.isNotEmpty) out.add(DayMemory(year: year, assets: assets));
    }
    return out;
  }

  /// The best few photos from a stretch of days, chosen on the phone. Nothing is copied yet.
  Future<List<AssetEntity>> eventPhotos({
    required DateTime start,
    required DateTime end,
    int limit = 9,
  }) async {
    final option = FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      createTimeCond: DateTimeCond(
        min: DateTime(start.year, start.month, start.day),
        max: DateTime(end.year, end.month, end.day, 23, 59, 59),
      ),
      orders: [const OrderOption(type: OrderOptionType.createDate, asc: true)],
    );
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
      filterOption: option,
    );
    if (albums.isEmpty) return const [];
    final assets = await albums.first.getAssetListRange(start: 0, end: 400);
    final candidates = [
      for (final a in assets)
        EventPhoto(
          ref: a,
          taken: a.createDateTime,
          pixels: a.width * a.height,
          favorite: a.isFavorite,
          screenshot: (Platform.isIOS && a.subtype & 4 != 0) ||
              (a.relativePath?.toLowerCase().contains('screenshot') ?? false),
        ),
    ];
    final picked = pickEventPhotos(candidates, limit: limit);
    final tidy = eventCollageSize(picked.length);
    return tidy == picked.length ? picked : pickEventPhotos(candidates, limit: tidy);
  }

  /// Copies library photos into the app so a collage or film can keep them.
  Future<List<String>> keepAssets(List<AssetEntity> assets) async {
    final out = <String>[];
    for (final asset in assets) {
      final file = await asset.file;
      if (file != null) out.add(await persistPath(file.path));
    }
    return out;
  }

  final _picker = ImagePicker();
  final _uuid = const Uuid();

  Future<Directory> _dir() async {
    if (PhotoFiles.documentsRoot == null) await PhotoFiles.warm();
    final dir = Directory(p.join(PhotoFiles.documentsRoot!, 'photos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Relative path, so a later launch can find the file after the container moves.
  Future<String> persistPath(String sourcePath) async {
    final ext = p.extension(sourcePath);
    final name = '${_uuid.v4()}${ext.isEmpty ? '.jpg' : ext}';
    final dest = p.join((await _dir()).path, name);
    await File(sourcePath).copy(dest);
    return 'photos/$name';
  }

  Future<String> persistBytes(Uint8List bytes, {String ext = '.jpg'}) async {
    final name = '${_uuid.v4()}$ext';
    final dest = p.join((await _dir()).path, name);
    await File(dest).writeAsBytes(bytes);
    return 'photos/$name';
  }

  /// Camera dates from the library. Empty when the person says no.
  Future<List<String>> photosFromYear(int year, {int limit = 80}) async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) return const [];
    final from = DateTime(year);
    final to = DateTime(year, 12, 31, 23, 59, 59);
    final option = FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      createTimeCond: DateTimeCond(min: from, max: to),
      orders: [
        const OrderOption(type: OrderOptionType.createDate, asc: true),
      ],
    );
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
      filterOption: option,
    );
    if (albums.isEmpty) return const [];
    final out = <String>[];
    var page = 0;
    const pageSize = 40;
    while (out.length < limit) {
      final assets = await albums.first.getAssetListPaged(
        page: page,
        size: pageSize,
      );
      if (assets.isEmpty) break;
      for (final asset in assets) {
        if (out.length >= limit) break;
        final file = await asset.file;
        if (file != null) out.add(await persistPath(file.path));
      }
      if (assets.length < pageSize) break;
      page++;
    }
    return out;
  }

  Future<List<String>> pickImages({int limit = 15}) async {
    final files = await _picker.pickMultiImage(
      limit: limit,
      maxWidth: 2048,
      imageQuality: 85,
    );
    final paths = <String>[];
    for (final file in files) {
      paths.add(await persistPath(file.path));
    }
    return paths;
  }

  Future<String?> pickSingle() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (file == null) return null;
    return persistPath(file.path);
  }

  Future<List<String>> photosInDateRange({
    required DateTime start,
    required DateTime end,
    int limit = 40,
  }) async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) {
      return pickImages(limit: limit);
    }
    final from = DateTime(start.year, start.month, start.day);
    final to = DateTime(end.year, end.month, end.day, 23, 59, 59);
    final option = FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      createTimeCond: DateTimeCond(min: from, max: to),
      orders: [
        const OrderOption(type: OrderOptionType.createDate, asc: true),
      ],
    );
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
      filterOption: option,
    );
    if (albums.isEmpty) return pickImages(limit: limit);
    final out = <String>[];
    var page = 0;
    const pageSize = 40;
    while (out.length < limit) {
      final assets = await albums.first.getAssetListPaged(
        page: page,
        size: pageSize,
      );
      if (assets.isEmpty) break;
      for (final asset in assets) {
        if (out.length >= limit) break;
        final file = await asset.file;
        if (file != null) {
          out.add(await persistPath(file.path));
        }
      }
      if (assets.length < pageSize) break;
      page++;
    }
    return out;
  }
}
