import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '/core/utils/logger.dart';
import '/core/utils/static_map_url.dart';
import '/config/constant/app_config.dart';
import '/firebase_options.dart';

final class InitializeServices {
  // Initializes Firebase and external services
  Future<void> initialize() async {
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

      /// Initialize Google Maps SDK
      await initializeGoogleMaps();

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
}

/// Warms up the native Google Maps SDK before the first interactive map.
///
/// The API key must be in native config (Android manifest / iOS AppDelegate);
/// see README.
Future<void> initializeGoogleMaps() async {
  if (kIsWeb || !StaticMapUrl.hasGoogleKey) return;

  try {
    if (Platform.isAndroid) {
      await GoogleMapsFlutterAndroid().warmup();
    }
    Logger.info('Google Maps SDK initialized successfully.');
  } catch (e, s) {
    Logger.error('Google Maps SDK initialization failed', e, s);
  }
}
