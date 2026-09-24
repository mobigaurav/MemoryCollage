/// Runtime config. Leave keys empty for local-first development.
class AppConfig {
  static const appName = 'Memory Book';
  static const appStoreTitle = 'Memory Book';
  static const supportEmail = 'mobigaurav@gmail.com';

  /// Public SDK keys. Prefer the platform key; [revenueCatApiKey] is the fallback.
  /// Empty = local entitlement store so the app still runs.
  static const revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: '',
  );
  static const revenueCatAppleKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: '',
  );
  static const revenueCatGoogleKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_KEY',
    defaultValue: '',
  );

  /// Stays on while we test. Store builds pass `--dart-define=DEV_UNLOCK=false`.
  static const devUnlockEnabled = bool.fromEnvironment(
    'DEV_UNLOCK',
    defaultValue: true,
  );

  static const premiumEntitlement = 'premium';
  static const premiumProductId = 'com.memorycollage.premium';
  static const premiumAnnualId = 'com.memorycollage.premium.annual';
  static const premiumMonthlyId = 'com.memorycollage.premium.monthly';

  /// v1.5 AI proxy. Empty = on-device cinematic reel fallback.
  static const aiBaseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: '',
  );

  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  /// Memory Book Cognito app client (public, USER_PASSWORD_AUTH). Own pool, not Arogya's.
  static const cognitoClientId = String.fromEnvironment(
    'COGNITO_CLIENT_ID',
    defaultValue: '',
  );
  static const awsRegion = String.fromEnvironment(
    'AWS_REGION',
    defaultValue: 'us-east-1',
  );

  static const freeAlbumLimit = 3;
  static const freeCollageTemplateIds = {
    'grid_2x2',
    'grid_3x2',
    'grid_3x3',
    'two_up',
    'three_up',
    'vertical_3',
    'horizontal_3',
    'hero_strip',
    'polaroid_row',
    'mosaic',
    'window_2x3',
    'postcard',
    'freeform',
  };

  static const maxCollagePhotos = 20;
  static const defaultSlideshowSeconds = 3.0;
}
