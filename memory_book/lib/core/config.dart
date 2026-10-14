/// Runtime config. Leave keys empty for local-first development.
class AppConfig {
  static const appName = 'Memory Book';
  static const appStoreTitle = 'Memory Book';
  static const supportEmail = 'mobigaurav@gmail.com';
  /// Memory Book's own site. Not memory-book.vercel.app, which is a different project.
  static const siteUrl = 'https://memory-book-pearl-zeta.vercel.app';

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

  static const premiumEntitlement = 'premium';
  static const premiumProductId = 'com.memorycollage.premium';
  static const premiumAnnualId = 'com.memorycollage.premium.annual';
  static const premiumMonthlyId = 'com.memorycollage.premium.monthly';

  /// One-time pack. Five clips, spent one at a time. Not part of Premium.
  static const creditPackProductId = 'com.memorycollage.credits.five';
  static const creditPackSize = 5;

  /// Live dev API. Business logic reads this when a credit or a clip is requested.
  /// Override with `--dart-define=AI_BASE_URL=` only to stay fully on device.
  static const aiBaseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue:
        'https://z2k4sv0eoe.execute-api.us-east-1.amazonaws.com/dev',
  );

  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  /// Memory Book Cognito app client (public, USER_PASSWORD_AUTH). Own pool, not Arogya's.
  static const cognitoClientId = String.fromEnvironment(
    'COGNITO_CLIENT_ID',
    defaultValue: 'thi97f481tevec4k8t7eibsf6',
  );
  static const awsRegion = String.fromEnvironment(
    'AWS_REGION',
    defaultValue: 'us-east-1',
  );

  /// Hosted UI for Apple and Google. Cognito returns to [cognitoRedirectUri].
  static const cognitoDomain = String.fromEnvironment(
    'COGNITO_DOMAIN',
    defaultValue: 'memorybook-dev.auth.us-east-1.amazoncognito.com',
  );
  static const cognitoRedirectUri = 'memorybook://auth';

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

  /// Public PostHog project key. An empty override keeps every call quiet.
  static const posthogApiKey = String.fromEnvironment(
    'POSTHOG_API_KEY',
    defaultValue: 'phc_rdCbaskeHzwjYRxAqDApHwKXtqV4wPuSeny9sGb9YrtN',
  );
  static const posthogHost = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://us.i.posthog.com',
  );

  /// Empty until a Memory Book Firebase project is passed at build time.
  /// Push registration stays off, the same way Vedic skips FCM without config.
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '',
  );
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  static bool get firebaseConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;
}
