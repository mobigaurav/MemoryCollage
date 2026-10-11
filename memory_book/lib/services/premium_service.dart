import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/config.dart';

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

class PackPurchase {
  const PackPurchase({required this.state, this.transactionId});

  final PremiumState state;
  final String? transactionId;
}

class PremiumService {
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
    if (activeKey.isEmpty) {
      return PremiumState(
        isPremium: false,
        source: 'none',
        plans: _storePlans(),
        configured: false,
      );
    }
    try {
      await _ensureConfigured();
      final info = await Purchases.getCustomerInfo();
      final offerings = await Purchases.getOfferings();
      return _fromCustomer(info, plans: _plansFrom(offerings));
    } catch (e) {
      return PremiumState(
        isPremium: false,
        source: 'none',
        error: e.toString(),
        plans: _storePlans(),
        configured: false,
      );
    }
  }

  PremiumState applyCustomer(CustomerInfo info, PremiumState current) {
    return _fromCustomer(info, plans: current.plans);
  }

  /// Ties StoreKit and Play purchases to the signed-in account.
  /// No-ops until a RevenueCat public SDK key is present.
  Future<void> identify(String appUserId) async {
    final id = appUserId.trim();
    if (activeKey.isEmpty || id.isEmpty) return;
    await _ensureConfigured();
    await Purchases.logIn(id);
  }

  Future<void> signOutStore() async {
    if (activeKey.isEmpty) return;
    if (!await Purchases.isConfigured) return;
    final info = await Purchases.getCustomerInfo();
    if (info.originalAppUserId.startsWith(r'$RCAnonymous')) return;
    await Purchases.logOut();
  }

  Future<PremiumState> purchase(String planId) async {
    if (activeKey.isEmpty) {
      return (await refresh()).copyWith(
        error: 'Premium purchases are not connected yet.',
      );
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

  PremiumState _fromCustomer(
    CustomerInfo info, {
    required List<PremiumPlan> plans,
  }) {
    final entitled =
        info.entitlements.all[AppConfig.premiumEntitlement]?.isActive ?? false;
    return PremiumState(
      isPremium: entitled,
      source: entitled ? 'revenuecat' : 'none',
      plans: plans.isEmpty ? _storePlans() : plans,
      configured: true,
    );
  }

  Future<PackPurchase> purchaseCreditPack() async {
    if (activeKey.isEmpty) {
      return PackPurchase(
        state: (await refresh()).copyWith(
          error: 'Credit packs are not connected yet.',
        ),
      );
    }
    try {
      await _ensureConfigured();
      final offerings = await Purchases.getOfferings();
      final pkg = _creditPackage(offerings);
      if (pkg == null) {
        throw StateError(
          'No five-clip pack. Add ${AppConfig.creditPackProductId} to the current offering.',
        );
      }
      final result = await Purchases.purchase(PurchaseParams.package(pkg));
      final id = result.storeTransaction.transactionIdentifier;
      return PackPurchase(
        state: await refresh(),
        transactionId: id.isEmpty ? null : id,
      );
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return PackPurchase(state: (await refresh()).copyWith(clearError: true));
      }
      return PackPurchase(
        state: (await refresh()).copyWith(error: e.message ?? e.code),
      );
    } catch (e) {
      return PackPurchase(state: (await refresh()).copyWith(error: e.toString()));
    }
  }

  Package? _creditPackage(Offerings offerings) {
    final groups = [
      offerings.current?.availablePackages ?? const <Package>[],
      for (final offering in offerings.all.values) offering.availablePackages,
    ];
    for (final packages in groups) {
      for (final pkg in packages) {
        if (pkg.storeProduct.identifier == AppConfig.creditPackProductId) {
          return pkg;
        }
      }
    }
    return null;
  }

  List<PremiumPlan> _plansFrom(Offerings offerings) {
    final packages = (offerings.current?.availablePackages ?? [])
        .where(
          (pkg) => pkg.storeProduct.identifier != AppConfig.creditPackProductId,
        )
        .toList();
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

  List<PremiumPlan> _storePlans() {
    return const [
      PremiumPlan(
        id: AppConfig.premiumAnnualId,
        title: 'Annual',
        priceLabel: 'App Store',
        detail: 'The family plan',
        annual: true,
      ),
      PremiumPlan(
        id: AppConfig.premiumMonthlyId,
        title: 'Monthly',
        priceLabel: 'App Store',
        detail: 'Cancel anytime',
        monthly: true,
      ),
    ];
  }
}
