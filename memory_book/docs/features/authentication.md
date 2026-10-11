# Sign-in without a login wall

Memory Book is a photo book that lives on the phone. An account exists so a person can spend an AI credit and so a purchase can follow them to another device. Opening the shelf never asks for one.

That split is the whole design. Books, collages, and films are rows in a local database and files in the app’s documents directory. The account is a Cognito session, used when the phone calls the API.

## Two ways into the same pool

Email is the Cognito app client’s `USER_PASSWORD_AUTH` flow. The phone signs up, confirms the code Cognito emails, then stores the id token and the refresh token. The API accepts that id token as a bearer token and reads the `sub` claim. There is no second user table on the phone. The subject is the account.

Apple and Google do not create a second kind of account on the device. The phone opens Cognito’s hosted UI with `identity_provider` set to `SignInWithApple` or `Google`, using PKCE because the app client has no secret. Cognito talks to Apple or Google, then redirects to `memorybook://auth` with an authorization code. The phone exchanges that code at the pool’s token endpoint and stores the same kind of tokens email sign-in already stored. Cloud clips and the credit call then send `Authorization: Bearer`.

A cancelled browser sheet is not an error toast. A missing provider on the pool is. The buttons stay visible so the failure is obvious.

## Why Apple needs a Services ID

The iOS app that ships to the store keeps the existing bundle id, so the update replaces Memory Collage rather than listing a second app. Sign in with Apple through Cognito is a website login, and Apple will not reuse an App ID as the OAuth client. The Services ID is a separate identifier. Its primary app is the Memory Collage app id, so the Apple sheet shows that app’s name and icon. The Services ID’s return URL is Cognito’s `/oauth2/idpresponse` endpoint, not the phone. The phone only sees the custom scheme after Cognito has finished.

Google is a web OAuth client for the same reason. Cognito’s servers exchange the code, so the redirect URI registered at Google is again `/oauth2/idpresponse`. An iOS or Android client id is the wrong object here.

The private key Apple issues for that Services ID, and the Google client secret, are CloudFormation parameters. They are not in the app and not in source control. A later deploy that omits them keeps the previous values.

## What stays on the phone

Signing out clears the tokens and the session row. It does not delete albums. A guest can still make a book. The moment they spend a credit, the app asks them to sign in, because the API rejects a call with no bearer token.

Welcome credits are still granted on the device when the local balance is zero. The durable ledger is the next piece of this design. Until that database is attached, a Lambda cold start can forget server-side credit history. The phone’s session does not depend on that ledger. The tokens do.

## What this is not

This is not a sync account. Photos are not uploaded because someone signed in. The only image that leaves the phone for an account is the one they explicitly send for an AI clip, and the confirmation sheet says so before the request starts.

## Diagram

```
 Phone                         Cognito                         Apple or Google
  |                              |                                  |
  | Continue with Apple/Google   |                                  |
  |----------------------------->|                                  |
  |  GET /oauth2/authorize       |                                  |
  |  identity_provider=...       |                                  |
  |  PKCE S256, no client secret |                                  |
  |                              | redirect                         |
  |                              |--------------------------------->|
  |                              |         id token / code          |
  |                              |<---------------------------------|
  |  memorybook://auth?code=     |                                  |
  |<-----------------------------|                                  |
  |  POST /oauth2/token          |                                  |
  |----------------------------->|                                  |
  |  id, access, refresh         |                                  |
  |<-----------------------------|                                  |
  |                              |                                  |
  |  later: API Bearer id token  |                                  |
  +------------------------------+----------------------------------+

 Email skips the browser. USER_PASSWORD_AUTH returns the same three tokens.
```

## Libraries

| Library | Role |
| --- | --- |
| [flutter_web_auth_2](https://pub.dev/packages/flutter_web_auth_2) | System browser session and the `memorybook://` return |
| [crypto](https://pub.dev/packages/crypto) | PKCE S256 challenge |
| [http](https://pub.dev/packages/http) | Cognito JSON API and the token endpoint |
| [drift](https://pub.dev/packages/drift) | `AuthSessions` row on the phone |
| AWS Cognito | User pool, hosted UI, Apple and Google identity providers |

`sign_in_with_apple` and `google_sign_in` are still in the app manifest. The buttons do not call them. Cognito is the client.

## Source

`memory_book/lib/services/cognito_auth.dart` builds the hosted UI URL. `identity_provider` is `Google` or `SignInWithApple`.

```dart
return Uri.https(host, '/oauth2/authorize', {
  'response_type': 'code',
  'client_id': clientId,
  'redirect_uri': redirectUri,
  'scope': 'openid email profile',
  'identity_provider': identityProvider,
  'code_challenge_method': 'S256',
  'code_challenge': codeChallenge,
});
```

`memory_book/lib/services/auth_ai.dart` opens that URL and treats a closed sheet as a cancel.

```dart
callback = await FlutterWebAuth2.authenticate(
  url: uri.toString(),
  callbackUrlScheme: 'memorybook',
);
```

`services/api/mb_api/middleware.py` rejects any API call that is not a Cognito bearer token. The billing webhook is the one public path besides health.
