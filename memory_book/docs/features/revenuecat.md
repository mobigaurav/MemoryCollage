# Purchases that follow the account

Memory Book Premium removes the watermark, opens every collage template, and lifts the three-book shelf limit. The store sells that as an annual plan and a monthly plan. RevenueCat is the layer between StoreKit, Play Billing, and the app, so the phone never talks to two receipt formats.

## What the phone checks

The public SDK key is a compile-time value, one for Apple and one for Google. It is not a secret, and it is not Arogya’s key. Each product has its own RevenueCat project. An empty key means the release binary cannot pretend a purchase happened.

On launch, and again after sign-in, the app calls `Purchases.logIn` with an id of the form `provider:subject`. Email, Apple, and Google therefore become the same RevenueCat customer that Cognito already named. Sign-out calls `Purchases.logOut` unless the current customer is still anonymous. A purchase made before sign-in is aliased onto the account by that login, which is RevenueCat’s normal behavior.

The entitlement id is `premium`. The paywall reads the current offering and shows the price string the store returned. Annual is the plan the shelf is designed around. Restore asks RevenueCat for the same entitlement. A restore that returns no active entitlement does not flip the local flag.

Product ids stay on the original iOS app, `com.memorycollage.premium.annual` and `com.memorycollage.premium.monthly`, because the App Store listing is an update, not a new record.

## Release versus the desk

Debug and profile builds can still unlock locally, so the book can be tested without a store sandbox. A release build, which is what TestFlight and Play internal testing install, ignores that switch. If the SDK key is missing, the paywall says purchases are not connected. It does not grant Premium.

That matches the rule we already use on a production app: the client may display a price, but it may not invent an entitlement. The store, then RevenueCat, is the source of the boolean.

## The webhook is a stub on purpose

RevenueCat can POST to `/v1/billing/revenuecat` when a subscription starts or expires. The route is public, because the store has to reach it, and it does not grant credits. A signature check belongs in front of any write. The credit ledger is still in memory on the Lambda, so a grant there would vanish on the next cold start and could be replayed.

When the ledger moves to a database, the webhook should do three things and then stop. Verify the shared secret. Ignore anonymous RevenueCat ids, because those are not a Cognito subject yet. Set entitlement on the user whose id matches `app_user_id`. Cancellation waits for expiration. The period already paid for stays paid.

Consumable AI credit packs are a later product. Premium and credits are different objects. One unlocks the paper. The other pays for a clip that leaves the device.

## Diagram

```
  You tab                PremiumService              RevenueCat           Store
    |                         |                          |                  |
    | sign-in session         |                          |                  |
    |------------------------>| logIn(provider:subject)  |                  |
    |                         |------------------------->|                  |
    | tap Annual              |                          |                  |
    |------------------------>| purchase(package)        |                  |
    |                         |------------------------->| StoreKit / Play  |
    |                         |                          |----------------->|
    |                         |                          |   receipt        |
    |                         |                          |<-----------------|
    |                         | CustomerInfo             |                  |
    |                         |<-------------------------|                  |
    | entitlement "premium"   |                          |                  |
    |<------------------------|                          |                  |

  Release build, no SDK key: purchase returns "not connected".
  It does not write the local premium flag.

  Webhook, later:

  RevenueCat --POST /v1/billing/revenuecat--> Lambda
                                              today: { ok, applied: false }
```

## Libraries

| Library | Role |
| --- | --- |
| [purchases_flutter](https://pub.dev/packages/purchases_flutter) | RevenueCat SDK. Offerings, purchase, restore, logIn |
| StoreKit / Play Billing | The receipt. The app does not parse it |
| FastAPI | `POST /v1/billing/revenuecat`, public, does not grant yet |

## Source

`memory_book/lib/providers.dart` binds the signed-in Cognito subject to the store customer.

```dart
await service.identify('${session.provider}:${session.subject}');
```

`memory_book/lib/services/premium_service.dart` refuses a fake unlock on a release build.

```dart
if (activeKey.isEmpty) {
  if (!AppConfig.devUnlockEnabled) {
    return (await refresh()).copyWith(
      error: 'Premium purchases are not connected yet.',
    );
  }
}
```

`services/api/mb_api/routers/billing.py` answers the webhook and writes nothing.

```python
@router.post("/v1/billing/revenuecat")
async def revenuecat_webhook(request: Request) -> dict:
    await request.body()
    return {"ok": True, "applied": False}
```
