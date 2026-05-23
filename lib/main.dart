import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'config/constant/app_config.dart';
import 'core/utils/logger.dart';
import 'firebase_options.dart';
import 'app.dart';

/// Main entry point of the application
void main() async {
  // Ensures Flutter engine is initialized before async calls
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keeps splash screen visible until app setup is completed
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Configure transparent status bar for clean UI experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Restrict app orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase and third-party services
  await _initializeServices();

  // Remove native splash screen after setup completion
  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: ScreenUtilInit(
        designSize: Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MyApp(),
      ),
    ),
  );
}

/// Initializes Firebase and external services
Future<void> _initializeServices() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    const webClientId = AppConfig.googleWebClientId;

    // Validate Google Sign-In configuration for Android
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        webClientId.isEmpty) {
      Logger.warning(
        'Google Web Client ID is missing. Google Sign-In may not work properly on Android.',
      );
    }

    await GoogleSignIn.instance.initialize(
      serverClientId: webClientId.isEmpty ? null : webClientId,
    );

    Logger.info(
        'Firebase and authentication services initialized successfully.');
  } catch (error, stackTrace) {
    Logger.error(
      'Application initialization failed while setting up Firebase or Google Sign-In',
      error,
      stackTrace,
    );
  } finally {
    Logger.info('Launching application...');
  }
}
