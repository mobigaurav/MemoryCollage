import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/app_database.dart';
import 'data/repositories/album_repository.dart';
import 'data/repositories/draft_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'services/auth_ai.dart';
import 'services/book_export.dart';
import 'services/credit_ledger.dart';
import 'services/export_history.dart';
import 'services/export_service.dart';
import 'services/local_notify.dart';
import 'services/photo_service.dart';
import 'services/print_service.dart';
import 'services/premium_service.dart';
import 'services/slideshow_exporter.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

final albumRepositoryProvider = Provider<AlbumRepository>(
  (ref) => AlbumRepository(ref.watch(appDatabaseProvider)),
);

final draftRepositoryProvider = Provider<DraftRepository>(
  (ref) => DraftRepository(ref.watch(settingsRepositoryProvider)),
);

final photoServiceProvider = Provider<PhotoService>((ref) => PhotoService());

final localNotifyProvider = Provider<LocalNotify>((ref) => LocalNotify());

final nativeEncoderProvider =
    Provider<NativeVideoEncoder>((ref) => NativeVideoEncoder());

final printServiceProvider = Provider<PrintService>((ref) => PrintService());

final exportServiceProvider = Provider<ExportService>(
  (ref) => ExportService(ref.watch(nativeEncoderProvider)),
);

final exportHistoryProvider = Provider<ExportHistory>(
  (ref) => ExportHistory(ref.watch(settingsRepositoryProvider)),
);

final flipReelExporterProvider = Provider<FlipReelExporter>(
  (ref) => FlipReelExporter(ref.watch(nativeEncoderProvider)),
);

final slideshowExporterProvider = Provider<SlideshowExporter>(
  (ref) => SlideshowExporter(ref.watch(nativeEncoderProvider)),
);

final creditLedgerProvider = Provider<CreditLedger>(
  (ref) => CreditLedger(ref.watch(appDatabaseProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(appDatabaseProvider)),
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.watch(authRepositoryProvider),
    ref.watch(creditLedgerProvider),
    ref.watch(settingsRepositoryProvider),
  ),
);

final aiVideoClientProvider = Provider<AiVideoClient>(
  (ref) => AiVideoClient(
    ref.watch(creditLedgerProvider),
    ref.watch(authRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
  ),
);

final premiumServiceProvider = Provider<PremiumService>(
  (ref) => PremiumService(ref.watch(settingsRepositoryProvider)),
);

class PremiumController extends Notifier<PremiumState> {
  @override
  PremiumState build() {
    final service = ref.read(premiumServiceProvider);
    service.listen((info) async {
      final local = await service.localUnlocked();
      state = service.applyCustomer(info, state, local);
    });
    Future.microtask(refresh);
    return PremiumState.free;
  }

  Future<void> refresh() async {
    state = await ref.read(premiumServiceProvider).refresh();
  }

  Future<void> purchase([String? planId]) async {
    final id = planId ??
        state.plans.where((p) => p.annual).firstOrNull?.id ??
        (state.plans.isEmpty ? 'dev_annual' : state.plans.first.id);
    state = await ref.read(premiumServiceProvider).purchase(id);
  }

  Future<void> restore() async {
    state = await ref.read(premiumServiceProvider).restore();
  }

  Future<void> unlockLocally() async {
    state = await ref.read(premiumServiceProvider).unlockLocally();
  }

  Future<void> clearLocalUnlock() async {
    state = await ref.read(premiumServiceProvider).clearLocalUnlock();
  }
}

final premiumControllerProvider =
    NotifierProvider<PremiumController, PremiumState>(PremiumController.new);

final albumsProvider = StreamProvider((ref) {
  return ref.watch(albumRepositoryProvider).watchAll();
});

final albumDetailProvider =
    StreamProvider.family<AlbumDetail?, String>((ref, id) {
  return ref.watch(albumRepositoryProvider).watchDetail(id);
});

final creditBalanceProvider = StreamProvider<int>((ref) {
  return ref.watch(creditLedgerProvider).watchBalance();
});

final authSessionProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).watch();
});
