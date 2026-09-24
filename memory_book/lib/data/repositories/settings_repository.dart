
import '../db/app_database.dart';

class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  static const onboardingKey = 'onboardingComplete';
  static const localPremiumKey = 'localPremium';
  static const exportHistoryKey = 'exportHistory';
  static const weeklyNudgeKey = 'weeklyPhotosNudge';
  static const weeklyNudgeAtKey = 'weeklyPhotosNudgeAt';
  static const localAccountEmailKey = 'localAccountEmail';
  static const cognitoIdTokenKey = 'cognitoIdToken';
  static const cognitoRefreshTokenKey = 'cognitoRefreshToken';

  Future<String?> get(String key) async {
    final row = await (_db.select(_db.appKvEntries)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await _db
        .into(_db.appKvEntries)
        .insertOnConflictUpdate(
          AppKvEntriesCompanion.insert(key: key, value: value),
        );
  }

  Future<bool> getBool(String key) async => (await get(key)) == 'true';

  Future<void> setBool(String key, bool value) =>
      set(key, value ? 'true' : 'false');
}
