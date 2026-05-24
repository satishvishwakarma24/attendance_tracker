import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central theme for the app
abstract final class AppTheme {
  static const Color seedColor = Color(0xFF0D47A1);
  static const _baseTextTheme = GoogleFonts.interTextTheme;
  static const _baseTextStyle = GoogleFonts.inter;

  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final text = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      primaryTextTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest,
        elevation: 0.5,
        centerTitle: true,
        foregroundColor: scheme.onSurface,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        hintStyle: _baseTextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: _baseTextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: scheme.surfaceContainerLowest,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: _baseTextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.primary,
        contentTextStyle: _baseTextStyle(color: scheme.onPrimary),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.outlineVariant,
        thumbColor: scheme.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    return _baseTextTheme().copyWith(
      headlineMedium: _baseTextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
      titleLarge: _baseTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: scheme.primary,
      ),
      titleMedium: _baseTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
      bodyLarge: _baseTextStyle(fontSize: 16, color: scheme.onSurface),
      bodyMedium: _baseTextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
      bodySmall: _baseTextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
      labelLarge: _baseTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      labelSmall: _baseTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

extension AppThemeX on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  ColorScheme get colors => appTheme.colorScheme;
  TextTheme get textStyles => appTheme.textTheme;
}

/// Semantic punch in/out colors (light and dark aware).
extension AttendancePunchColors on ColorScheme {
  Color get punchIn =>
      brightness == Brightness.light
          ? const Color(0xFF1B5E20)
          : const Color(0xFF81C784);

  Color get onPunchIn =>
      brightness == Brightness.light ? Colors.white : const Color(0xFF1B5E20);

  Color get punchInContainer =>
      brightness == Brightness.light
          ? const Color(0xFFE8F5E9)
          : const Color(0xFF1B5E20).withValues(alpha: 0.22);

  Color get punchOut =>
      brightness == Brightness.light
          ? const Color(0xFFE65100)
          : const Color(0xFFFFB74D);

  Color get onPunchOut =>
      brightness == Brightness.light ? Colors.white : const Color(0xFF4E2600);

  Color get punchOutContainer =>
      brightness == Brightness.light
          ? const Color(0xFFFFF3E0)
          : const Color(0xFFE65100).withValues(alpha: 0.2);
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// /// Central theme for the app
// abstract final class AppTheme {
//   /// Single brand color
//   static const Color seedColor = Color(0xFF0050CB);

//   static ThemeData get light => _theme(Brightness.light);
//   static ThemeData get dark => _theme(Brightness.dark);

//   static ThemeData _theme(Brightness brightness) {
//     final scheme = ColorScheme.fromSeed(
//       seedColor: seedColor,
//       brightness: brightness,
//     );
//     final text = _textTheme(scheme);

//     return ThemeData(
//       useMaterial3: true,
//       brightness: brightness,
//       colorScheme: scheme,
//       scaffoldBackgroundColor: scheme.surface,
//       textTheme: text,
//       primaryTextTheme: text,
//       appBarTheme: AppBarTheme(
//         backgroundColor: scheme.surfaceContainerLowest,
//         elevation: 0.5,
//         centerTitle: true,
//         foregroundColor: scheme.onSurface,
//         titleTextStyle: text.titleLarge,
//         iconTheme: IconThemeData(color: scheme.onSurface),
//       ),
//       cardTheme: CardThemeData(
//         color: scheme.surfaceContainerLowest,
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(color: scheme.outlineVariant),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: scheme.surfaceContainerLowest,
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: scheme.outline),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: scheme.outline),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: scheme.primary, width: 1.5),
//         ),
//         hintStyle: GoogleFonts.lato(color: scheme.onSurfaceVariant),
//         prefixIconColor: scheme.onSurfaceVariant,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: scheme.primary,
//           foregroundColor: scheme.onPrimary,
//           elevation: 3,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           backgroundColor: scheme.surfaceContainerLowest,
//           foregroundColor: scheme.onSurface,
//           side: BorderSide(color: scheme.outlineVariant),
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           textStyle: GoogleFonts.lato(fontWeight: FontWeight.w600),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//       floatingActionButtonTheme: FloatingActionButtonThemeData(
//         backgroundColor: scheme.primary,
//         foregroundColor: scheme.onPrimary,
//       ),
//       snackBarTheme: SnackBarThemeData(
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: scheme.primary,
//         contentTextStyle: GoogleFonts.lato(color: scheme.onPrimary),
//       ),
//       dividerTheme: DividerThemeData(
//         color: scheme.outlineVariant,
//         thickness: 1,
//       ),
//       sliderTheme: SliderThemeData(
//         activeTrackColor: scheme.primary,
//         inactiveTrackColor: scheme.outlineVariant,
//         thumbColor: scheme.primary,
//       ),
//       progressIndicatorTheme: ProgressIndicatorThemeData(
//         color: scheme.primary,
//       ),
//     );
//   }

//   static TextTheme _textTheme(ColorScheme scheme) {
//     return GoogleFonts.latoTextTheme().copyWith(
//       headlineMedium: GoogleFonts.lato(
//         fontSize: 28,
//         fontWeight: FontWeight.bold,
//         color: scheme.onSurface,
//       ),
//       titleLarge: GoogleFonts.lato(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: scheme.primary,
//       ),
//       titleMedium: GoogleFonts.lato(
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//         color: scheme.onSurface,
//       ),
//       bodyLarge: GoogleFonts.lato(fontSize: 16, color: scheme.onSurface),
//       bodyMedium:
//           GoogleFonts.lato(fontSize: 14, color: scheme.onSurfaceVariant),
//       bodySmall: GoogleFonts.lato(fontSize: 12, color: scheme.onSurfaceVariant),
//       labelLarge: GoogleFonts.lato(
//         fontSize: 14,
//         fontWeight: FontWeight.w600,
//         color: scheme.onSurface,
//       ),
//       labelSmall: GoogleFonts.lato(
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//         letterSpacing: 1.2,
//         color: scheme.onSurfaceVariant,
//       ),
//     );
//   }
// }

// extension AppThemeX on BuildContext {
//   ThemeData get appTheme => Theme.of(this);
//   ColorScheme get colors => appTheme.colorScheme;
//   TextTheme get textStyles => appTheme.textTheme;
// }
