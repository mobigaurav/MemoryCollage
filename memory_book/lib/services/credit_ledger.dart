import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/db/app_database.dart';

class CreditLedger {
  CreditLedger(this._db);
  final AppDatabase _db;
  final _uuid = const Uuid();

  Future<int> balance() async {
    final rows = await _db.select(_db.creditEvents).get();
    return rows.fold<int>(0, (sum, row) => sum + row.delta);
  }

  Stream<int> watchBalance() {
    return _db.select(_db.creditEvents).watch().map(
          (rows) => rows.fold<int>(0, (sum, row) => sum + row.delta),
        );
  }

  Future<void> grant(int amount, String reason) async {
    await _db.into(_db.creditEvents).insert(
          CreditEventsCompanion.insert(
            id: _uuid.v4(),
            delta: amount,
            reason: reason,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<bool> spend(int amount, String reason) async {
    if (await balance() < amount) return false;
    await grant(-amount, reason);
    return true;
  }
}

class AuthAccount {
  const AuthAccount({
    required this.provider,
    required this.subject,
    this.email,
    this.displayName,
  });

  final String provider;
  final String subject;
  final String? email;
  final String? displayName;
}

class AuthRepository {
  AuthRepository(this._db);
  final AppDatabase _db;
  final _uuid = const Uuid();

  Future<AuthSession?> current() async {
    final rows = await _db.select(_db.authSessions).get();
    return rows.isEmpty ? null : rows.last;
  }

  Stream<AuthSession?> watch() {
    return _db.select(_db.authSessions).watch().map(
          (rows) => rows.isEmpty ? null : rows.last,
        );
  }

  Future<void> save(AuthAccount account) async {
    await _db.delete(_db.authSessions).go();
    await _db.into(_db.authSessions).insert(
          AuthSessionsCompanion.insert(
            id: _uuid.v4(),
            provider: account.provider,
            subject: account.subject,
            email: Value(account.email),
            displayName: Value(account.displayName),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> signOut() => _db.delete(_db.authSessions).go();
}
