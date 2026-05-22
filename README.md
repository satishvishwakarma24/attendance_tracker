# 📍 Attendance Tracker (WorkSync Management System)

An advanced, location-aware Attendance Management System built with **Flutter**, **pure Riverpod**, **GoRouter**, and **Firebase**. The application is designed to allow employees/users to punch in and out at specific, geofenced office locations, and provides a comprehensive administrative interface for a super admin to manage locations and monitor attendance.

---

## 🚀 Overview

The **Attendance Tracker** features a modern, reactive interface with complete Light/Dark mode support, exclusively powered by Riverpod state management, precise declarative routing, and robust permission handling for location services. It enforces that users are physically present within authorized geofenced zones before permitting them to clock in or out.

### 🌟 Key Features

*   **Geofenced Punch In/Out**: Users can only clock in or out when their device is physically within the defined radius of a registered office location.
*   **Super Admin Role**: Exclusive access to administrative dashboards to:
    *   Add and manage multiple office locations (specify name, latitude, longitude, and geofence radius) and synchronize updates in real-time.
    *   Monitor real-time clock-in/out logs of all users.
*   **Pure Riverpod State Engine**: Uniquely handles application state (such as themes, office location lists, and punch states) using centralized Riverpod `NotifierProvider`s, providing highly decoupled, predictable, and testable code.
*   **Declarative Navigation**: Zero imperative routing faults. Driven entirely by `go_router` under standard paths.
*   **Network Layer**: Unified HTTP API client built with `dio`, providing customized timeouts, comprehensive interceptors, centralized logging, and elegant mapping of network exceptions (`ApiException`).
*   **Modern Premium UI/UX**:
    *   Dynamic dark/light mode toggle with persistent preferences.
    *   Highly responsive layouts using `flutter_screenutil` and premium custom fonts (`google_fonts`).
*   **Robust Logging**: Centralized diagnostics tracing powered by `talker` and wrapped in a global `Logger` utility, ensuring consistent console auditing.

---

## 🛠️ Project Structure

The project follows a clean architecture pattern under the `lib/` directory:

```text
lib/
├── config/              # Application configurations
│   ├── constant/        # App constants (name, version)
│   └── routes/          # Navigation and routing setup (go_router)
├── core/                # Core components shared across the app
│   ├── network/         # Cohesive network engine (api_client, api_exception, network_provider)
│   ├── theme/           # App themes (Light, Dark, Theme Provider)
│   ├── utils/           # Utilities (Logger, PermissionHandler, LocaleProvider)
│   └── widgets/         # Shared presentation widgets
├── modules/             # Feature-specific modules
│   ├── auth/            # Sign in, sign up, and user session management
│   ├── dashboard/       # User punch panel dashboard and attendance state (Riverpod-powered)
│   ├── location/        # Locations list and geofence config screens (Riverpod-powered)
│   └── view.dart        # Screen views exports central registry
├── app.dart             # Main App widget config
└── main.dart            # App entrypoint & initializers
```

---

## 📦 Tech Stack & Dependencies

*   **UI Framework**: [Flutter](https://flutter.dev) (Dart SDK `>=3.3.0 <4.0.0`)
*   **State Management**: `flutter_riverpod` & `riverpod_generator` (declarative state logic with caching and dependency injection; **no legacy providers**)
*   **Routing**: `go_router` (declarative navigation)
*   **Network Client**: `dio` (unified HTTP client with standard query parameters, headers, and error parsing)
*   **Local Caching & Storage**:
    *   `hive` & `hive_flutter` (high-performance lightweight NoSQL database for offline logs)
    *   `flutter_secure_storage` (secure keychain/keystore storage for sensitive tokens)
    *   `encrypt` (symmetric encryption for locally stored content)
    *   `shared_preferences` (theme state and local user metadata persistence)
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
    *   `cached_network_image` (Network images with automatic offline caching)
    *   `flutter_native_splash` (Premium launch splash screen)
*   **Dev Tools**:
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
5.  **Logging & Debugging Standards**:
    *   Use **only** the global `Logger` utility defined at `lib/core/utils/logger.dart` for console printing, debugging, warnings, and error tracing.
    *   Never use raw `print()` or `debugPrint()` anywhere in the application code.

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

- [x] Complete integration of `go_router` and configure centralized RESTful paths.
- [x] Migrate all stateful modules (Themes, office locations list, and attendance punch status) to pure Riverpod `NotifierProvider` state architectures.
- [x] Construct a modern `core/network` layer integrating `dio`, custom exception mappers, and detailed tracing with `Logger`.
- [ ] Complete integration of `firebase_auth` and design modular Login/Registration flows.
- [ ] Implement Geolocator-based real-time distance assessment for Punch In/Out.
- [ ] Fully wire the database repositories to fetch geofenced active locations directly from Firebase.