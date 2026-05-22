import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/utils/logger.dart';
import 'app.dart';

/// Top-level background message handler for Firebase Cloud Messaging.
/// It must be annotated with @pragma('vm:entry-point') to prevent tree-shaking
/// and to run correctly in a separate background isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    Logger.info('FCM background message received: ${message.messageId}');
  } catch (e, s) {
    Logger.error('Failed to handle FCM background message: $e', e, s);
  }
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Set system UI styling for a premium modern look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize local Hive database
  try {
    await Hive.initFlutter();
    Logger.info('Hive database initialized successfully.');
  } catch (e, s) {
    Logger.error('Failed to initialize Hive database: $e', e, s);
  }

  // Initialize Firebase, Crashlytics, Analytics, and Messaging with platform-safe configuration checks
  try {
    await Firebase.initializeApp();
    
    // Setup Flutter fatal error capturing via Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Setup asynchronous platform level fatal error capturing
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Log initial app launch session to Firebase Analytics
    await FirebaseAnalytics.instance.logAppOpen();

    // Register the background message handler for FCM
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permission for Firebase Cloud Messaging
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    Logger.info('Firebase initialized successfully. FCM Permission status: ${settings.authorizationStatus}');
  } catch (e, s) {
    Logger.error(
      'Failed to initialize Firebase services. Please verify that your google-services.json (Android) '
      'and GoogleService-Info.plist (iOS) configuration files are in place. Error: $e', 
      e, 
      s,
    );
  }

  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: ScreenUtilInit(
        designSize: Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        child: App(),
      ),
    ),
  );
}
