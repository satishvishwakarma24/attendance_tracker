# 📍 Attendance Tracker (Management System)

An advanced, location-aware Attendance Management System built with **Flutter**, **Riverpod**, and **Firebase**. The application is designed to allow employees/users to punch in and out at specific, geofenced office locations, and provides a comprehensive administrative interface for a super admin to manage locations and monitor attendance.

---

## 🚀 Overview

The **Attendance Tracker** features a modern, reactive interface with complete Light/Dark mode support, Riverpod state management, localization capability, and robust permission handling for location services. It enforces that users are physically present within authorized geofenced zones before permitting them to clock in or out.

### 🌟 Key Features

*   **Geofenced Punch In/Out**: Users can only clock in or out when their device is physically within the defined radius of a registered office location.
*   **Super Admin Role**: Exclusive access to administrative dashboards to:
    *   Add and manage multiple office locations (specify name, latitude, longitude, and geofence radius).
    *   Monitor real-time clock-in/out logs of all users.
*   **Offline Support & Biometrics**: Local caching of logs, secure storage of credentials, and biometrics validation (FaceID/Fingerprint) for punching in/out securely.
*   **Modern Premium UI/UX**:
    *   Dynamic dark/light mode toggle with persistent preferences.
    *   Highly responsive layouts using `flutter_screenutil` and premium custom fonts (`google_fonts`).
*   **Sturdy Architecture**: Built with a modular structure dividing configurations, core utils, and functional features (modules) for maximum maintainability.
*   **Robust Logging**: Integrated with `talker` for detailed diagnostics, API logging, and state change tracking.

---

## 🛠️ Project Structure

The project follows a clean architecture pattern under the `lib/` directory:

```text
lib/
├── config/              # Application configurations
│   ├── constant/        # App constants (name, version)
│   ├── routes/          # Navigation and routing setup (go_router)
│   └── services/        # Service initializers (Firebase, Hive, etc.)
├── core/                # Core components shared across the app
│   ├── theme/           # App themes (Light, Dark, Theme Provider)
│   ├── utils/           # Utilities (Logger, PermissionHandler)
│   └── widgets/         # Shared presentation widgets
├── modules/             # Feature-specific modules
│   ├── admin/           # Super admin dashboard & location management
│   ├── attendance/      # Clock-in/out user operations
│   ├── auth/            # Sign in, sign up, and user session management
│   └── common/          # Shared views, placeholders, and error screens
├── app.dart             # Main App widget config
└── main.dart            # App entrypoint & initializers
```

---

## 📦 Tech Stack & Dependencies

*   **UI Framework**: [Flutter](https://flutter.dev) (Dart SDK `>=3.3.0 <4.0.0`)
*   **State Management**: `flutter_riverpod` & `riverpod_generator` (declarative state logic with caching and dependency injection)
*   **Routing**: `go_router` (declarative navigation)
*   **Local Caching & Storage**:
    *   `hive` & `hive_flutter` (high-performance lightweight NoSQL database for offline logs)
    *   `flutter_secure_storage` (secure keychain/keystore storage for sensitive tokens)
    *   `encrypt` (symmetric encryption for locally stored content)
*   **Database & Cloud Services (Firebase)**:
    *   `firebase_core` (Core initialization)
    *   `firebase_auth` (Secure user authentication)
    *   `cloud_firestore` (NoSQL database for attendance records & office locations)
    *   `firebase_storage` (Cloud storage for profile and uploaded media)
    *   `firebase_analytics` & `firebase_crashlytics` (App stability diagnostics)
    *   `firebase_messaging` (Push notifications for attendance alerts)
*   **Location & Device Utilities**:
    *   `geolocator` (Precise location queries & distance calculations)
    *   `geocoding` (Resolve addresses to/from coordinates)
    *   `google_maps_flutter` (Interactive map widget to choose or display geofenced zones)
    *   `permission_handler` (Graceful location, notification, and camera permission requests)
    *   `local_auth` (Biometrics FaceID / Fingerprint authorization)
*   **Design & Theme**:
    *   `flutter_screenutil` (Density-independent design sizing)
    *   `google_fonts` (Premium typeface loading)
    *   `animations` (Beautiful micro-interactions & transitions)
    *   `cached_network_image` (Network images with automatic offline caching)
    *   `flutter_native_splash` (Premium launch splash screen)
*   **Network & Dev Tools**:
    *   `dio` (Modern HTTP client for external API communication)
    *   `talker` (Sophisticated logging, error capture, and run-time audit logs)
    *   `freezed` & `json_serializable` (Type-safe code generators for models)

---

## ⚡ Performance Optimization & Best Practices

To maintain a buttery-smooth 60/120 FPS experience, we strictly enforce the following optimization practices:

1.  **Widget Optimization**:
    *   **Always use `const` widgets** where possible to reduce compile-time overhead and prevent redundant widget rebuilds.
    *   Design small, granular widgets to keep rebuild trees focused.
2.  **State Management (Riverpod)**:
    *   Use **`ref.select()`** strategically when listening to state updates to prevent widgets from rebuilds when unrelated fields of the state change.
3.  **Data Fetching & Storage**:
    *   **Firestore Pagination**: Implement paginated queries (cursor-based pagination) instead of loading full collections to optimize Firestore read limits.
    *   **Lazy Loading**: Defer resource allocations, API queries, and heavy UI components until they are actively displayed.
4.  **User Interactions**:
    *   **Debounced Input Handling**: Apply debounce timers to search boxes and filters to prevent duplicate API hits or database queries.
5.  **Media Uploads**:
    *   **Image Compression**: Compress all profile/logs images client-side before sending them to `firebase_storage` to save bandwidth and decrease load times.

---

## 📥 Getting Started

### Prerequisites

Ensure you have the Flutter SDK installed on your system. Run `flutter doctor` to verify your environment.

### Installation

1.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd attendance_tracker
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run Code Generation**:
    Build runner is used for generating Riverpod providers, Freezed models, and JSON serialization.
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Firebase Setup**:
    Since this project relies on Firebase, configure it for your targeted platforms:
    *   Run `flutterfire configure` to generate `firebase_options.dart`.
    *   Uncomment the Firebase initialization in `lib/main.dart`:
        ```dart
        // Firebase init
        // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
        ```

5.  **Run the Application**:
    ```bash
    flutter run
    ```

---

## 📝 Roadmap

- [ ] Complete integration of `firebase_auth` and design modular Login/Registration flows.
- [ ] Implement Geolocator-based real-time distance assessment for Punch In/Out.
- [ ] Create the **Super Admin Module** for adding and configuring multiple custom office locations with geofence boundaries.
- [ ] Design administrative list/reports views for attendance logs.
- [ ] Fully set up localized string tables (`intl` / `l10n`).