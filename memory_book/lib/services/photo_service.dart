import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:uuid/uuid.dart';

class PhotoService {
  PhotoService();

  final _picker = ImagePicker();
  final _uuid = const Uuid();

  Future<Directory> _dir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'photos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> persistPath(String sourcePath) async {
    final ext = p.extension(sourcePath);
    final dest = p.join(
      (await _dir()).path,
      '${_uuid.v4()}${ext.isEmpty ? '.jpg' : ext}',
    );
    await File(sourcePath).copy(dest);
    return dest;
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
