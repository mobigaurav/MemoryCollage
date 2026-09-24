// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AlbumsTable extends Albums with TableInfo<$AlbumsTable, Album> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _themeIdMeta = const VerificationMeta(
    'themeId',
  );
  @override
  late final GeneratedColumn<String> themeId = GeneratedColumn<String>(
    'theme_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('leather'),
  );
  static const VerificationMeta _coverPhotoPathMeta = const VerificationMeta(
    'coverPhotoPath',
  );
  @override
  late final GeneratedColumn<String> coverPhotoPath = GeneratedColumn<String>(
    'cover_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateStartMeta = const VerificationMeta(
    'dateStart',
  );
  @override
  late final GeneratedColumn<DateTime> dateStart = GeneratedColumn<DateTime>(
    'date_start',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateEndMeta = const VerificationMeta(
    'dateEnd',
  );
  @override
  late final GeneratedColumn<DateTime> dateEnd = GeneratedColumn<DateTime>(
    'date_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    themeId,
    coverPhotoPath,
    createdAt,
    updatedAt,
    dateStart,
    dateEnd,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<Album> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('theme_id')) {
      context.handle(
        _themeIdMeta,
        themeId.isAcceptableOrUnknown(data['theme_id']!, _themeIdMeta),
      );
    }
    if (data.containsKey('cover_photo_path')) {
      context.handle(
        _coverPhotoPathMeta,
        coverPhotoPath.isAcceptableOrUnknown(
          data['cover_photo_path']!,
          _coverPhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('date_start')) {
      context.handle(
        _dateStartMeta,
        dateStart.isAcceptableOrUnknown(data['date_start']!, _dateStartMeta),
      );
    }
    if (data.containsKey('date_end')) {
      context.handle(
        _dateEndMeta,
        dateEnd.isAcceptableOrUnknown(data['date_end']!, _dateEndMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Album map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Album(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      themeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_id'],
      )!,
      coverPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      dateStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_start'],
      ),
      dateEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_end'],
      ),
    );
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(attachedDatabase, alias);
  }
}

class Album extends DataClass implements Insertable<Album> {
  final String id;
  final String title;
  final String themeId;
  final String? coverPhotoPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  const Album({
    required this.id,
    required this.title,
    required this.themeId,
    this.coverPhotoPath,
    required this.createdAt,
    required this.updatedAt,
    this.dateStart,
    this.dateEnd,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['theme_id'] = Variable<String>(themeId);
    if (!nullToAbsent || coverPhotoPath != null) {
      map['cover_photo_path'] = Variable<String>(coverPhotoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || dateStart != null) {
      map['date_start'] = Variable<DateTime>(dateStart);
    }
    if (!nullToAbsent || dateEnd != null) {
      map['date_end'] = Variable<DateTime>(dateEnd);
    }
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      id: Value(id),
      title: Value(title),
      themeId: Value(themeId),
      coverPhotoPath: coverPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPhotoPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dateStart: dateStart == null && nullToAbsent
          ? const Value.absent()
          : Value(dateStart),
      dateEnd: dateEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(dateEnd),
    );
  }

  factory Album.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Album(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      themeId: serializer.fromJson<String>(json['themeId']),
      coverPhotoPath: serializer.fromJson<String?>(json['coverPhotoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dateStart: serializer.fromJson<DateTime?>(json['dateStart']),
      dateEnd: serializer.fromJson<DateTime?>(json['dateEnd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'themeId': serializer.toJson<String>(themeId),
      'coverPhotoPath': serializer.toJson<String?>(coverPhotoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dateStart': serializer.toJson<DateTime?>(dateStart),
      'dateEnd': serializer.toJson<DateTime?>(dateEnd),
    };
  }

  Album copyWith({
    String? id,
    String? title,
    String? themeId,
    Value<String?> coverPhotoPath = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> dateStart = const Value.absent(),
    Value<DateTime?> dateEnd = const Value.absent(),
  }) => Album(
    id: id ?? this.id,
    title: title ?? this.title,
    themeId: themeId ?? this.themeId,
    coverPhotoPath: coverPhotoPath.present
        ? coverPhotoPath.value
        : this.coverPhotoPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dateStart: dateStart.present ? dateStart.value : this.dateStart,
    dateEnd: dateEnd.present ? dateEnd.value : this.dateEnd,
  );
  Album copyWithCompanion(AlbumsCompanion data) {
    return Album(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      themeId: data.themeId.present ? data.themeId.value : this.themeId,
      coverPhotoPath: data.coverPhotoPath.present
          ? data.coverPhotoPath.value
          : this.coverPhotoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dateStart: data.dateStart.present ? data.dateStart.value : this.dateStart,
      dateEnd: data.dateEnd.present ? data.dateEnd.value : this.dateEnd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Album(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('themeId: $themeId, ')
          ..write('coverPhotoPath: $coverPhotoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dateStart: $dateStart, ')
          ..write('dateEnd: $dateEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    themeId,
    coverPhotoPath,
    createdAt,
    updatedAt,
    dateStart,
    dateEnd,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Album &&
          other.id == this.id &&
          other.title == this.title &&
          other.themeId == this.themeId &&
          other.coverPhotoPath == this.coverPhotoPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dateStart == this.dateStart &&
          other.dateEnd == this.dateEnd);
}

class AlbumsCompanion extends UpdateCompanion<Album> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> themeId;
  final Value<String?> coverPhotoPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> dateStart;
  final Value<DateTime?> dateEnd;
  final Value<int> rowid;
  const AlbumsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.themeId = const Value.absent(),
    this.coverPhotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dateStart = const Value.absent(),
    this.dateEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsCompanion.insert({
    required String id,
    required String title,
    this.themeId = const Value.absent(),
    this.coverPhotoPath = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.dateStart = const Value.absent(),
    this.dateEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Album> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? themeId,
    Expression<String>? coverPhotoPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? dateStart,
    Expression<DateTime>? dateEnd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (themeId != null) 'theme_id': themeId,
      if (coverPhotoPath != null) 'cover_photo_path': coverPhotoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dateStart != null) 'date_start': dateStart,
      if (dateEnd != null) 'date_end': dateEnd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? themeId,
    Value<String?>? coverPhotoPath,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? dateStart,
    Value<DateTime?>? dateEnd,
    Value<int>? rowid,
  }) {
    return AlbumsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      themeId: themeId ?? this.themeId,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (themeId.present) {
      map['theme_id'] = Variable<String>(themeId.value);
    }
    if (coverPhotoPath.present) {
      map['cover_photo_path'] = Variable<String>(coverPhotoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dateStart.present) {
      map['date_start'] = Variable<DateTime>(dateStart.value);
    }
    if (dateEnd.present) {
      map['date_end'] = Variable<DateTime>(dateEnd.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('themeId: $themeId, ')
          ..write('coverPhotoPath: $coverPhotoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dateStart: $dateStart, ')
          ..write('dateEnd: $dateEnd, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookPagesTable extends BookPages
    with TableInfo<$BookPagesTable, BookPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookPagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES albums (id)',
    ),
  );
  static const VerificationMeta _pageIndexMeta = const VerificationMeta(
    'pageIndex',
  );
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
    'page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _layoutIdMeta = const VerificationMeta(
    'layoutId',
  );
  @override
  late final GeneratedColumn<String> layoutId = GeneratedColumn<String>(
    'layout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('full'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, albumId, pageIndex, layoutId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookPage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(
        _pageIndexMeta,
        pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('layout_id')) {
      context.handle(
        _layoutIdMeta,
        layoutId.isAcceptableOrUnknown(data['layout_id']!, _layoutIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookPage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      )!,
      pageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_index'],
      )!,
      layoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout_id'],
      )!,
    );
  }

  @override
  $BookPagesTable createAlias(String alias) {
    return $BookPagesTable(attachedDatabase, alias);
  }
}

class BookPage extends DataClass implements Insertable<BookPage> {
  final String id;
  final String albumId;
  final int pageIndex;
  final String layoutId;
  const BookPage({
    required this.id,
    required this.albumId,
    required this.pageIndex,
    required this.layoutId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['album_id'] = Variable<String>(albumId);
    map['page_index'] = Variable<int>(pageIndex);
    map['layout_id'] = Variable<String>(layoutId);
    return map;
  }

  BookPagesCompanion toCompanion(bool nullToAbsent) {
    return BookPagesCompanion(
      id: Value(id),
      albumId: Value(albumId),
      pageIndex: Value(pageIndex),
      layoutId: Value(layoutId),
    );
  }

  factory BookPage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookPage(
      id: serializer.fromJson<String>(json['id']),
      albumId: serializer.fromJson<String>(json['albumId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      layoutId: serializer.fromJson<String>(json['layoutId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'albumId': serializer.toJson<String>(albumId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'layoutId': serializer.toJson<String>(layoutId),
    };
  }

  BookPage copyWith({
    String? id,
    String? albumId,
    int? pageIndex,
    String? layoutId,
  }) => BookPage(
    id: id ?? this.id,
    albumId: albumId ?? this.albumId,
    pageIndex: pageIndex ?? this.pageIndex,
    layoutId: layoutId ?? this.layoutId,
  );
  BookPage copyWithCompanion(BookPagesCompanion data) {
    return BookPage(
      id: data.id.present ? data.id.value : this.id,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      layoutId: data.layoutId.present ? data.layoutId.value : this.layoutId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookPage(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('layoutId: $layoutId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, albumId, pageIndex, layoutId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookPage &&
          other.id == this.id &&
          other.albumId == this.albumId &&
          other.pageIndex == this.pageIndex &&
          other.layoutId == this.layoutId);
}

class BookPagesCompanion extends UpdateCompanion<BookPage> {
  final Value<String> id;
  final Value<String> albumId;
  final Value<int> pageIndex;
  final Value<String> layoutId;
  final Value<int> rowid;
  const BookPagesCompanion({
    this.id = const Value.absent(),
    this.albumId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.layoutId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookPagesCompanion.insert({
    required String id,
    required String albumId,
    required int pageIndex,
    this.layoutId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       albumId = Value(albumId),
       pageIndex = Value(pageIndex);
  static Insertable<BookPage> custom({
    Expression<String>? id,
    Expression<String>? albumId,
    Expression<int>? pageIndex,
    Expression<String>? layoutId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (albumId != null) 'album_id': albumId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (layoutId != null) 'layout_id': layoutId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookPagesCompanion copyWith({
    Value<String>? id,
    Value<String>? albumId,
    Value<int>? pageIndex,
    Value<String>? layoutId,
    Value<int>? rowid,
  }) {
    return BookPagesCompanion(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      pageIndex: pageIndex ?? this.pageIndex,
      layoutId: layoutId ?? this.layoutId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (layoutId.present) {
      map['layout_id'] = Variable<String>(layoutId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookPagesCompanion(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('layoutId: $layoutId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotoSlotsTable extends PhotoSlots
    with TableInfo<$PhotoSlotsTable, PhotoSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<String> pageId = GeneratedColumn<String>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES book_pages (id)',
    ),
  );
  static const VerificationMeta _slotIndexMeta = const VerificationMeta(
    'slotIndex',
  );
  @override
  late final GeneratedColumn<int> slotIndex = GeneratedColumn<int>(
    'slot_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _scaleMeta = const VerificationMeta('scale');
  @override
  late final GeneratedColumn<double> scale = GeneratedColumn<double>(
    'scale',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _offsetXMeta = const VerificationMeta(
    'offsetX',
  );
  @override
  late final GeneratedColumn<double> offsetX = GeneratedColumn<double>(
    'offset_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _offsetYMeta = const VerificationMeta(
    'offsetY',
  );
  @override
  late final GeneratedColumn<double> offsetY = GeneratedColumn<double>(
    'offset_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _filterIdMeta = const VerificationMeta(
    'filterId',
  );
  @override
  late final GeneratedColumn<String> filterId = GeneratedColumn<String>(
    'filter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _showDateMeta = const VerificationMeta(
    'showDate',
  );
  @override
  late final GeneratedColumn<bool> showDate = GeneratedColumn<bool>(
    'show_date',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_date" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageId,
    slotIndex,
    imagePath,
    caption,
    scale,
    offsetX,
    offsetY,
    filterId,
    showDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoSlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('slot_index')) {
      context.handle(
        _slotIndexMeta,
        slotIndex.isAcceptableOrUnknown(data['slot_index']!, _slotIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_slotIndexMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('scale')) {
      context.handle(
        _scaleMeta,
        scale.isAcceptableOrUnknown(data['scale']!, _scaleMeta),
      );
    }
    if (data.containsKey('offset_x')) {
      context.handle(
        _offsetXMeta,
        offsetX.isAcceptableOrUnknown(data['offset_x']!, _offsetXMeta),
      );
    }
    if (data.containsKey('offset_y')) {
      context.handle(
        _offsetYMeta,
        offsetY.isAcceptableOrUnknown(data['offset_y']!, _offsetYMeta),
      );
    }
    if (data.containsKey('filter_id')) {
      context.handle(
        _filterIdMeta,
        filterId.isAcceptableOrUnknown(data['filter_id']!, _filterIdMeta),
      );
    }
    if (data.containsKey('show_date')) {
      context.handle(
        _showDateMeta,
        showDate.isAcceptableOrUnknown(data['show_date']!, _showDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoSlot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_id'],
      )!,
      slotIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_index'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      )!,
      scale: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scale'],
      )!,
      offsetX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}offset_x'],
      )!,
      offsetY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}offset_y'],
      )!,
      filterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_id'],
      )!,
      showDate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_date'],
      )!,
    );
  }

  @override
  $PhotoSlotsTable createAlias(String alias) {
    return $PhotoSlotsTable(attachedDatabase, alias);
  }
}

class PhotoSlot extends DataClass implements Insertable<PhotoSlot> {
  final String id;
  final String pageId;
  final int slotIndex;
  final String? imagePath;
  final String caption;
  final double scale;
  final double offsetX;
  final double offsetY;
  final String filterId;
  final bool showDate;
  const PhotoSlot({
    required this.id,
    required this.pageId,
    required this.slotIndex,
    this.imagePath,
    required this.caption,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    required this.filterId,
    required this.showDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['page_id'] = Variable<String>(pageId);
    map['slot_index'] = Variable<int>(slotIndex);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['caption'] = Variable<String>(caption);
    map['scale'] = Variable<double>(scale);
    map['offset_x'] = Variable<double>(offsetX);
    map['offset_y'] = Variable<double>(offsetY);
    map['filter_id'] = Variable<String>(filterId);
    map['show_date'] = Variable<bool>(showDate);
    return map;
  }

  PhotoSlotsCompanion toCompanion(bool nullToAbsent) {
    return PhotoSlotsCompanion(
      id: Value(id),
      pageId: Value(pageId),
      slotIndex: Value(slotIndex),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      caption: Value(caption),
      scale: Value(scale),
      offsetX: Value(offsetX),
      offsetY: Value(offsetY),
      filterId: Value(filterId),
      showDate: Value(showDate),
    );
  }

  factory PhotoSlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoSlot(
      id: serializer.fromJson<String>(json['id']),
      pageId: serializer.fromJson<String>(json['pageId']),
      slotIndex: serializer.fromJson<int>(json['slotIndex']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      caption: serializer.fromJson<String>(json['caption']),
      scale: serializer.fromJson<double>(json['scale']),
      offsetX: serializer.fromJson<double>(json['offsetX']),
      offsetY: serializer.fromJson<double>(json['offsetY']),
      filterId: serializer.fromJson<String>(json['filterId']),
      showDate: serializer.fromJson<bool>(json['showDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pageId': serializer.toJson<String>(pageId),
      'slotIndex': serializer.toJson<int>(slotIndex),
      'imagePath': serializer.toJson<String?>(imagePath),
      'caption': serializer.toJson<String>(caption),
      'scale': serializer.toJson<double>(scale),
      'offsetX': serializer.toJson<double>(offsetX),
      'offsetY': serializer.toJson<double>(offsetY),
      'filterId': serializer.toJson<String>(filterId),
      'showDate': serializer.toJson<bool>(showDate),
    };
  }

  PhotoSlot copyWith({
    String? id,
    String? pageId,
    int? slotIndex,
    Value<String?> imagePath = const Value.absent(),
    String? caption,
    double? scale,
    double? offsetX,
    double? offsetY,
    String? filterId,
    bool? showDate,
  }) => PhotoSlot(
    id: id ?? this.id,
    pageId: pageId ?? this.pageId,
    slotIndex: slotIndex ?? this.slotIndex,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    caption: caption ?? this.caption,
    scale: scale ?? this.scale,
    offsetX: offsetX ?? this.offsetX,
    offsetY: offsetY ?? this.offsetY,
    filterId: filterId ?? this.filterId,
    showDate: showDate ?? this.showDate,
  );
  PhotoSlot copyWithCompanion(PhotoSlotsCompanion data) {
    return PhotoSlot(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      slotIndex: data.slotIndex.present ? data.slotIndex.value : this.slotIndex,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      caption: data.caption.present ? data.caption.value : this.caption,
      scale: data.scale.present ? data.scale.value : this.scale,
      offsetX: data.offsetX.present ? data.offsetX.value : this.offsetX,
      offsetY: data.offsetY.present ? data.offsetY.value : this.offsetY,
      filterId: data.filterId.present ? data.filterId.value : this.filterId,
      showDate: data.showDate.present ? data.showDate.value : this.showDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoSlot(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('slotIndex: $slotIndex, ')
          ..write('imagePath: $imagePath, ')
          ..write('caption: $caption, ')
          ..write('scale: $scale, ')
          ..write('offsetX: $offsetX, ')
          ..write('offsetY: $offsetY, ')
          ..write('filterId: $filterId, ')
          ..write('showDate: $showDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pageId,
    slotIndex,
    imagePath,
    caption,
    scale,
    offsetX,
    offsetY,
    filterId,
    showDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoSlot &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.slotIndex == this.slotIndex &&
          other.imagePath == this.imagePath &&
          other.caption == this.caption &&
          other.scale == this.scale &&
          other.offsetX == this.offsetX &&
          other.offsetY == this.offsetY &&
          other.filterId == this.filterId &&
          other.showDate == this.showDate);
}

class PhotoSlotsCompanion extends UpdateCompanion<PhotoSlot> {
  final Value<String> id;
  final Value<String> pageId;
  final Value<int> slotIndex;
  final Value<String?> imagePath;
  final Value<String> caption;
  final Value<double> scale;
  final Value<double> offsetX;
  final Value<double> offsetY;
  final Value<String> filterId;
  final Value<bool> showDate;
  final Value<int> rowid;
  const PhotoSlotsCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.slotIndex = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.caption = const Value.absent(),
    this.scale = const Value.absent(),
    this.offsetX = const Value.absent(),
    this.offsetY = const Value.absent(),
    this.filterId = const Value.absent(),
    this.showDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotoSlotsCompanion.insert({
    required String id,
    required String pageId,
    required int slotIndex,
    this.imagePath = const Value.absent(),
    this.caption = const Value.absent(),
    this.scale = const Value.absent(),
    this.offsetX = const Value.absent(),
    this.offsetY = const Value.absent(),
    this.filterId = const Value.absent(),
    this.showDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pageId = Value(pageId),
       slotIndex = Value(slotIndex);
  static Insertable<PhotoSlot> custom({
    Expression<String>? id,
    Expression<String>? pageId,
    Expression<int>? slotIndex,
    Expression<String>? imagePath,
    Expression<String>? caption,
    Expression<double>? scale,
    Expression<double>? offsetX,
    Expression<double>? offsetY,
    Expression<String>? filterId,
    Expression<bool>? showDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (slotIndex != null) 'slot_index': slotIndex,
      if (imagePath != null) 'image_path': imagePath,
      if (caption != null) 'caption': caption,
      if (scale != null) 'scale': scale,
      if (offsetX != null) 'offset_x': offsetX,
      if (offsetY != null) 'offset_y': offsetY,
      if (filterId != null) 'filter_id': filterId,
      if (showDate != null) 'show_date': showDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotoSlotsCompanion copyWith({
    Value<String>? id,
    Value<String>? pageId,
    Value<int>? slotIndex,
    Value<String?>? imagePath,
    Value<String>? caption,
    Value<double>? scale,
    Value<double>? offsetX,
    Value<double>? offsetY,
    Value<String>? filterId,
    Value<bool>? showDate,
    Value<int>? rowid,
  }) {
    return PhotoSlotsCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      slotIndex: slotIndex ?? this.slotIndex,
      imagePath: imagePath ?? this.imagePath,
      caption: caption ?? this.caption,
      scale: scale ?? this.scale,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      filterId: filterId ?? this.filterId,
      showDate: showDate ?? this.showDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<String>(pageId.value);
    }
    if (slotIndex.present) {
      map['slot_index'] = Variable<int>(slotIndex.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (scale.present) {
      map['scale'] = Variable<double>(scale.value);
    }
    if (offsetX.present) {
      map['offset_x'] = Variable<double>(offsetX.value);
    }
    if (offsetY.present) {
      map['offset_y'] = Variable<double>(offsetY.value);
    }
    if (filterId.present) {
      map['filter_id'] = Variable<String>(filterId.value);
    }
    if (showDate.present) {
      map['show_date'] = Variable<bool>(showDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoSlotsCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('slotIndex: $slotIndex, ')
          ..write('imagePath: $imagePath, ')
          ..write('caption: $caption, ')
          ..write('scale: $scale, ')
          ..write('offsetX: $offsetX, ')
          ..write('offsetY: $offsetY, ')
          ..write('filterId: $filterId, ')
          ..write('showDate: $showDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollageProjectsTable extends CollageProjects
    with TableInfo<$CollageProjectsTable, CollageProject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollageProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backgroundMeta = const VerificationMeta(
    'background',
  );
  @override
  late final GeneratedColumn<String> background = GeneratedColumn<String>(
    'background',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('paper'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    templateId,
    background,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collage_projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollageProject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('background')) {
      context.handle(
        _backgroundMeta,
        background.isAcceptableOrUnknown(data['background']!, _backgroundMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollageProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollageProject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      background: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}background'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CollageProjectsTable createAlias(String alias) {
    return $CollageProjectsTable(attachedDatabase, alias);
  }
}

class CollageProject extends DataClass implements Insertable<CollageProject> {
  final String id;
  final String title;
  final String templateId;
  final String background;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CollageProject({
    required this.id,
    required this.title,
    required this.templateId,
    required this.background,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['template_id'] = Variable<String>(templateId);
    map['background'] = Variable<String>(background);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CollageProjectsCompanion toCompanion(bool nullToAbsent) {
    return CollageProjectsCompanion(
      id: Value(id),
      title: Value(title),
      templateId: Value(templateId),
      background: Value(background),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CollageProject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollageProject(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      templateId: serializer.fromJson<String>(json['templateId']),
      background: serializer.fromJson<String>(json['background']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'templateId': serializer.toJson<String>(templateId),
      'background': serializer.toJson<String>(background),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CollageProject copyWith({
    String? id,
    String? title,
    String? templateId,
    String? background,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CollageProject(
    id: id ?? this.id,
    title: title ?? this.title,
    templateId: templateId ?? this.templateId,
    background: background ?? this.background,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CollageProject copyWithCompanion(CollageProjectsCompanion data) {
    return CollageProject(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      background: data.background.present
          ? data.background.value
          : this.background,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollageProject(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('templateId: $templateId, ')
          ..write('background: $background, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, templateId, background, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollageProject &&
          other.id == this.id &&
          other.title == this.title &&
          other.templateId == this.templateId &&
          other.background == this.background &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CollageProjectsCompanion extends UpdateCompanion<CollageProject> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> templateId;
  final Value<String> background;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CollageProjectsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.templateId = const Value.absent(),
    this.background = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollageProjectsCompanion.insert({
    required String id,
    required String title,
    required String templateId,
    this.background = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       templateId = Value(templateId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CollageProject> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? templateId,
    Expression<String>? background,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (templateId != null) 'template_id': templateId,
      if (background != null) 'background': background,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollageProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? templateId,
    Value<String>? background,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CollageProjectsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      templateId: templateId ?? this.templateId,
      background: background ?? this.background,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (background.present) {
      map['background'] = Variable<String>(background.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollageProjectsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('templateId: $templateId, ')
          ..write('background: $background, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollageItemsTable extends CollageItems
    with TableInfo<$CollageItemsTable, CollageItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollageItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collage_projects (id)',
    ),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIndexMeta = const VerificationMeta(
    'itemIndex',
  );
  @override
  late final GeneratedColumn<int> itemIndex = GeneratedColumn<int>(
    'item_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scaleMeta = const VerificationMeta('scale');
  @override
  late final GeneratedColumn<double> scale = GeneratedColumn<double>(
    'scale',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _offsetXMeta = const VerificationMeta(
    'offsetX',
  );
  @override
  late final GeneratedColumn<double> offsetX = GeneratedColumn<double>(
    'offset_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _offsetYMeta = const VerificationMeta(
    'offsetY',
  );
  @override
  late final GeneratedColumn<double> offsetY = GeneratedColumn<double>(
    'offset_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    imagePath,
    itemIndex,
    scale,
    offsetX,
    offsetY,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collage_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollageItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('item_index')) {
      context.handle(
        _itemIndexMeta,
        itemIndex.isAcceptableOrUnknown(data['item_index']!, _itemIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIndexMeta);
    }
    if (data.containsKey('scale')) {
      context.handle(
        _scaleMeta,
        scale.isAcceptableOrUnknown(data['scale']!, _scaleMeta),
      );
    }
    if (data.containsKey('offset_x')) {
      context.handle(
        _offsetXMeta,
        offsetX.isAcceptableOrUnknown(data['offset_x']!, _offsetXMeta),
      );
    }
    if (data.containsKey('offset_y')) {
      context.handle(
        _offsetYMeta,
        offsetY.isAcceptableOrUnknown(data['offset_y']!, _offsetYMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollageItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollageItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      itemIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_index'],
      )!,
      scale: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scale'],
      )!,
      offsetX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}offset_x'],
      )!,
      offsetY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}offset_y'],
      )!,
    );
  }

  @override
  $CollageItemsTable createAlias(String alias) {
    return $CollageItemsTable(attachedDatabase, alias);
  }
}

class CollageItem extends DataClass implements Insertable<CollageItem> {
  final String id;
  final String projectId;
  final String imagePath;
  final int itemIndex;
  final double scale;
  final double offsetX;
  final double offsetY;
  const CollageItem({
    required this.id,
    required this.projectId,
    required this.imagePath,
    required this.itemIndex,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['image_path'] = Variable<String>(imagePath);
    map['item_index'] = Variable<int>(itemIndex);
    map['scale'] = Variable<double>(scale);
    map['offset_x'] = Variable<double>(offsetX);
    map['offset_y'] = Variable<double>(offsetY);
    return map;
  }

  CollageItemsCompanion toCompanion(bool nullToAbsent) {
    return CollageItemsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      imagePath: Value(imagePath),
      itemIndex: Value(itemIndex),
      scale: Value(scale),
      offsetX: Value(offsetX),
      offsetY: Value(offsetY),
    );
  }

  factory CollageItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollageItem(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      itemIndex: serializer.fromJson<int>(json['itemIndex']),
      scale: serializer.fromJson<double>(json['scale']),
      offsetX: serializer.fromJson<double>(json['offsetX']),
      offsetY: serializer.fromJson<double>(json['offsetY']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'imagePath': serializer.toJson<String>(imagePath),
      'itemIndex': serializer.toJson<int>(itemIndex),
      'scale': serializer.toJson<double>(scale),
      'offsetX': serializer.toJson<double>(offsetX),
      'offsetY': serializer.toJson<double>(offsetY),
    };
  }

  CollageItem copyWith({
    String? id,
    String? projectId,
    String? imagePath,
    int? itemIndex,
    double? scale,
    double? offsetX,
    double? offsetY,
  }) => CollageItem(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    imagePath: imagePath ?? this.imagePath,
    itemIndex: itemIndex ?? this.itemIndex,
    scale: scale ?? this.scale,
    offsetX: offsetX ?? this.offsetX,
    offsetY: offsetY ?? this.offsetY,
  );
  CollageItem copyWithCompanion(CollageItemsCompanion data) {
    return CollageItem(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      itemIndex: data.itemIndex.present ? data.itemIndex.value : this.itemIndex,
      scale: data.scale.present ? data.scale.value : this.scale,
      offsetX: data.offsetX.present ? data.offsetX.value : this.offsetX,
      offsetY: data.offsetY.present ? data.offsetY.value : this.offsetY,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollageItem(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('imagePath: $imagePath, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('scale: $scale, ')
          ..write('offsetX: $offsetX, ')
          ..write('offsetY: $offsetY')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, imagePath, itemIndex, scale, offsetX, offsetY);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollageItem &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.imagePath == this.imagePath &&
          other.itemIndex == this.itemIndex &&
          other.scale == this.scale &&
          other.offsetX == this.offsetX &&
          other.offsetY == this.offsetY);
}

class CollageItemsCompanion extends UpdateCompanion<CollageItem> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> imagePath;
  final Value<int> itemIndex;
  final Value<double> scale;
  final Value<double> offsetX;
  final Value<double> offsetY;
  final Value<int> rowid;
  const CollageItemsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.itemIndex = const Value.absent(),
    this.scale = const Value.absent(),
    this.offsetX = const Value.absent(),
    this.offsetY = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollageItemsCompanion.insert({
    required String id,
    required String projectId,
    required String imagePath,
    required int itemIndex,
    this.scale = const Value.absent(),
    this.offsetX = const Value.absent(),
    this.offsetY = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       imagePath = Value(imagePath),
       itemIndex = Value(itemIndex);
  static Insertable<CollageItem> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? imagePath,
    Expression<int>? itemIndex,
    Expression<double>? scale,
    Expression<double>? offsetX,
    Expression<double>? offsetY,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (imagePath != null) 'image_path': imagePath,
      if (itemIndex != null) 'item_index': itemIndex,
      if (scale != null) 'scale': scale,
      if (offsetX != null) 'offset_x': offsetX,
      if (offsetY != null) 'offset_y': offsetY,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollageItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? imagePath,
    Value<int>? itemIndex,
    Value<double>? scale,
    Value<double>? offsetX,
    Value<double>? offsetY,
    Value<int>? rowid,
  }) {
    return CollageItemsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      imagePath: imagePath ?? this.imagePath,
      itemIndex: itemIndex ?? this.itemIndex,
      scale: scale ?? this.scale,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (itemIndex.present) {
      map['item_index'] = Variable<int>(itemIndex.value);
    }
    if (scale.present) {
      map['scale'] = Variable<double>(scale.value);
    }
    if (offsetX.present) {
      map['offset_x'] = Variable<double>(offsetX.value);
    }
    if (offsetY.present) {
      map['offset_y'] = Variable<double>(offsetY.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollageItemsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('imagePath: $imagePath, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('scale: $scale, ')
          ..write('offsetX: $offsetX, ')
          ..write('offsetY: $offsetY, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollageTextsTable extends CollageTexts
    with TableInfo<$CollageTextsTable, CollageText> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollageTextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collage_projects (id)',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nxMeta = const VerificationMeta('nx');
  @override
  late final GeneratedColumn<double> nx = GeneratedColumn<double>(
    'nx',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nyMeta = const VerificationMeta('ny');
  @override
  late final GeneratedColumn<double> ny = GeneratedColumn<double>(
    'ny',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    body,
    nx,
    ny,
    colorValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collage_texts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollageText> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('nx')) {
      context.handle(_nxMeta, nx.isAcceptableOrUnknown(data['nx']!, _nxMeta));
    } else if (isInserting) {
      context.missing(_nxMeta);
    }
    if (data.containsKey('ny')) {
      context.handle(_nyMeta, ny.isAcceptableOrUnknown(data['ny']!, _nyMeta));
    } else if (isInserting) {
      context.missing(_nyMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollageText map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollageText(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      nx: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}nx'],
      )!,
      ny: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ny'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
    );
  }

  @override
  $CollageTextsTable createAlias(String alias) {
    return $CollageTextsTable(attachedDatabase, alias);
  }
}

class CollageText extends DataClass implements Insertable<CollageText> {
  final String id;
  final String projectId;
  final String body;
  final double nx;
  final double ny;
  final int colorValue;
  const CollageText({
    required this.id,
    required this.projectId,
    required this.body,
    required this.nx,
    required this.ny,
    required this.colorValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['body'] = Variable<String>(body);
    map['nx'] = Variable<double>(nx);
    map['ny'] = Variable<double>(ny);
    map['color_value'] = Variable<int>(colorValue);
    return map;
  }

  CollageTextsCompanion toCompanion(bool nullToAbsent) {
    return CollageTextsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      body: Value(body),
      nx: Value(nx),
      ny: Value(ny),
      colorValue: Value(colorValue),
    );
  }

  factory CollageText.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollageText(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      body: serializer.fromJson<String>(json['body']),
      nx: serializer.fromJson<double>(json['nx']),
      ny: serializer.fromJson<double>(json['ny']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'body': serializer.toJson<String>(body),
      'nx': serializer.toJson<double>(nx),
      'ny': serializer.toJson<double>(ny),
      'colorValue': serializer.toJson<int>(colorValue),
    };
  }

  CollageText copyWith({
    String? id,
    String? projectId,
    String? body,
    double? nx,
    double? ny,
    int? colorValue,
  }) => CollageText(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    body: body ?? this.body,
    nx: nx ?? this.nx,
    ny: ny ?? this.ny,
    colorValue: colorValue ?? this.colorValue,
  );
  CollageText copyWithCompanion(CollageTextsCompanion data) {
    return CollageText(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      body: data.body.present ? data.body.value : this.body,
      nx: data.nx.present ? data.nx.value : this.nx,
      ny: data.ny.present ? data.ny.value : this.ny,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollageText(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('body: $body, ')
          ..write('nx: $nx, ')
          ..write('ny: $ny, ')
          ..write('colorValue: $colorValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, body, nx, ny, colorValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollageText &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.body == this.body &&
          other.nx == this.nx &&
          other.ny == this.ny &&
          other.colorValue == this.colorValue);
}

class CollageTextsCompanion extends UpdateCompanion<CollageText> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> body;
  final Value<double> nx;
  final Value<double> ny;
  final Value<int> colorValue;
  final Value<int> rowid;
  const CollageTextsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.body = const Value.absent(),
    this.nx = const Value.absent(),
    this.ny = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollageTextsCompanion.insert({
    required String id,
    required String projectId,
    required String body,
    required double nx,
    required double ny,
    required int colorValue,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       body = Value(body),
       nx = Value(nx),
       ny = Value(ny),
       colorValue = Value(colorValue);
  static Insertable<CollageText> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? body,
    Expression<double>? nx,
    Expression<double>? ny,
    Expression<int>? colorValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (body != null) 'body': body,
      if (nx != null) 'nx': nx,
      if (ny != null) 'ny': ny,
      if (colorValue != null) 'color_value': colorValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollageTextsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? body,
    Value<double>? nx,
    Value<double>? ny,
    Value<int>? colorValue,
    Value<int>? rowid,
  }) {
    return CollageTextsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      body: body ?? this.body,
      nx: nx ?? this.nx,
      ny: ny ?? this.ny,
      colorValue: colorValue ?? this.colorValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (nx.present) {
      map['nx'] = Variable<double>(nx.value);
    }
    if (ny.present) {
      map['ny'] = Variable<double>(ny.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollageTextsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('body: $body, ')
          ..write('nx: $nx, ')
          ..write('ny: $ny, ')
          ..write('colorValue: $colorValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VideoProjectsTable extends VideoProjects
    with TableInfo<$VideoProjectsTable, VideoProject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aspectMeta = const VerificationMeta('aspect');
  @override
  late final GeneratedColumn<String> aspect = GeneratedColumn<String>(
    'aspect',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('9:16'),
  );
  static const VerificationMeta _filterIdMeta = const VerificationMeta(
    'filterId',
  );
  @override
  late final GeneratedColumn<String> filterId = GeneratedColumn<String>(
    'filter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _transitionMeta = const VerificationMeta(
    'transition',
  );
  @override
  late final GeneratedColumn<String> transition = GeneratedColumn<String>(
    'transition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('crossfade'),
  );
  static const VerificationMeta _musicPathMeta = const VerificationMeta(
    'musicPath',
  );
  @override
  late final GeneratedColumn<String> musicPath = GeneratedColumn<String>(
    'music_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondsPerSlideMeta = const VerificationMeta(
    'secondsPerSlide',
  );
  @override
  late final GeneratedColumn<double> secondsPerSlide = GeneratedColumn<double>(
    'seconds_per_slide',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(3.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    aspect,
    filterId,
    transition,
    musicPath,
    secondsPerSlide,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<VideoProject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('aspect')) {
      context.handle(
        _aspectMeta,
        aspect.isAcceptableOrUnknown(data['aspect']!, _aspectMeta),
      );
    }
    if (data.containsKey('filter_id')) {
      context.handle(
        _filterIdMeta,
        filterId.isAcceptableOrUnknown(data['filter_id']!, _filterIdMeta),
      );
    }
    if (data.containsKey('transition')) {
      context.handle(
        _transitionMeta,
        transition.isAcceptableOrUnknown(data['transition']!, _transitionMeta),
      );
    }
    if (data.containsKey('music_path')) {
      context.handle(
        _musicPathMeta,
        musicPath.isAcceptableOrUnknown(data['music_path']!, _musicPathMeta),
      );
    }
    if (data.containsKey('seconds_per_slide')) {
      context.handle(
        _secondsPerSlideMeta,
        secondsPerSlide.isAcceptableOrUnknown(
          data['seconds_per_slide']!,
          _secondsPerSlideMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoProject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      aspect: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aspect'],
      )!,
      filterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_id'],
      )!,
      transition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transition'],
      )!,
      musicPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}music_path'],
      ),
      secondsPerSlide: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}seconds_per_slide'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VideoProjectsTable createAlias(String alias) {
    return $VideoProjectsTable(attachedDatabase, alias);
  }
}

class VideoProject extends DataClass implements Insertable<VideoProject> {
  final String id;
  final String title;
  final String aspect;
  final String filterId;
  final String transition;
  final String? musicPath;
  final double secondsPerSlide;
  final DateTime createdAt;
  const VideoProject({
    required this.id,
    required this.title,
    required this.aspect,
    required this.filterId,
    required this.transition,
    this.musicPath,
    required this.secondsPerSlide,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['aspect'] = Variable<String>(aspect);
    map['filter_id'] = Variable<String>(filterId);
    map['transition'] = Variable<String>(transition);
    if (!nullToAbsent || musicPath != null) {
      map['music_path'] = Variable<String>(musicPath);
    }
    map['seconds_per_slide'] = Variable<double>(secondsPerSlide);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VideoProjectsCompanion toCompanion(bool nullToAbsent) {
    return VideoProjectsCompanion(
      id: Value(id),
      title: Value(title),
      aspect: Value(aspect),
      filterId: Value(filterId),
      transition: Value(transition),
      musicPath: musicPath == null && nullToAbsent
          ? const Value.absent()
          : Value(musicPath),
      secondsPerSlide: Value(secondsPerSlide),
      createdAt: Value(createdAt),
    );
  }

  factory VideoProject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoProject(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      aspect: serializer.fromJson<String>(json['aspect']),
      filterId: serializer.fromJson<String>(json['filterId']),
      transition: serializer.fromJson<String>(json['transition']),
      musicPath: serializer.fromJson<String?>(json['musicPath']),
      secondsPerSlide: serializer.fromJson<double>(json['secondsPerSlide']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'aspect': serializer.toJson<String>(aspect),
      'filterId': serializer.toJson<String>(filterId),
      'transition': serializer.toJson<String>(transition),
      'musicPath': serializer.toJson<String?>(musicPath),
      'secondsPerSlide': serializer.toJson<double>(secondsPerSlide),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VideoProject copyWith({
    String? id,
    String? title,
    String? aspect,
    String? filterId,
    String? transition,
    Value<String?> musicPath = const Value.absent(),
    double? secondsPerSlide,
    DateTime? createdAt,
  }) => VideoProject(
    id: id ?? this.id,
    title: title ?? this.title,
    aspect: aspect ?? this.aspect,
    filterId: filterId ?? this.filterId,
    transition: transition ?? this.transition,
    musicPath: musicPath.present ? musicPath.value : this.musicPath,
    secondsPerSlide: secondsPerSlide ?? this.secondsPerSlide,
    createdAt: createdAt ?? this.createdAt,
  );
  VideoProject copyWithCompanion(VideoProjectsCompanion data) {
    return VideoProject(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      aspect: data.aspect.present ? data.aspect.value : this.aspect,
      filterId: data.filterId.present ? data.filterId.value : this.filterId,
      transition: data.transition.present
          ? data.transition.value
          : this.transition,
      musicPath: data.musicPath.present ? data.musicPath.value : this.musicPath,
      secondsPerSlide: data.secondsPerSlide.present
          ? data.secondsPerSlide.value
          : this.secondsPerSlide,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoProject(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('aspect: $aspect, ')
          ..write('filterId: $filterId, ')
          ..write('transition: $transition, ')
          ..write('musicPath: $musicPath, ')
          ..write('secondsPerSlide: $secondsPerSlide, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    aspect,
    filterId,
    transition,
    musicPath,
    secondsPerSlide,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoProject &&
          other.id == this.id &&
          other.title == this.title &&
          other.aspect == this.aspect &&
          other.filterId == this.filterId &&
          other.transition == this.transition &&
          other.musicPath == this.musicPath &&
          other.secondsPerSlide == this.secondsPerSlide &&
          other.createdAt == this.createdAt);
}

class VideoProjectsCompanion extends UpdateCompanion<VideoProject> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> aspect;
  final Value<String> filterId;
  final Value<String> transition;
  final Value<String?> musicPath;
  final Value<double> secondsPerSlide;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VideoProjectsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.aspect = const Value.absent(),
    this.filterId = const Value.absent(),
    this.transition = const Value.absent(),
    this.musicPath = const Value.absent(),
    this.secondsPerSlide = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideoProjectsCompanion.insert({
    required String id,
    required String title,
    this.aspect = const Value.absent(),
    this.filterId = const Value.absent(),
    this.transition = const Value.absent(),
    this.musicPath = const Value.absent(),
    this.secondsPerSlide = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<VideoProject> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? aspect,
    Expression<String>? filterId,
    Expression<String>? transition,
    Expression<String>? musicPath,
    Expression<double>? secondsPerSlide,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (aspect != null) 'aspect': aspect,
      if (filterId != null) 'filter_id': filterId,
      if (transition != null) 'transition': transition,
      if (musicPath != null) 'music_path': musicPath,
      if (secondsPerSlide != null) 'seconds_per_slide': secondsPerSlide,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideoProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? aspect,
    Value<String>? filterId,
    Value<String>? transition,
    Value<String?>? musicPath,
    Value<double>? secondsPerSlide,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VideoProjectsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      aspect: aspect ?? this.aspect,
      filterId: filterId ?? this.filterId,
      transition: transition ?? this.transition,
      musicPath: musicPath ?? this.musicPath,
      secondsPerSlide: secondsPerSlide ?? this.secondsPerSlide,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (aspect.present) {
      map['aspect'] = Variable<String>(aspect.value);
    }
    if (filterId.present) {
      map['filter_id'] = Variable<String>(filterId.value);
    }
    if (transition.present) {
      map['transition'] = Variable<String>(transition.value);
    }
    if (musicPath.present) {
      map['music_path'] = Variable<String>(musicPath.value);
    }
    if (secondsPerSlide.present) {
      map['seconds_per_slide'] = Variable<double>(secondsPerSlide.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoProjectsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('aspect: $aspect, ')
          ..write('filterId: $filterId, ')
          ..write('transition: $transition, ')
          ..write('musicPath: $musicPath, ')
          ..write('secondsPerSlide: $secondsPerSlide, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VideoClipsTable extends VideoClips
    with TableInfo<$VideoClipsTable, VideoClip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoClipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES video_projects (id)',
    ),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clipIndexMeta = const VerificationMeta(
    'clipIndex',
  );
  @override
  late final GeneratedColumn<int> clipIndex = GeneratedColumn<int>(
    'clip_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<double> durationSec = GeneratedColumn<double>(
    'duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    imagePath,
    clipIndex,
    durationSec,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_clips';
  @override
  VerificationContext validateIntegrity(
    Insertable<VideoClip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('clip_index')) {
      context.handle(
        _clipIndexMeta,
        clipIndex.isAcceptableOrUnknown(data['clip_index']!, _clipIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_clipIndexMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoClip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoClip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      clipIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clip_index'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration_sec'],
      )!,
    );
  }

  @override
  $VideoClipsTable createAlias(String alias) {
    return $VideoClipsTable(attachedDatabase, alias);
  }
}

class VideoClip extends DataClass implements Insertable<VideoClip> {
  final String id;
  final String projectId;
  final String imagePath;
  final int clipIndex;
  final double durationSec;
  const VideoClip({
    required this.id,
    required this.projectId,
    required this.imagePath,
    required this.clipIndex,
    required this.durationSec,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['image_path'] = Variable<String>(imagePath);
    map['clip_index'] = Variable<int>(clipIndex);
    map['duration_sec'] = Variable<double>(durationSec);
    return map;
  }

  VideoClipsCompanion toCompanion(bool nullToAbsent) {
    return VideoClipsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      imagePath: Value(imagePath),
      clipIndex: Value(clipIndex),
      durationSec: Value(durationSec),
    );
  }

  factory VideoClip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoClip(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      clipIndex: serializer.fromJson<int>(json['clipIndex']),
      durationSec: serializer.fromJson<double>(json['durationSec']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'imagePath': serializer.toJson<String>(imagePath),
      'clipIndex': serializer.toJson<int>(clipIndex),
      'durationSec': serializer.toJson<double>(durationSec),
    };
  }

  VideoClip copyWith({
    String? id,
    String? projectId,
    String? imagePath,
    int? clipIndex,
    double? durationSec,
  }) => VideoClip(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    imagePath: imagePath ?? this.imagePath,
    clipIndex: clipIndex ?? this.clipIndex,
    durationSec: durationSec ?? this.durationSec,
  );
  VideoClip copyWithCompanion(VideoClipsCompanion data) {
    return VideoClip(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      clipIndex: data.clipIndex.present ? data.clipIndex.value : this.clipIndex,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoClip(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('imagePath: $imagePath, ')
          ..write('clipIndex: $clipIndex, ')
          ..write('durationSec: $durationSec')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, imagePath, clipIndex, durationSec);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoClip &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.imagePath == this.imagePath &&
          other.clipIndex == this.clipIndex &&
          other.durationSec == this.durationSec);
}

class VideoClipsCompanion extends UpdateCompanion<VideoClip> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> imagePath;
  final Value<int> clipIndex;
  final Value<double> durationSec;
  final Value<int> rowid;
  const VideoClipsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.clipIndex = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideoClipsCompanion.insert({
    required String id,
    required String projectId,
    required String imagePath,
    required int clipIndex,
    required double durationSec,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       imagePath = Value(imagePath),
       clipIndex = Value(clipIndex),
       durationSec = Value(durationSec);
  static Insertable<VideoClip> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? imagePath,
    Expression<int>? clipIndex,
    Expression<double>? durationSec,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (imagePath != null) 'image_path': imagePath,
      if (clipIndex != null) 'clip_index': clipIndex,
      if (durationSec != null) 'duration_sec': durationSec,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideoClipsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? imagePath,
    Value<int>? clipIndex,
    Value<double>? durationSec,
    Value<int>? rowid,
  }) {
    return VideoClipsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      imagePath: imagePath ?? this.imagePath,
      clipIndex: clipIndex ?? this.clipIndex,
      durationSec: durationSec ?? this.durationSec,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (clipIndex.present) {
      map['clip_index'] = Variable<int>(clipIndex.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<double>(durationSec.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoClipsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('imagePath: $imagePath, ')
          ..write('clipIndex: $clipIndex, ')
          ..write('durationSec: $durationSec, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppKvEntriesTable extends AppKvEntries
    with TableInfo<$AppKvEntriesTable, AppKvEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppKvEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_kv_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppKvEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppKvEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppKvEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppKvEntriesTable createAlias(String alias) {
    return $AppKvEntriesTable(attachedDatabase, alias);
  }
}

class AppKvEntry extends DataClass implements Insertable<AppKvEntry> {
  final String key;
  final String value;
  const AppKvEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppKvEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppKvEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory AppKvEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppKvEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppKvEntry copyWith({String? key, String? value}) =>
      AppKvEntry(key: key ?? this.key, value: value ?? this.value);
  AppKvEntry copyWithCompanion(AppKvEntriesCompanion data) {
    return AppKvEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppKvEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppKvEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class AppKvEntriesCompanion extends UpdateCompanion<AppKvEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppKvEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppKvEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppKvEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppKvEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppKvEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppKvEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CreditEventsTable extends CreditEvents
    with TableInfo<$CreditEventsTable, CreditEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
    'delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, delta, reason, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreditEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CreditEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CreditEventsTable createAlias(String alias) {
    return $CreditEventsTable(attachedDatabase, alias);
  }
}

class CreditEvent extends DataClass implements Insertable<CreditEvent> {
  final String id;
  final int delta;
  final String reason;
  final DateTime createdAt;
  const CreditEvent({
    required this.id,
    required this.delta,
    required this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['delta'] = Variable<int>(delta);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CreditEventsCompanion toCompanion(bool nullToAbsent) {
    return CreditEventsCompanion(
      id: Value(id),
      delta: Value(delta),
      reason: Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory CreditEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditEvent(
      id: serializer.fromJson<String>(json['id']),
      delta: serializer.fromJson<int>(json['delta']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'delta': serializer.toJson<int>(delta),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CreditEvent copyWith({
    String? id,
    int? delta,
    String? reason,
    DateTime? createdAt,
  }) => CreditEvent(
    id: id ?? this.id,
    delta: delta ?? this.delta,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  CreditEvent copyWithCompanion(CreditEventsCompanion data) {
    return CreditEvent(
      id: data.id.present ? data.id.value : this.id,
      delta: data.delta.present ? data.delta.value : this.delta,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditEvent(')
          ..write('id: $id, ')
          ..write('delta: $delta, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, delta, reason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditEvent &&
          other.id == this.id &&
          other.delta == this.delta &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class CreditEventsCompanion extends UpdateCompanion<CreditEvent> {
  final Value<String> id;
  final Value<int> delta;
  final Value<String> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CreditEventsCompanion({
    this.id = const Value.absent(),
    this.delta = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CreditEventsCompanion.insert({
    required String id,
    required int delta,
    required String reason,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       delta = Value(delta),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<CreditEvent> custom({
    Expression<String>? id,
    Expression<int>? delta,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (delta != null) 'delta': delta,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CreditEventsCompanion copyWith({
    Value<String>? id,
    Value<int>? delta,
    Value<String>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CreditEventsCompanion(
      id: id ?? this.id,
      delta: delta ?? this.delta,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditEventsCompanion(')
          ..write('id: $id, ')
          ..write('delta: $delta, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuthSessionsTable extends AuthSessions
    with TableInfo<$AuthSessionsTable, AuthSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    provider,
    subject,
    email,
    displayName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auth_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuthSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuthSessionsTable createAlias(String alias) {
    return $AuthSessionsTable(attachedDatabase, alias);
  }
}

class AuthSession extends DataClass implements Insertable<AuthSession> {
  final String id;
  final String provider;
  final String subject;
  final String? email;
  final String? displayName;
  final DateTime createdAt;
  const AuthSession({
    required this.id,
    required this.provider,
    required this.subject,
    this.email,
    this.displayName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider'] = Variable<String>(provider);
    map['subject'] = Variable<String>(subject);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuthSessionsCompanion toCompanion(bool nullToAbsent) {
    return AuthSessionsCompanion(
      id: Value(id),
      provider: Value(provider),
      subject: Value(subject),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      createdAt: Value(createdAt),
    );
  }

  factory AuthSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthSession(
      id: serializer.fromJson<String>(json['id']),
      provider: serializer.fromJson<String>(json['provider']),
      subject: serializer.fromJson<String>(json['subject']),
      email: serializer.fromJson<String?>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'provider': serializer.toJson<String>(provider),
      'subject': serializer.toJson<String>(subject),
      'email': serializer.toJson<String?>(email),
      'displayName': serializer.toJson<String?>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuthSession copyWith({
    String? id,
    String? provider,
    String? subject,
    Value<String?> email = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    DateTime? createdAt,
  }) => AuthSession(
    id: id ?? this.id,
    provider: provider ?? this.provider,
    subject: subject ?? this.subject,
    email: email.present ? email.value : this.email,
    displayName: displayName.present ? displayName.value : this.displayName,
    createdAt: createdAt ?? this.createdAt,
  );
  AuthSession copyWithCompanion(AuthSessionsCompanion data) {
    return AuthSession(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      subject: data.subject.present ? data.subject.value : this.subject,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthSession(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('subject: $subject, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, provider, subject, email, displayName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthSession &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.subject == this.subject &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt);
}

class AuthSessionsCompanion extends UpdateCompanion<AuthSession> {
  final Value<String> id;
  final Value<String> provider;
  final Value<String> subject;
  final Value<String?> email;
  final Value<String?> displayName;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AuthSessionsCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.subject = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuthSessionsCompanion.insert({
    required String id,
    required String provider,
    required String subject,
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       provider = Value(provider),
       subject = Value(subject),
       createdAt = Value(createdAt);
  static Insertable<AuthSession> custom({
    Expression<String>? id,
    Expression<String>? provider,
    Expression<String>? subject,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (subject != null) 'subject': subject,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuthSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? provider,
    Value<String>? subject,
    Value<String?>? email,
    Value<String?>? displayName,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AuthSessionsCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      subject: subject ?? this.subject,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthSessionsCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('subject: $subject, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AlbumsTable albums = $AlbumsTable(this);
  late final $BookPagesTable bookPages = $BookPagesTable(this);
  late final $PhotoSlotsTable photoSlots = $PhotoSlotsTable(this);
  late final $CollageProjectsTable collageProjects = $CollageProjectsTable(
    this,
  );
  late final $CollageItemsTable collageItems = $CollageItemsTable(this);
  late final $CollageTextsTable collageTexts = $CollageTextsTable(this);
  late final $VideoProjectsTable videoProjects = $VideoProjectsTable(this);
  late final $VideoClipsTable videoClips = $VideoClipsTable(this);
  late final $AppKvEntriesTable appKvEntries = $AppKvEntriesTable(this);
  late final $CreditEventsTable creditEvents = $CreditEventsTable(this);
  late final $AuthSessionsTable authSessions = $AuthSessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    albums,
    bookPages,
    photoSlots,
    collageProjects,
    collageItems,
    collageTexts,
    videoProjects,
    videoClips,
    appKvEntries,
    creditEvents,
    authSessions,
  ];
}

typedef $$AlbumsTableCreateCompanionBuilder = AlbumsCompanion Function({
  required String id,
  required String title,
  Value<String> themeId,
  Value<String?> coverPhotoPath,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> dateStart,
  Value<DateTime?> dateEnd,
  Value<int> rowid,
});
typedef $$AlbumsTableUpdateCompanionBuilder = AlbumsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> themeId,
  Value<String?> coverPhotoPath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> dateStart,
  Value<DateTime?> dateEnd,
  Value<int> rowid,
});

final class $$AlbumsTableReferences
    extends BaseReferences<_$AppDatabase, $AlbumsTable, Album> {
  $$AlbumsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookPagesTable, List<BookPage>>
  _bookPagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookPages,
    aliasName: 'albums__id__book_pages__album_id',
  );

  $$BookPagesTableProcessedTableManager get bookPagesRefs {
    final manager = $$BookPagesTableTableManager(
      $_db,
      $_db.bookPages,
    ).filter((f) => f.albumId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookPagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeId => $composableBuilder(
    column: $table.themeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPhotoPath => $composableBuilder(
    column: $table.coverPhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateStart => $composableBuilder(
    column: $table.dateStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateEnd => $composableBuilder(
    column: $table.dateEnd,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookPagesRefs(
    Expression<bool> Function($$BookPagesTableFilterComposer f) f,
  ) {
    final $$BookPagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookPages,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookPagesTableFilterComposer(
            $db: $db,
            $table: $db.bookPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeId => $composableBuilder(
    column: $table.themeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPhotoPath => $composableBuilder(
    column: $table.coverPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateStart => $composableBuilder(
    column: $table.dateStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateEnd => $composableBuilder(
    column: $table.dateEnd,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get themeId =>
      $composableBuilder(column: $table.themeId, builder: (column) => column);

  GeneratedColumn<String> get coverPhotoPath => $composableBuilder(
    column: $table.coverPhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dateStart =>
      $composableBuilder(column: $table.dateStart, builder: (column) => column);

  GeneratedColumn<DateTime> get dateEnd =>
      $composableBuilder(column: $table.dateEnd, builder: (column) => column);

  Expression<T> bookPagesRefs<T extends Object>(
    Expression<T> Function($$BookPagesTableAnnotationComposer a) f,
  ) {
    final $$BookPagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookPages,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookPagesTableAnnotationComposer(
            $db: $db,
            $table: $db.bookPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlbumsTable,
          Album,
          $$AlbumsTableFilterComposer,
          $$AlbumsTableOrderingComposer,
          $$AlbumsTableAnnotationComposer,
          $$AlbumsTableCreateCompanionBuilder,
          $$AlbumsTableUpdateCompanionBuilder,
          (Album, $$AlbumsTableReferences),
          Album,
          PrefetchHooks Function({bool bookPagesRefs})
        > {
  $$AlbumsTableTableManager(_$AppDatabase db, $AlbumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> themeId = const Value.absent(),
                Value<String?> coverPhotoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> dateStart = const Value.absent(),
                Value<DateTime?> dateEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsCompanion(
                id: id,
                title: title,
                themeId: themeId,
                coverPhotoPath: coverPhotoPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                dateStart: dateStart,
                dateEnd: dateEnd,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> themeId = const Value.absent(),
                Value<String?> coverPhotoPath = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> dateStart = const Value.absent(),
                Value<DateTime?> dateEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsCompanion.insert(
                id: id,
                title: title,
                themeId: themeId,
                coverPhotoPath: coverPhotoPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                dateStart: dateStart,
                dateEnd: dateEnd,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlbumsTable, Album>(table),
                  $$AlbumsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookPagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookPagesRefs) db.bookPages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookPagesRefs)
                    await $_getPrefetchedData<Album, $AlbumsTable, BookPage>(
                      currentTable: table,
                      referencedTable: $$AlbumsTableReferences
                          ._bookPagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AlbumsTableReferences(db, table, p0).bookPagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.albumId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlbumsTable,
      Album,
      $$AlbumsTableFilterComposer,
      $$AlbumsTableOrderingComposer,
      $$AlbumsTableAnnotationComposer,
      $$AlbumsTableCreateCompanionBuilder,
      $$AlbumsTableUpdateCompanionBuilder,
      (Album, $$AlbumsTableReferences),
      Album,
      PrefetchHooks Function({bool bookPagesRefs})
    >;
typedef $$BookPagesTableCreateCompanionBuilder = BookPagesCompanion Function({
  required String id,
  required String albumId,
  required int pageIndex,
  Value<String> layoutId,
  Value<int> rowid,
});
typedef $$BookPagesTableUpdateCompanionBuilder = BookPagesCompanion Function({
  Value<String> id,
  Value<String> albumId,
  Value<int> pageIndex,
  Value<String> layoutId,
  Value<int> rowid,
});

final class $$BookPagesTableReferences
    extends BaseReferences<_$AppDatabase, $BookPagesTable, BookPage> {
  $$BookPagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AlbumsTable _albumIdTable(_$AppDatabase db) =>
      db.albums.createAlias('book_pages__album_id__albums__id');

  $$AlbumsTableProcessedTableManager get albumId {
    final $_column = $_itemColumn<String>('album_id')!;

    final manager = $$AlbumsTableTableManager(
      $_db,
      $_db.albums,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PhotoSlotsTable, List<PhotoSlot>>
  _photoSlotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.photoSlots,
    aliasName: 'book_pages__id__photo_slots__page_id',
  );

  $$PhotoSlotsTableProcessedTableManager get photoSlotsRefs {
    final manager = $$PhotoSlotsTableTableManager(
      $_db,
      $_db.photoSlots,
    ).filter((f) => f.pageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_photoSlotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BookPagesTableFilterComposer
    extends Composer<_$AppDatabase, $BookPagesTable> {
  $$BookPagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get layoutId => $composableBuilder(
    column: $table.layoutId,
    builder: (column) => ColumnFilters(column),
  );

  $$AlbumsTableFilterComposer get albumId {
    final $$AlbumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableFilterComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> photoSlotsRefs(
    Expression<bool> Function($$PhotoSlotsTableFilterComposer f) f,
  ) {
    final $$PhotoSlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photoSlots,
      getReferencedColumn: (t) => t.pageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotoSlotsTableFilterComposer(
            $db: $db,
            $table: $db.photoSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookPagesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookPagesTable> {
  $$BookPagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get layoutId => $composableBuilder(
    column: $table.layoutId,
    builder: (column) => ColumnOrderings(column),
  );

  $$AlbumsTableOrderingComposer get albumId {
    final $$AlbumsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableOrderingComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookPagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookPagesTable> {
  $$BookPagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<String> get layoutId =>
      $composableBuilder(column: $table.layoutId, builder: (column) => column);

  $$AlbumsTableAnnotationComposer get albumId {
    final $$AlbumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableAnnotationComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> photoSlotsRefs<T extends Object>(
    Expression<T> Function($$PhotoSlotsTableAnnotationComposer a) f,
  ) {
    final $$PhotoSlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photoSlots,
      getReferencedColumn: (t) => t.pageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotoSlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.photoSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookPagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookPagesTable,
          BookPage,
          $$BookPagesTableFilterComposer,
          $$BookPagesTableOrderingComposer,
          $$BookPagesTableAnnotationComposer,
          $$BookPagesTableCreateCompanionBuilder,
          $$BookPagesTableUpdateCompanionBuilder,
          (BookPage, $$BookPagesTableReferences),
          BookPage,
          PrefetchHooks Function({bool albumId, bool photoSlotsRefs})
        > {
  $$BookPagesTableTableManager(_$AppDatabase db, $BookPagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookPagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookPagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookPagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> albumId = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<String> layoutId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookPagesCompanion(
                id: id,
                albumId: albumId,
                pageIndex: pageIndex,
                layoutId: layoutId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String albumId,
                required int pageIndex,
                Value<String> layoutId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookPagesCompanion.insert(
                id: id,
                albumId: albumId,
                pageIndex: pageIndex,
                layoutId: layoutId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookPagesTable, BookPage>(table),
                  $$BookPagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({albumId = false, photoSlotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (photoSlotsRefs) db.photoSlots],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (albumId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.albumId,
                        referencedTable: $$BookPagesTableReferences
                            ._albumIdTable(db),
                        referencedColumn: $$BookPagesTableReferences
                            ._albumIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (photoSlotsRefs)
                    await $_getPrefetchedData<
                      BookPage,
                      $BookPagesTable,
                      PhotoSlot
                    >(
                      currentTable: table,
                      referencedTable: $$BookPagesTableReferences
                          ._photoSlotsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BookPagesTableReferences(
                            db,
                            table,
                            p0,
                          ).photoSlotsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.pageId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BookPagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookPagesTable,
      BookPage,
      $$BookPagesTableFilterComposer,
      $$BookPagesTableOrderingComposer,
      $$BookPagesTableAnnotationComposer,
      $$BookPagesTableCreateCompanionBuilder,
      $$BookPagesTableUpdateCompanionBuilder,
      (BookPage, $$BookPagesTableReferences),
      BookPage,
      PrefetchHooks Function({bool albumId, bool photoSlotsRefs})
    >;
typedef $$PhotoSlotsTableCreateCompanionBuilder = PhotoSlotsCompanion Function({
  required String id,
  required String pageId,
  required int slotIndex,
  Value<String?> imagePath,
  Value<String> caption,
  Value<double> scale,
  Value<double> offsetX,
  Value<double> offsetY,
  Value<String> filterId,
  Value<bool> showDate,
  Value<int> rowid,
});
typedef $$PhotoSlotsTableUpdateCompanionBuilder = PhotoSlotsCompanion Function({
  Value<String> id,
  Value<String> pageId,
  Value<int> slotIndex,
  Value<String?> imagePath,
  Value<String> caption,
  Value<double> scale,
  Value<double> offsetX,
  Value<double> offsetY,
  Value<String> filterId,
  Value<bool> showDate,
  Value<int> rowid,
});

final class $$PhotoSlotsTableReferences
    extends BaseReferences<_$AppDatabase, $PhotoSlotsTable, PhotoSlot> {
  $$PhotoSlotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BookPagesTable _pageIdTable(_$AppDatabase db) =>
      db.bookPages.createAlias('photo_slots__page_id__book_pages__id');

  $$BookPagesTableProcessedTableManager get pageId {
    final $_column = $_itemColumn<String>('page_id')!;

    final manager = $$BookPagesTableTableManager(
      $_db,
      $_db.bookPages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhotoSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $PhotoSlotsTable> {
  $$PhotoSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slotIndex => $composableBuilder(
    column: $table.slotIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scale => $composableBuilder(
    column: $table.scale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get offsetX => $composableBuilder(
    column: $table.offsetX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get offsetY => $composableBuilder(
    column: $table.offsetY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterId => $composableBuilder(
    column: $table.filterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showDate => $composableBuilder(
    column: $table.showDate,
    builder: (column) => ColumnFilters(column),
  );

  $$BookPagesTableFilterComposer get pageId {
    final $$BookPagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.bookPages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookPagesTableFilterComposer(
            $db: $db,
            $table: $db.bookPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotoSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotoSlotsTable> {
  $$PhotoSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slotIndex => $composableBuilder(
    column: $table.slotIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scale => $composableBuilder(
    column: $table.scale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get offsetX => $composableBuilder(
    column: $table.offsetX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get offsetY => $composableBuilder(
    column: $table.offsetY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterId => $composableBuilder(
    column: $table.filterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showDate => $composableBuilder(
    column: $table.showDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$BookPagesTableOrderingComposer get pageId {
    final $$BookPagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.bookPages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookPagesTableOrderingComposer(
            $db: $db,
            $table: $db.bookPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotoSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotoSlotsTable> {
  $$PhotoSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get slotIndex =>
      $composableBuilder(column: $table.slotIndex, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<double> get scale =>
      $composableBuilder(column: $table.scale, builder: (column) => column);

  GeneratedColumn<double> get offsetX =>
      $composableBuilder(column: $table.offsetX, builder: (column) => column);

  GeneratedColumn<double> get offsetY =>
      $composableBuilder(column: $table.offsetY, builder: (column) => column);

  GeneratedColumn<String> get filterId =>
      $composableBuilder(column: $table.filterId, builder: (column) => column);

  GeneratedColumn<bool> get showDate =>
      $composableBuilder(column: $table.showDate, builder: (column) => column);

  $$BookPagesTableAnnotationComposer get pageId {
    final $$BookPagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.bookPages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookPagesTableAnnotationComposer(
            $db: $db,
            $table: $db.bookPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotoSlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotoSlotsTable,
          PhotoSlot,
          $$PhotoSlotsTableFilterComposer,
          $$PhotoSlotsTableOrderingComposer,
          $$PhotoSlotsTableAnnotationComposer,
          $$PhotoSlotsTableCreateCompanionBuilder,
          $$PhotoSlotsTableUpdateCompanionBuilder,
          (PhotoSlot, $$PhotoSlotsTableReferences),
          PhotoSlot,
          PrefetchHooks Function({bool pageId})
        > {
  $$PhotoSlotsTableTableManager(_$AppDatabase db, $PhotoSlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotoSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotoSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotoSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pageId = const Value.absent(),
                Value<int> slotIndex = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String> caption = const Value.absent(),
                Value<double> scale = const Value.absent(),
                Value<double> offsetX = const Value.absent(),
                Value<double> offsetY = const Value.absent(),
                Value<String> filterId = const Value.absent(),
                Value<bool> showDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotoSlotsCompanion(
                id: id,
                pageId: pageId,
                slotIndex: slotIndex,
                imagePath: imagePath,
                caption: caption,
                scale: scale,
                offsetX: offsetX,
                offsetY: offsetY,
                filterId: filterId,
                showDate: showDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pageId,
                required int slotIndex,
                Value<String?> imagePath = const Value.absent(),
                Value<String> caption = const Value.absent(),
                Value<double> scale = const Value.absent(),
                Value<double> offsetX = const Value.absent(),
                Value<double> offsetY = const Value.absent(),
                Value<String> filterId = const Value.absent(),
                Value<bool> showDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotoSlotsCompanion.insert(
                id: id,
                pageId: pageId,
                slotIndex: slotIndex,
                imagePath: imagePath,
                caption: caption,
                scale: scale,
                offsetX: offsetX,
                offsetY: offsetY,
                filterId: filterId,
                showDate: showDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotoSlotsTable, PhotoSlot>(table),
                  $$PhotoSlotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pageId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pageId,
                        referencedTable: $$PhotoSlotsTableReferences
                            ._pageIdTable(db),
                        referencedColumn: $$PhotoSlotsTableReferences
                            ._pageIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PhotoSlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotoSlotsTable,
      PhotoSlot,
      $$PhotoSlotsTableFilterComposer,
      $$PhotoSlotsTableOrderingComposer,
      $$PhotoSlotsTableAnnotationComposer,
      $$PhotoSlotsTableCreateCompanionBuilder,
      $$PhotoSlotsTableUpdateCompanionBuilder,
      (PhotoSlot, $$PhotoSlotsTableReferences),
      PhotoSlot,
      PrefetchHooks Function({bool pageId})
    >;
typedef $$CollageProjectsTableCreateCompanionBuilder =
    CollageProjectsCompanion Function({
      required String id,
      required String title,
      required String templateId,
      Value<String> background,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CollageProjectsTableUpdateCompanionBuilder =
    CollageProjectsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> templateId,
      Value<String> background,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CollageProjectsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CollageProjectsTable, CollageProject> {
  $$CollageProjectsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CollageItemsTable, List<CollageItem>>
  _collageItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collageItems,
    aliasName: 'collage_projects__id__collage_items__project_id',
  );

  $$CollageItemsTableProcessedTableManager get collageItemsRefs {
    final manager = $$CollageItemsTableTableManager(
      $_db,
      $_db.collageItems,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_collageItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CollageTextsTable, List<CollageText>>
  _collageTextsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collageTexts,
    aliasName: 'collage_projects__id__collage_texts__project_id',
  );

  $$CollageTextsTableProcessedTableManager get collageTextsRefs {
    final manager = $$CollageTextsTableTableManager(
      $_db,
      $_db.collageTexts,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_collageTextsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollageProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $CollageProjectsTable> {
  $$CollageProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> collageItemsRefs(
    Expression<bool> Function($$CollageItemsTableFilterComposer f) f,
  ) {
    final $$CollageItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collageItems,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollageItemsTableFilterComposer(
            $db: $db,
            $table: $db.collageItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> collageTextsRefs(
    Expression<bool> Function($$CollageTextsTableFilterComposer f) f,
  ) {
    final $$CollageTextsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collageTexts,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollageTextsTableFilterComposer(
            $db: $db,
            $table: $db.collageTexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollageProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollageProjectsTable> {
  $$CollageProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollageProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollageProjectsTable> {
  $$CollageProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> collageItemsRefs<T extends Object>(
    Expression<T> Function($$CollageItemsTableAnnotationComposer a) f,
  ) {
    final $$CollageItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collageItems,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollageItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.collageItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> collageTextsRefs<T extends Object>(
    Expression<T> Function($$CollageTextsTableAnnotationComposer a) f,
  ) {
    final $$CollageTextsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collageTexts,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollageTextsTableAnnotationComposer(
            $db: $db,
            $table: $db.collageTexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollageProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollageProjectsTable,
          CollageProject,
          $$CollageProjectsTableFilterComposer,
          $$CollageProjectsTableOrderingComposer,
          $$CollageProjectsTableAnnotationComposer,
          $$CollageProjectsTableCreateCompanionBuilder,
          $$CollageProjectsTableUpdateCompanionBuilder,
          (CollageProject, $$CollageProjectsTableReferences),
          CollageProject,
          PrefetchHooks Function({bool collageItemsRefs, bool collageTextsRefs})
        > {
  $$CollageProjectsTableTableManager(
    _$AppDatabase db,
    $CollageProjectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollageProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollageProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollageProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> background = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollageProjectsCompanion(
                id: id,
                title: title,
                templateId: templateId,
                background: background,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String templateId,
                Value<String> background = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CollageProjectsCompanion.insert(
                id: id,
                title: title,
                templateId: templateId,
                background: background,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollageProjectsTable, CollageProject>(table),
                  $$CollageProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({collageItemsRefs = false, collageTextsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (collageItemsRefs) db.collageItems,
                    if (collageTextsRefs) db.collageTexts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (collageItemsRefs)
                        await $_getPrefetchedData<
                          CollageProject,
                          $CollageProjectsTable,
                          CollageItem
                        >(
                          currentTable: table,
                          referencedTable: $$CollageProjectsTableReferences
                              ._collageItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollageProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).collageItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (collageTextsRefs)
                        await $_getPrefetchedData<
                          CollageProject,
                          $CollageProjectsTable,
                          CollageText
                        >(
                          currentTable: table,
                          referencedTable: $$CollageProjectsTableReferences
                              ._collageTextsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollageProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).collageTextsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CollageProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollageProjectsTable,
      CollageProject,
      $$CollageProjectsTableFilterComposer,
      $$CollageProjectsTableOrderingComposer,
      $$CollageProjectsTableAnnotationComposer,
      $$CollageProjectsTableCreateCompanionBuilder,
      $$CollageProjectsTableUpdateCompanionBuilder,
      (CollageProject, $$CollageProjectsTableReferences),
      CollageProject,
      PrefetchHooks Function({bool collageItemsRefs, bool collageTextsRefs})
    >;
typedef $$CollageItemsTableCreateCompanionBuilder =
    CollageItemsCompanion Function({
      required String id,
      required String projectId,
      required String imagePath,
      required int itemIndex,
      Value<double> scale,
      Value<double> offsetX,
      Value<double> offsetY,
      Value<int> rowid,
    });
typedef $$CollageItemsTableUpdateCompanionBuilder =
    CollageItemsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> imagePath,
      Value<int> itemIndex,
      Value<double> scale,
      Value<double> offsetX,
      Value<double> offsetY,
      Value<int> rowid,
    });

final class $$CollageItemsTableReferences
    extends BaseReferences<_$AppDatabase, $CollageItemsTable, CollageItem> {
  $$CollageItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollageProjectsTable _projectIdTable(_$AppDatabase db) => db
      .collageProjects
      .createAlias('collage_items__project_id__collage_projects__id');

  $$CollageProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$CollageProjectsTableTableManager(
      $_db,
      $_db.collageProjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CollageItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CollageItemsTable> {
  $$CollageItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scale => $composableBuilder(
    column: $table.scale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get offsetX => $composableBuilder(
    column: $table.offsetX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get offsetY => $composableBuilder(
    column: $table.offsetY,
    builder: (column) => ColumnFilters(column),
  );

  $$CollageProjectsTableFilterComposer get projectId {
    final $$CollageProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.collageProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollageProjectsTableFilterComposer(
            $db: $db,
            $table: $db.collageProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollageItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollageItemsTable> {
  $$CollageItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scale => $composableBuilder(
    column: $table.scale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get offsetX => $composableBuilder(
    column: $table.offsetX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get offsetY => $composableBuilder(
    column: $table.offsetY,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollageProjectsTableOrderingComposer get projectId {
    final $$CollageProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.collageProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollageProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.collageProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollageItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollageItemsTable> {
  $$CollageItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<int> get itemIndex =>
      $composableBuilder(column: $table.itemIndex, builder: (column) => column);

  GeneratedColumn<double> get scale =>
      $composableBuilder(column: $table.scale, builder: (column) => column);

  GeneratedColumn<double> get offsetX =>
      $composableBuilder(column: $table.offsetX, builder: (column) => column);

  GeneratedColumn<double> get offsetY =>
      $composableBuilder(column: $table.offsetY, builder: (column) => column);

  $$CollageProjectsTableAnnotationComposer get projectId {
    final $$CollageProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.collageProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollageProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.collageProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollageItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollageItemsTable,
          CollageItem,
          $$CollageItemsTableFilterComposer,
          $$CollageItemsTableOrderingComposer,
          $$CollageItemsTableAnnotationComposer,
          $$CollageItemsTableCreateCompanionBuilder,
          $$CollageItemsTableUpdateCompanionBuilder,
          (CollageItem, $$CollageItemsTableReferences),
          CollageItem,
          PrefetchHooks Function({bool projectId})
        > {
  $$CollageItemsTableTableManager(_$AppDatabase db, $CollageItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollageItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollageItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollageItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<int> itemIndex = const Value.absent(),
                Value<double> scale = const Value.absent(),
                Value<double> offsetX = const Value.absent(),
                Value<double> offsetY = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollageItemsCompanion(
                id: id,
                projectId: projectId,
                imagePath: imagePath,
                itemIndex: itemIndex,
                scale: scale,
                offsetX: offsetX,
                offsetY: offsetY,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String imagePath,
                required int itemIndex,
                Value<double> scale = const Value.absent(),
                Value<double> offsetX = const Value.absent(),
                Value<double> offsetY = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollageItemsCompanion.insert(
                id: id,
                projectId: projectId,
                imagePath: imagePath,
                itemIndex: itemIndex,
                scale: scale,
                offsetX: offsetX,
                offsetY: offsetY,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollageItemsTable, CollageItem>(table),
                  $$CollageItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.projectId,
                        referencedTable: $$CollageItemsTableReferences
                            ._projectIdTable(db),
                        referencedColumn: $$CollageItemsTableReferences
                            ._projectIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CollageItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollageItemsTable,
      CollageItem,
      $$CollageItemsTableFilterComposer,
      $$CollageItemsTableOrderingComposer,
      $$CollageItemsTableAnnotationComposer,
      $$CollageItemsTableCreateCompanionBuilder,
      $$CollageItemsTableUpdateCompanionBuilder,
      (CollageItem, $$CollageItemsTableReferences),
      CollageItem,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$CollageTextsTableCreateCompanionBuilder =
    CollageTextsCompanion Function({
      required String id,
      required String projectId,
      required String body,
      required double nx,
      required double ny,
      required int colorValue,
      Value<int> rowid,
    });
typedef $$CollageTextsTableUpdateCompanionBuilder =
    CollageTextsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> body,
      Value<double> nx,
      Value<double> ny,
      Value<int> colorValue,
      Value<int> rowid,
    });

final class $$CollageTextsTableReferences
    extends BaseReferences<_$AppDatabase, $CollageTextsTable, CollageText> {
  $$CollageTextsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollageProjectsTable _projectIdTable(_$AppDatabase db) => db
      .collageProjects
      .createAlias('collage_texts__project_id__collage_projects__id');

  $$CollageProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$CollageProjectsTableTableManager(
      $_db,
      $_db.collageProjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CollageTextsTableFilterComposer
    extends Composer<_$AppDatabase, $CollageTextsTable> {
  $$CollageTextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nx => $composableBuilder(
    column: $table.nx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ny => $composableBuilder(
    column: $table.ny,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  $$CollageProjectsTableFilterComposer get projectId {
    final $$CollageProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.collageProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollageProjectsTableFilterComposer(
            $db: $db,
            $table: $db.collageProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollageTextsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollageTextsTable> {
  $$CollageTextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nx => $composableBuilder(
    column: $table.nx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ny => $composableBuilder(
    column: $table.ny,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollageProjectsTableOrderingComposer get projectId {
    final $$CollageProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.collageProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollageProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.collageProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollageTextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollageTextsTable> {
  $$CollageTextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<double> get nx =>
      $composableBuilder(column: $table.nx, builder: (column) => column);

  GeneratedColumn<double> get ny =>
      $composableBuilder(column: $table.ny, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  $$CollageProjectsTableAnnotationComposer get projectId {
    final $$CollageProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.collageProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollageProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.collageProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollageTextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollageTextsTable,
          CollageText,
          $$CollageTextsTableFilterComposer,
          $$CollageTextsTableOrderingComposer,
          $$CollageTextsTableAnnotationComposer,
          $$CollageTextsTableCreateCompanionBuilder,
          $$CollageTextsTableUpdateCompanionBuilder,
          (CollageText, $$CollageTextsTableReferences),
          CollageText,
          PrefetchHooks Function({bool projectId})
        > {
  $$CollageTextsTableTableManager(_$AppDatabase db, $CollageTextsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollageTextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollageTextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollageTextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<double> nx = const Value.absent(),
                Value<double> ny = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollageTextsCompanion(
                id: id,
                projectId: projectId,
                body: body,
                nx: nx,
                ny: ny,
                colorValue: colorValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String body,
                required double nx,
                required double ny,
                required int colorValue,
                Value<int> rowid = const Value.absent(),
              }) => CollageTextsCompanion.insert(
                id: id,
                projectId: projectId,
                body: body,
                nx: nx,
                ny: ny,
                colorValue: colorValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollageTextsTable, CollageText>(table),
                  $$CollageTextsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.projectId,
                        referencedTable: $$CollageTextsTableReferences
                            ._projectIdTable(db),
                        referencedColumn: $$CollageTextsTableReferences
                            ._projectIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CollageTextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollageTextsTable,
      CollageText,
      $$CollageTextsTableFilterComposer,
      $$CollageTextsTableOrderingComposer,
      $$CollageTextsTableAnnotationComposer,
      $$CollageTextsTableCreateCompanionBuilder,
      $$CollageTextsTableUpdateCompanionBuilder,
      (CollageText, $$CollageTextsTableReferences),
      CollageText,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$VideoProjectsTableCreateCompanionBuilder =
    VideoProjectsCompanion Function({
      required String id,
      required String title,
      Value<String> aspect,
      Value<String> filterId,
      Value<String> transition,
      Value<String?> musicPath,
      Value<double> secondsPerSlide,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$VideoProjectsTableUpdateCompanionBuilder =
    VideoProjectsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> aspect,
      Value<String> filterId,
      Value<String> transition,
      Value<String?> musicPath,
      Value<double> secondsPerSlide,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$VideoProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $VideoProjectsTable, VideoProject> {
  $$VideoProjectsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$VideoClipsTable, List<VideoClip>>
  _videoClipsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.videoClips,
    aliasName: 'video_projects__id__video_clips__project_id',
  );

  $$VideoClipsTableProcessedTableManager get videoClipsRefs {
    final manager = $$VideoClipsTableTableManager(
      $_db,
      $_db.videoClips,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_videoClipsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VideoProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $VideoProjectsTable> {
  $$VideoProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aspect => $composableBuilder(
    column: $table.aspect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterId => $composableBuilder(
    column: $table.filterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transition => $composableBuilder(
    column: $table.transition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get musicPath => $composableBuilder(
    column: $table.musicPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get secondsPerSlide => $composableBuilder(
    column: $table.secondsPerSlide,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> videoClipsRefs(
    Expression<bool> Function($$VideoClipsTableFilterComposer f) f,
  ) {
    final $$VideoClipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.videoClips,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideoClipsTableFilterComposer(
            $db: $db,
            $table: $db.videoClips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VideoProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoProjectsTable> {
  $$VideoProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aspect => $composableBuilder(
    column: $table.aspect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterId => $composableBuilder(
    column: $table.filterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transition => $composableBuilder(
    column: $table.transition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get musicPath => $composableBuilder(
    column: $table.musicPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get secondsPerSlide => $composableBuilder(
    column: $table.secondsPerSlide,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideoProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoProjectsTable> {
  $$VideoProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get aspect =>
      $composableBuilder(column: $table.aspect, builder: (column) => column);

  GeneratedColumn<String> get filterId =>
      $composableBuilder(column: $table.filterId, builder: (column) => column);

  GeneratedColumn<String> get transition => $composableBuilder(
    column: $table.transition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get musicPath =>
      $composableBuilder(column: $table.musicPath, builder: (column) => column);

  GeneratedColumn<double> get secondsPerSlide => $composableBuilder(
    column: $table.secondsPerSlide,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> videoClipsRefs<T extends Object>(
    Expression<T> Function($$VideoClipsTableAnnotationComposer a) f,
  ) {
    final $$VideoClipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.videoClips,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideoClipsTableAnnotationComposer(
            $db: $db,
            $table: $db.videoClips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VideoProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideoProjectsTable,
          VideoProject,
          $$VideoProjectsTableFilterComposer,
          $$VideoProjectsTableOrderingComposer,
          $$VideoProjectsTableAnnotationComposer,
          $$VideoProjectsTableCreateCompanionBuilder,
          $$VideoProjectsTableUpdateCompanionBuilder,
          (VideoProject, $$VideoProjectsTableReferences),
          VideoProject,
          PrefetchHooks Function({bool videoClipsRefs})
        > {
  $$VideoProjectsTableTableManager(_$AppDatabase db, $VideoProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> aspect = const Value.absent(),
                Value<String> filterId = const Value.absent(),
                Value<String> transition = const Value.absent(),
                Value<String?> musicPath = const Value.absent(),
                Value<double> secondsPerSlide = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideoProjectsCompanion(
                id: id,
                title: title,
                aspect: aspect,
                filterId: filterId,
                transition: transition,
                musicPath: musicPath,
                secondsPerSlide: secondsPerSlide,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> aspect = const Value.absent(),
                Value<String> filterId = const Value.absent(),
                Value<String> transition = const Value.absent(),
                Value<String?> musicPath = const Value.absent(),
                Value<double> secondsPerSlide = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => VideoProjectsCompanion.insert(
                id: id,
                title: title,
                aspect: aspect,
                filterId: filterId,
                transition: transition,
                musicPath: musicPath,
                secondsPerSlide: secondsPerSlide,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VideoProjectsTable, VideoProject>(table),
                  $$VideoProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({videoClipsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (videoClipsRefs) db.videoClips],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (videoClipsRefs)
                    await $_getPrefetchedData<
                      VideoProject,
                      $VideoProjectsTable,
                      VideoClip
                    >(
                      currentTable: table,
                      referencedTable: $$VideoProjectsTableReferences
                          ._videoClipsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$VideoProjectsTableReferences(
                            db,
                            table,
                            p0,
                          ).videoClipsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.projectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VideoProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideoProjectsTable,
      VideoProject,
      $$VideoProjectsTableFilterComposer,
      $$VideoProjectsTableOrderingComposer,
      $$VideoProjectsTableAnnotationComposer,
      $$VideoProjectsTableCreateCompanionBuilder,
      $$VideoProjectsTableUpdateCompanionBuilder,
      (VideoProject, $$VideoProjectsTableReferences),
      VideoProject,
      PrefetchHooks Function({bool videoClipsRefs})
    >;
typedef $$VideoClipsTableCreateCompanionBuilder = VideoClipsCompanion Function({
  required String id,
  required String projectId,
  required String imagePath,
  required int clipIndex,
  required double durationSec,
  Value<int> rowid,
});
typedef $$VideoClipsTableUpdateCompanionBuilder = VideoClipsCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> imagePath,
  Value<int> clipIndex,
  Value<double> durationSec,
  Value<int> rowid,
});

final class $$VideoClipsTableReferences
    extends BaseReferences<_$AppDatabase, $VideoClipsTable, VideoClip> {
  $$VideoClipsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VideoProjectsTable _projectIdTable(_$AppDatabase db) => db
      .videoProjects
      .createAlias('video_clips__project_id__video_projects__id');

  $$VideoProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$VideoProjectsTableTableManager(
      $_db,
      $_db.videoProjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VideoClipsTableFilterComposer
    extends Composer<_$AppDatabase, $VideoClipsTable> {
  $$VideoClipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clipIndex => $composableBuilder(
    column: $table.clipIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  $$VideoProjectsTableFilterComposer get projectId {
    final $$VideoProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.videoProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideoProjectsTableFilterComposer(
            $db: $db,
            $table: $db.videoProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VideoClipsTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoClipsTable> {
  $$VideoClipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clipIndex => $composableBuilder(
    column: $table.clipIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  $$VideoProjectsTableOrderingComposer get projectId {
    final $$VideoProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.videoProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideoProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.videoProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VideoClipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoClipsTable> {
  $$VideoClipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<int> get clipIndex =>
      $composableBuilder(column: $table.clipIndex, builder: (column) => column);

  GeneratedColumn<double> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  $$VideoProjectsTableAnnotationComposer get projectId {
    final $$VideoProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.videoProjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideoProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.videoProjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VideoClipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideoClipsTable,
          VideoClip,
          $$VideoClipsTableFilterComposer,
          $$VideoClipsTableOrderingComposer,
          $$VideoClipsTableAnnotationComposer,
          $$VideoClipsTableCreateCompanionBuilder,
          $$VideoClipsTableUpdateCompanionBuilder,
          (VideoClip, $$VideoClipsTableReferences),
          VideoClip,
          PrefetchHooks Function({bool projectId})
        > {
  $$VideoClipsTableTableManager(_$AppDatabase db, $VideoClipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoClipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoClipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoClipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<int> clipIndex = const Value.absent(),
                Value<double> durationSec = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideoClipsCompanion(
                id: id,
                projectId: projectId,
                imagePath: imagePath,
                clipIndex: clipIndex,
                durationSec: durationSec,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String imagePath,
                required int clipIndex,
                required double durationSec,
                Value<int> rowid = const Value.absent(),
              }) => VideoClipsCompanion.insert(
                id: id,
                projectId: projectId,
                imagePath: imagePath,
                clipIndex: clipIndex,
                durationSec: durationSec,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VideoClipsTable, VideoClip>(table),
                  $$VideoClipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.projectId,
                        referencedTable: $$VideoClipsTableReferences
                            ._projectIdTable(db),
                        referencedColumn: $$VideoClipsTableReferences
                            ._projectIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VideoClipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideoClipsTable,
      VideoClip,
      $$VideoClipsTableFilterComposer,
      $$VideoClipsTableOrderingComposer,
      $$VideoClipsTableAnnotationComposer,
      $$VideoClipsTableCreateCompanionBuilder,
      $$VideoClipsTableUpdateCompanionBuilder,
      (VideoClip, $$VideoClipsTableReferences),
      VideoClip,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$AppKvEntriesTableCreateCompanionBuilder =
    AppKvEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppKvEntriesTableUpdateCompanionBuilder =
    AppKvEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppKvEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AppKvEntriesTable> {
  $$AppKvEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppKvEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppKvEntriesTable> {
  $$AppKvEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppKvEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppKvEntriesTable> {
  $$AppKvEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppKvEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppKvEntriesTable,
          AppKvEntry,
          $$AppKvEntriesTableFilterComposer,
          $$AppKvEntriesTableOrderingComposer,
          $$AppKvEntriesTableAnnotationComposer,
          $$AppKvEntriesTableCreateCompanionBuilder,
          $$AppKvEntriesTableUpdateCompanionBuilder,
          (
            AppKvEntry,
            BaseReferences<_$AppDatabase, $AppKvEntriesTable, AppKvEntry>,
          ),
          AppKvEntry,
          PrefetchHooks Function()
        > {
  $$AppKvEntriesTableTableManager(_$AppDatabase db, $AppKvEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppKvEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppKvEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppKvEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppKvEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppKvEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppKvEntriesTable, AppKvEntry>(table),
                  BaseReferences<_$AppDatabase, $AppKvEntriesTable, AppKvEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppKvEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppKvEntriesTable,
      AppKvEntry,
      $$AppKvEntriesTableFilterComposer,
      $$AppKvEntriesTableOrderingComposer,
      $$AppKvEntriesTableAnnotationComposer,
      $$AppKvEntriesTableCreateCompanionBuilder,
      $$AppKvEntriesTableUpdateCompanionBuilder,
      (
        AppKvEntry,
        BaseReferences<_$AppDatabase, $AppKvEntriesTable, AppKvEntry>,
      ),
      AppKvEntry,
      PrefetchHooks Function()
    >;
typedef $$CreditEventsTableCreateCompanionBuilder =
    CreditEventsCompanion Function({
      required String id,
      required int delta,
      required String reason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CreditEventsTableUpdateCompanionBuilder =
    CreditEventsCompanion Function({
      Value<String> id,
      Value<int> delta,
      Value<String> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CreditEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CreditEventsTable> {
  $$CreditEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CreditEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditEventsTable> {
  $$CreditEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CreditEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditEventsTable> {
  $$CreditEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CreditEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CreditEventsTable,
          CreditEvent,
          $$CreditEventsTableFilterComposer,
          $$CreditEventsTableOrderingComposer,
          $$CreditEventsTableAnnotationComposer,
          $$CreditEventsTableCreateCompanionBuilder,
          $$CreditEventsTableUpdateCompanionBuilder,
          (
            CreditEvent,
            BaseReferences<_$AppDatabase, $CreditEventsTable, CreditEvent>,
          ),
          CreditEvent,
          PrefetchHooks Function()
        > {
  $$CreditEventsTableTableManager(_$AppDatabase db, $CreditEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreditEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CreditEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> delta = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreditEventsCompanion(
                id: id,
                delta: delta,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int delta,
                required String reason,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CreditEventsCompanion.insert(
                id: id,
                delta: delta,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CreditEventsTable, CreditEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CreditEventsTable,
                    CreditEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CreditEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CreditEventsTable,
      CreditEvent,
      $$CreditEventsTableFilterComposer,
      $$CreditEventsTableOrderingComposer,
      $$CreditEventsTableAnnotationComposer,
      $$CreditEventsTableCreateCompanionBuilder,
      $$CreditEventsTableUpdateCompanionBuilder,
      (
        CreditEvent,
        BaseReferences<_$AppDatabase, $CreditEventsTable, CreditEvent>,
      ),
      CreditEvent,
      PrefetchHooks Function()
    >;
typedef $$AuthSessionsTableCreateCompanionBuilder =
    AuthSessionsCompanion Function({
      required String id,
      required String provider,
      required String subject,
      Value<String?> email,
      Value<String?> displayName,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AuthSessionsTableUpdateCompanionBuilder =
    AuthSessionsCompanion Function({
      Value<String> id,
      Value<String> provider,
      Value<String> subject,
      Value<String?> email,
      Value<String?> displayName,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AuthSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $AuthSessionsTable> {
  $$AuthSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuthSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthSessionsTable> {
  $$AuthSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuthSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthSessionsTable> {
  $$AuthSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuthSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuthSessionsTable,
          AuthSession,
          $$AuthSessionsTableFilterComposer,
          $$AuthSessionsTableOrderingComposer,
          $$AuthSessionsTableAnnotationComposer,
          $$AuthSessionsTableCreateCompanionBuilder,
          $$AuthSessionsTableUpdateCompanionBuilder,
          (
            AuthSession,
            BaseReferences<_$AppDatabase, $AuthSessionsTable, AuthSession>,
          ),
          AuthSession,
          PrefetchHooks Function()
        > {
  $$AuthSessionsTableTableManager(_$AppDatabase db, $AuthSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthSessionsCompanion(
                id: id,
                provider: provider,
                subject: subject,
                email: email,
                displayName: displayName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String provider,
                required String subject,
                Value<String?> email = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AuthSessionsCompanion.insert(
                id: id,
                provider: provider,
                subject: subject,
                email: email,
                displayName: displayName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuthSessionsTable, AuthSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AuthSessionsTable,
                    AuthSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuthSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuthSessionsTable,
      AuthSession,
      $$AuthSessionsTableFilterComposer,
      $$AuthSessionsTableOrderingComposer,
      $$AuthSessionsTableAnnotationComposer,
      $$AuthSessionsTableCreateCompanionBuilder,
      $$AuthSessionsTableUpdateCompanionBuilder,
      (
        AuthSession,
        BaseReferences<_$AppDatabase, $AuthSessionsTable, AuthSession>,
      ),
      AuthSession,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AlbumsTableTableManager get albums =>
      $$AlbumsTableTableManager(_db, _db.albums);
  $$BookPagesTableTableManager get bookPages =>
      $$BookPagesTableTableManager(_db, _db.bookPages);
  $$PhotoSlotsTableTableManager get photoSlots =>
      $$PhotoSlotsTableTableManager(_db, _db.photoSlots);
  $$CollageProjectsTableTableManager get collageProjects =>
      $$CollageProjectsTableTableManager(_db, _db.collageProjects);
  $$CollageItemsTableTableManager get collageItems =>
      $$CollageItemsTableTableManager(_db, _db.collageItems);
  $$CollageTextsTableTableManager get collageTexts =>
      $$CollageTextsTableTableManager(_db, _db.collageTexts);
  $$VideoProjectsTableTableManager get videoProjects =>
      $$VideoProjectsTableTableManager(_db, _db.videoProjects);
  $$VideoClipsTableTableManager get videoClips =>
      $$VideoClipsTableTableManager(_db, _db.videoClips);
  $$AppKvEntriesTableTableManager get appKvEntries =>
      $$AppKvEntriesTableTableManager(_db, _db.appKvEntries);
  $$CreditEventsTableTableManager get creditEvents =>
      $$CreditEventsTableTableManager(_db, _db.creditEvents);
  $$AuthSessionsTableTableManager get authSessions =>
      $$AuthSessionsTableTableManager(_db, _db.authSessions);
}
