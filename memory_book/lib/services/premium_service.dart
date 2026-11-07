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

  /// Debug and profile only. A release build tree-shakes this and stays locked.
  static PremiumState grantTester(PremiumState state, String? email) {
    if (kReleaseMode) return state;
    const tester = 'mobigaurav@gmail.com';
    if (email?.trim().toLowerCase() != tester) return state;
    return state.copyWith(isPremium: true, source: 'tester', clearError: true);
  }

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
    if (AppConfig.revenueCatApiKey.isNotEmpty) {
      return AppConfig.revenueCatApiKey;
    }
    // Test Store only. A release build never reads the key below.
    if (kReleaseMode) return '';
    const testStore = 'test_OJvjKaIDxnpJPYCjJHkAYhraEZQ';
    return testStore;
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
      final plans = packages.where((pkg) => !_isLifetime(pkg)).toList();
      Package? pkg;
      for (final candidate in plans) {
        if (candidate.identifier == planId) pkg = candidate;
      }
      pkg ??= offerings.current?.annual ?? offerings.current?.monthly;
      if (pkg == null || _isLifetime(pkg)) {
        throw StateError(
          'No monthly or yearly plan. Add those two to the current offering.',
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
      final product = pkg.storeProduct;
      PurchaseResult result;
      try {
        result = await Purchases.purchase(PurchaseParams.package(pkg));
      } on PlatformException catch (e) {
        if (PurchasesErrorHelper.getErrorCode(e) ==
            PurchasesErrorCode.purchaseCancelledError) {
          rethrow;
        }
        result = await Purchases.purchase(PurchaseParams.storeProduct(product));
      }
      final id = _creditTransactionId(result, product.identifier);
      if (id == null) {
        return PackPurchase(
          state: (await refresh()).copyWith(
            error: 'The five-clip purchase finished without a receipt.',
          ),
        );
      }
      return PackPurchase(state: await refresh(), transactionId: id);
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

  String? _creditTransactionId(PurchaseResult result, String productId) {
    final direct = result.storeTransaction;
    if (direct.transactionIdentifier.isNotEmpty &&
        direct.productIdentifier == productId) {
      return direct.transactionIdentifier;
    }
    for (final tx in result.customerInfo.nonSubscriptionTransactions.reversed) {
      if (tx.productIdentifier == productId && tx.transactionIdentifier.isNotEmpty) {
        return tx.transactionIdentifier;
      }
    }
    if (direct.transactionIdentifier.isNotEmpty) return direct.transactionIdentifier;
    return null;
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
          (pkg) =>
              pkg.storeProduct.identifier != AppConfig.creditPackProductId &&
              !_isLifetime(pkg),
        )
        .toList();
    final plans = packages.map(_planFromPackage).toList();
    plans.sort((a, b) {
      int rank(PremiumPlan p) => p.annual ? 0 : (p.monthly ? 1 : 2);
      return rank(a).compareTo(rank(b));
    });
    return plans;
  }

  bool _isLifetime(Package pkg) {
    final product = pkg.storeProduct.identifier.toLowerCase();
    return pkg.packageType == PackageType.lifetime || product == 'lifetime';
  }

  PremiumPlan _planFromPackage(Package pkg) {
    final product = pkg.storeProduct.identifier.toLowerCase();
    final annual = pkg.packageType == PackageType.annual ||
        product == 'yearly' ||
        product == 'annual';
    final monthly = pkg.packageType == PackageType.monthly || product == 'monthly';
    return PremiumPlan(
      id: pkg.identifier,
      title: annual ? 'Annual' : monthly ? 'Monthly' : pkg.storeProduct.title,
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
