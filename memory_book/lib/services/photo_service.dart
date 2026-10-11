import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:photo_manager/photo_manager.dart';
import 'package:uuid/uuid.dart';

import 'photo_files.dart';

class PhotoService {
  PhotoService();

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
