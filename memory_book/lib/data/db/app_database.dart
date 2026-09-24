import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Albums extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get themeId => text().withDefault(const Constant('leather'))();
  TextColumn get coverPhotoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get dateStart => dateTime().nullable()();
  DateTimeColumn get dateEnd => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class BookPages extends Table {
  TextColumn get id => text()();
  TextColumn get albumId => text().references(Albums, #id)();
  IntColumn get pageIndex => integer()();
  TextColumn get layoutId => text().withDefault(const Constant('full'))();

  @override
  Set<Column> get primaryKey => {id};
}

class PhotoSlots extends Table {
  TextColumn get id => text()();
  TextColumn get pageId => text().references(BookPages, #id)();
  IntColumn get slotIndex => integer()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get caption => text().withDefault(const Constant(''))();
  RealColumn get scale => real().withDefault(const Constant(1.0))();
  RealColumn get offsetX => real().withDefault(const Constant(0.0))();
  RealColumn get offsetY => real().withDefault(const Constant(0.0))();
  TextColumn get filterId => text().withDefault(const Constant('none'))();
  BoolColumn get showDate => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class CollageProjects extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get templateId => text()();
  TextColumn get background => text().withDefault(const Constant('paper'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CollageItems extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(CollageProjects, #id)();
  TextColumn get imagePath => text()();
  IntColumn get itemIndex => integer()();
  RealColumn get scale => real().withDefault(const Constant(1.0))();
  RealColumn get offsetX => real().withDefault(const Constant(0.0))();
  RealColumn get offsetY => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

class CollageTexts extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(CollageProjects, #id)();
  TextColumn get body => text()();
  RealColumn get nx => real()();
  RealColumn get ny => real()();
  IntColumn get colorValue => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class VideoProjects extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get aspect => text().withDefault(const Constant('9:16'))();
  TextColumn get filterId => text().withDefault(const Constant('none'))();
  TextColumn get transition => text().withDefault(const Constant('crossfade'))();
  TextColumn get musicPath => text().nullable()();
  RealColumn get secondsPerSlide => real().withDefault(const Constant(3.0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class VideoClips extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(VideoProjects, #id)();
  TextColumn get imagePath => text()();
  IntColumn get clipIndex => integer()();
  RealColumn get durationSec => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppKvEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class CreditEvents extends Table {
  TextColumn get id => text()();
  IntColumn get delta => integer()();
  TextColumn get reason => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class AuthSessions extends Table {
  TextColumn get id => text()();
  TextColumn get provider => text()();
  TextColumn get subject => text()();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Albums,
    BookPages,
    PhotoSlots,
    CollageProjects,
    CollageItems,
    CollageTexts,
    VideoProjects,
    VideoClips,
    AppKvEntries,
    CreditEvents,
    AuthSessions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() {
    return driftDatabase(name: 'memory_book');
  }
}
