import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/config.dart';
import '../data/repositories/settings_repository.dart';

class PremiumPlan {
  const PremiumPlan({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.detail,
    this.annual = false,
    this.monthly = false,
  });

  final String id;
  final String title;
  final String priceLabel;
  final String detail;
  final bool annual;
  final bool monthly;
}

class PremiumState {
  const PremiumState({
    required this.isPremium,
    required this.source,
    this.error,
    this.plans = const [],
    this.configured = false,
  });

  final bool isPremium;
  final String source;
  final String? error;
  final List<PremiumPlan> plans;
  final bool configured;

  static const free = PremiumState(isPremium: false, source: 'none');

  PremiumState copyWith({
    bool? isPremium,
    String? source,
    String? error,
    List<PremiumPlan>? plans,
    bool? configured,
    bool clearError = false,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      source: source ?? this.source,
      error: clearError ? null : (error ?? this.error),
      plans: plans ?? this.plans,
      configured: configured ?? this.configured,
    );
  }
}

class PremiumService {
  PremiumService(this._settings);
  final SettingsRepository _settings;
  var _listenerAttached = false;

  static String get activeKey {
    if ((Platform.isIOS || Platform.isMacOS) &&
        AppConfig.revenueCatAppleKey.isNotEmpty) {
      return AppConfig.revenueCatAppleKey;
    }
    if (Platform.isAndroid && AppConfig.revenueCatGoogleKey.isNotEmpty) {
      return AppConfig.revenueCatGoogleKey;
    }
    return AppConfig.revenueCatApiKey;
  }

  Future<void> _ensureConfigured() async {
    final key = activeKey;
    if (key.isEmpty) return;
    if (!await Purchases.isConfigured) {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      await Purchases.configure(PurchasesConfiguration(key));
    }
  }

  void listen(void Function(CustomerInfo info) onUpdate) {
    if (_listenerAttached || activeKey.isEmpty) return;
    _listenerAttached = true;
    Purchases.addCustomerInfoUpdateListener(onUpdate);
  }

  Future<PremiumState> refresh() async {
    final local = await _settings.getBool(SettingsRepository.localPremiumKey);
    if (activeKey.isEmpty) {
      return PremiumState(
        isPremium: AppConfig.devUnlockEnabled && local,
        source: 'local',
        plans: _devPlans(),
        configured: false,
      );
    }
    try {
      await _ensureConfigured();
      final info = await Purchases.getCustomerInfo();
      final offerings = await Purchases.getOfferings();
      return _fromCustomer(
        info,
        plans: _plansFrom(offerings),
        local: local,
      );
    } catch (e) {
      return PremiumState(
        isPremium: AppConfig.devUnlockEnabled && local,
        source: 'local',
        error: e.toString(),
        plans: _devPlans(),
        configured: false,
      );
    }
  }

  PremiumState applyCustomer(CustomerInfo info, PremiumState current, bool local) {
    return _fromCustomer(info, plans: current.plans, local: local);
  }

  Future<bool> localUnlocked() {
    return _settings.getBool(SettingsRepository.localPremiumKey);
  }

  Future<PremiumState> purchase(String planId) async {
    if (activeKey.isEmpty) {
      await _settings.setBool(SettingsRepository.localPremiumKey, true);
      return refresh();
    }
    try {
      await _ensureConfigured();
      final offerings = await Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? [];
      Package? pkg;
      for (final candidate in packages) {
        if (candidate.identifier == planId) pkg = candidate;
      }
      pkg ??= offerings.current?.annual ??
          (packages.isEmpty ? null : packages.first);
      if (pkg == null) {
        throw StateError(
          'No RevenueCat packages. Add annual and monthly to the current offering.',
        );
      }
      await Purchases.purchase(PurchaseParams.package(pkg));
      return await refresh();
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        final current = await refresh();
        return current.copyWith(clearError: true);
      }
      return (await refresh()).copyWith(error: e.message ?? e.code);
    } catch (e) {
      return (await refresh()).copyWith(error: e.toString());
    }
  }

  Future<PremiumState> restore() async {
    if (activeKey.isEmpty) return refresh();
    try {
      await _ensureConfigured();
      await Purchases.restorePurchases();
      return await refresh();
    } on PlatformException catch (e) {
      return (await refresh()).copyWith(error: e.message ?? e.code);
    } catch (e) {
      return (await refresh()).copyWith(error: e.toString());
    }
  }

  Future<PremiumState> unlockLocally() async {
    await _settings.setBool(SettingsRepository.localPremiumKey, true);
    return refresh();
  }

  Future<PremiumState> clearLocalUnlock() async {
    await _settings.setBool(SettingsRepository.localPremiumKey, false);
    return refresh();
  }

  PremiumState _fromCustomer(
    CustomerInfo info, {
    required List<PremiumPlan> plans,
    required bool local,
  }) {
    final entitled =
        info.entitlements.all[AppConfig.premiumEntitlement]?.isActive ?? false;
    final dev = AppConfig.devUnlockEnabled && local;
    return PremiumState(
      isPremium: entitled || dev,
      source: entitled ? 'revenuecat' : (dev ? 'dev' : 'revenuecat'),
      plans: plans.isEmpty ? _devPlans() : plans,
      configured: true,
    );
  }

  List<PremiumPlan> _plansFrom(Offerings offerings) {
    final packages = offerings.current?.availablePackages ?? [];
    final plans = packages.map(_planFromPackage).toList();
    plans.sort((a, b) {
      int rank(PremiumPlan p) => p.annual ? 0 : (p.monthly ? 1 : 2);
      return rank(a).compareTo(rank(b));
    });
    return plans;
  }

  PremiumPlan _planFromPackage(Package pkg) {
    final annual = pkg.packageType == PackageType.annual;
    final monthly = pkg.packageType == PackageType.monthly;
    final title = annual
        ? 'Annual'
        : monthly
            ? 'Monthly'
            : pkg.storeProduct.title;
    return PremiumPlan(
      id: pkg.identifier,
      title: title,
      priceLabel: pkg.storeProduct.priceString,
      detail: annual ? 'Best for a family shelf' : 'Cancel anytime',
      annual: annual,
      monthly: monthly,
    );
  }

  List<PremiumPlan> _devPlans() {
    return const [
      PremiumPlan(
        id: 'dev_annual',
        title: 'Annual',
        priceLabel: 'Store price',
        detail: 'Shows here once RevenueCat has a current offering',
        annual: true,
      ),
      PremiumPlan(
        id: 'dev_monthly',
        title: 'Monthly',
        priceLabel: 'Store price',
        detail: 'Secondary plan',
        monthly: true,
      ),
    ];
  }
}
