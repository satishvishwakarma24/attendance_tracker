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

  // Initialize Firebase, with platform-safe configuration checks
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    const webClientId = AppConfig.googleWebClientId;
    if (kIsWeb == false &&
        defaultTargetPlatform == TargetPlatform.android &&
        webClientId.isEmpty) {
      Logger.warning(
        'AppConfig.googleWebClientId is empty. Google Sign-In will fail on Android.',
      );
    }
    await GoogleSignIn.instance.initialize(
      serverClientId: webClientId.isEmpty ? null : webClientId,
    );
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
        child: MyApp(),
      ),
    ),
  );
}
