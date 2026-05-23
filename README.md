# Attendance Tracker

Location-aware attendance app built with **Flutter**, **Riverpod**, **GoRouter**, and **Firebase**. Employees punch in and out only inside registered office geofences. **Super admins** manage locations (add, edit, delete) and monitor attendance—they do not punch for themselves.

**Progress:** see [mvp-tracker.md](mvp-tracker.md)

---

## Features

| Role | Capabilities |
|------|----------------|
| **Employee** | Sign in (email or Google), view geofence status, punch in/out inside office radius |
| **Super admin** | Manage office locations, view attendance log; admin dashboard has no punch UI |

### Data model (Firestore)

| Collection | Fields (main) |
|------------|----------------|
| `users/{uid}` | `email`, `displayName`, `role` (`employee` \| `super_admin`), `createdAt` |
| `locations/{id}` | `name`, `latitude`, `longitude`, `radiusMeters`, `isActive`, `createdBy`, `createdAt` |
| `attendance/{id}` | `userId`, `locationId`, `type` (`in` \| `out`), `timestamp`, `lat`, `lng` |

Security rules are in [firestore.rules](firestore.rules). Deploy with:

```bash
firebase deploy --only firestore:rules
```

---

## Screens

| Screen | Route | Who |
|--------|-------|-----|
| Login | `/` | All |
| Dashboard | `/dashboard` | Employee: punch + geofence; Admin: shortcuts to locations & log |
| Office locations | `/locations` | Super admin |
| Add / edit location | `/add-location` or `/add-location?id=…` | Super admin |
| Attendance log | `/attendance-monitor` | Super admin |

### Screenshots

Add captures under `docs/screenshots/` (e.g. `01-login.png`, `02-dashboard-employee.png`, `04-locations-list.png`).

---

## Tech stack

| Layer | Packages |
|-------|----------|
| UI | Flutter 3.x, `flutter_screenutil`, `flutter_native_splash` |
| State | `flutter_riverpod` |
| Routing | `go_router` |
| Backend | `firebase_core`, `firebase_auth`, `cloud_firestore` |
| Auth | `google_sign_in` |
| Location | `geolocator`, `permission_handler` |
| Theme | `lib/core/theme/app_theme.dart` |
| Logging | `lib/core/utils/logger.dart` (`talker`) |
| Preferences | `shared_preferences` (theme mode) |

---

## Project structure

```text
lib/
├── config/              # App constants, go_router
├── core/
│   ├── firebase/        # Firestore providers
│   ├── theme/           # app_theme.dart, theme_provider.dart
│   └── utils/           # logger, geofence, location permissions
├── data/
│   ├── models/
│   └── repositories/    # Auth, users, locations, attendance
├── modules/
│   ├── auth/
│   ├── dashboard/
│   ├── location/
│   └── admin/
├── app.dart
├── main.dart
└── firebase_options.dart   # from flutterfire configure
```

---

## Getting started

### Prerequisites

- Flutter SDK (`flutter doctor`)
- Node.js (Firebase CLI via `npx`)
- Android Studio or Xcode (device/emulator)
- Firebase project

### Install

```bash
git clone <repository-url>
cd attendance_tracker
flutter pub get
```

### Firebase setup

1. `npx -y firebase-tools@latest login`
2. Create a project in [Firebase Console](https://console.firebase.google.com)
3. Configure the Flutter app:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

4. Enable **Authentication** → Email/Password and **Google** (add Android SHA-1/SHA-256 for Google Sign-In).
5. Create **Cloud Firestore** (production or test mode, then deploy rules).
6. Deploy rules and indexes:

   ```bash
   firebase deploy --only firestore
   ```

7. Run the app:

   ```bash
   flutter run
   ```

Set `AppConfig.googleWebClientId` in `lib/config/constant/app_config.dart` to your Firebase **Web client ID** (required for Google Sign-In on Android).

### First super admin

1. Sign in once with your account.
2. In Firestore Console: `users/<your-uid>` → set `role` to `super_admin`.
3. Restart the app — **Manage Locations** and **Attendance Log** unlock.

### Native permissions

**Location while in use** only (employees). No background location.

| Platform | Where |
|----------|--------|
| Android | `android/app/src/main/AndroidManifest.xml` |
| iOS | `ios/Runner/Info.plist` (`NSLocationWhenInUseUsageDescription`) |
| iOS build | `ios/Podfile` — `PERMISSION_LOCATION_WHENINUSE=1` |

After iOS native changes:

```bash
cd ios && pod install && cd ..
```

### Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Demo flow

1. **Super admin** → **Manage Locations** → add office (name, lat, lng, radius m).
2. **Employee** → dashboard shows inside/outside zone → **Punch In** (only inside geofence).
3. **Punch Out** when punched in.
4. **Super admin** → **Attendance Log** → recent punches (limit 50).
5. **Super admin** → edit or delete a location from the locations list (⋮ menu).

---

## Development conventions

- **Theme:** `lib/core/theme/app_theme.dart` — use `Theme.of(context)` in screens.
- **Logs:** `Logger` from `lib/core/utils/logger.dart` — no `print` / `debugPrint`.
- **State:** Riverpod notifiers; Firestore only in repositories.
- **Scope:** `.cursor/rules/flutter-attendance.mdc` — MVP features only unless asked otherwise.

---

## License

Private / interview submission.
