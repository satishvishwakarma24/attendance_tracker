import 'package:attendance_tracker/config/services/initialize_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  await InitializeServices().initialize();

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
