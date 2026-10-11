import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config.dart';
import 'data/db/app_database.dart';
import 'data/repositories/album_repository.dart';
import 'data/repositories/draft_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'services/auth_ai.dart';
import 'services/book_export.dart';
import 'services/community_api.dart';
import 'services/credit_ledger.dart';
import 'services/household_api.dart';
import 'services/export_history.dart';
import 'services/export_service.dart';
import 'services/local_notify.dart';
import 'services/photo_service.dart';
import 'services/print_service.dart';
import 'services/premium_service.dart';
import 'services/push_notifications.dart';
import 'services/reel_library.dart';
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

final pushNotificationsProvider = Provider<PushNotifications>(
  (ref) => PushNotifications(
    ref.watch(settingsRepositoryProvider),
    ref.watch(localNotifyProvider),
  ),
);

final nativeEncoderProvider =
    Provider<NativeVideoEncoder>((ref) => NativeVideoEncoder());

final printServiceProvider = Provider<PrintService>((ref) => PrintService());

final exportServiceProvider = Provider<ExportService>(
  (ref) => ExportService(ref.watch(nativeEncoderProvider)),
);

final exportHistoryProvider = Provider<ExportHistory>(
  (ref) => ExportHistory(ref.watch(settingsRepositoryProvider)),
);

final reelLibraryProvider = Provider<ReelLibrary>((ref) => ReelLibrary());

final reelsProvider = FutureProvider<List<ReelRecord>>((ref) {
  return ref.watch(reelLibraryProvider).load();
});

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
  (ref) => PremiumService(),
);

class PremiumController extends Notifier<PremiumState> {
  @override
  PremiumState build() {
    final service = ref.read(premiumServiceProvider);
    service.listen((info) async {
      state = service.applyCustomer(info, state);
    });
    ref.listen(authSessionProvider, (previous, next) {
      if (next.isLoading) return;
      final session = next.asData?.value;
      final before = previous?.asData?.value;
      if (before?.provider == session?.provider &&
          before?.subject == session?.subject) {
        return;
      }
      Future<void>(() async {
        await _bindStore(session);
        if (!ref.mounted) return;
        state = await ref.read(premiumServiceProvider).refresh();
      });
    });
    Future.microtask(() async {
      final session = await ref.read(authRepositoryProvider).current();
      await _bindStore(session);
      await refresh();
    });
    return PremiumState.free;
  }

  Future<void> _bindStore(AuthSession? session) async {
    final service = ref.read(premiumServiceProvider);
    try {
      if (session == null || session.subject.isEmpty) {
        await service.signOutStore();
        return;
      }
      await service.identify('${session.provider}:${session.subject}');
    } catch (_) {}
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

  Future<void> buyCreditPack() async {
    final result = await ref.read(premiumServiceProvider).purchaseCreditPack();
    final id = result.transactionId;
    if (id != null) {
      final ledger = ref.read(creditLedgerProvider);
      final reason = 'pack_5:$id';
      if (!await ledger.hasReason(reason)) {
        await ledger.grant(AppConfig.creditPackSize, reason);
      }
    }
    state = result.state;
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

final communityApiProvider = Provider<CommunityApi>(
  (ref) => CommunityApi(ref.watch(settingsRepositoryProvider)),
);

final householdApiProvider = Provider<HouseholdApi>(
  (ref) => HouseholdApi(ref.watch(settingsRepositoryProvider)),
);
