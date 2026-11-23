# VT-Index Flutter ↔ Django API setup

## Local development base URLs

The app now selects a local URL by target platform:

| Target | Django base URL |
|---|---|
| Android emulator | http://10.0.2.2:8000 |
| iOS simulator | http://127.0.0.1:8000 |
| Windows desktop | http://127.0.0.1:8000 |
| Web | http://127.0.0.1:8000 |
| Physical Android device | Set your development computer's LAN IP |

Run with a custom URL:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

Later, switch to production without editing Dart files:

```bash
flutter build apk --dart-define=API_BASE_URL=https://your-crm-domain.com
```

Use HTTPS in production. Do not ship production credentials or tokens in source code.

## Added integration foundation

- `lib/core/config/api_config.dart`: platform-aware and build-time configurable API URL.
- `lib/core/network/api_client.dart`: JSON GET/POST client, bearer-token support, and secure access-token storage.
- `http` and `flutter_secure_storage` dependencies.

## Existing Django endpoints verified in the CRM URL configuration

The backend currently mounts its client API under `/api/`. Examples:

- Login encryption challenge: `GET /api/login/encryption-challenge/`
- Login: `POST /api/login/`
- OTP verification: `POST /api/verify-otp/`
- Profile: `GET /api/profile/`
- Trading accounts: `GET /api/user-trading-accounts/`
- Open positions: `GET /api/open-positions/{account_id}/`
- Withdraw request: `POST /api/withdraw-request/`
- Internal transfer: `POST /api/internal-transfer/`

## Important authentication integration note

The existing Django login route supports a one-use RSA-OAEP + AES-GCM encrypted login payload, device metadata, rate limiting, OTP policy, and JWT/cookie session behavior. The Flutter app must implement the same server-side challenge/encryption contract and OTP response handling before it can safely authenticate. Do not send a plaintext password to the existing login endpoint, and do not treat local biometric success as server authentication.

This foundation intentionally does not bypass those protections or route users into the dashboard before Django confirms login. Next implementation step is the encrypted mobile login + OTP adapter, then profile/accounts data repositories. Existing browser authentication must remain unchanged.
