import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Flodo Midnight Palette
  static const Color background = Color(0xFF0b0c1f);
  static const Color surfaceContainerLow = Color(0xFF101126);
  static const Color surfaceContainer = Color(0xFF16172e);
  static const Color surfaceContainerHigh = Color(0xFF1c1d36);
  static const Color surfaceContainerHighest = Color(0xFF22233e);
  static const Color surfaceContainerLowest = Color(0xFF000000);
  
  static const Color primary = Color(0xFFb6a0ff);
  static const Color primaryDim = Color(0xFF7e51ff);
  static const Color primaryContainer = Color(0xFFa98fff);
  static const Color onPrimaryFixed = Color(0xFF000000);
  
  static const Color secondary = Color(0xFFbc8df9);
  static const Color tertiary = Color(0xFFff96bb);
  static const Color tertiaryDim = Color(0xFFee77a3);
  
  static const Color onSurface = Color(0xFFe4e3fe);
  static const Color onSurfaceVariant = Color(0xFFa9a9c2);
  static const Color outlineVariant = Color(0xFF46465b);
  static const Color surfaceVariant = Color(0xFF22233e);
  
  static const Color error = Color(0xFFff6e84);
  static const Color errorDim = Color(0xFFd73357);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: background,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(color: onSurface, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.manrope(color: onSurface, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.manrope(color: onSurface, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.manrope(color: onSurface, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.manrope(color: onSurface, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.manrope(color: onSurface, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.manrope(color: onSurface, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.manrope(color: onSurface, fontWeight: FontWeight.bold),
        titleSmall: GoogleFonts.inter(color: onSurface, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: onSurface),
        bodyMedium: GoogleFonts.inter(color: onSurface),
        bodySmall: GoogleFonts.inter(color: onSurfaceVariant),
        labelLarge: GoogleFonts.inter(color: onSurfaceVariant, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.inter(color: onSurfaceVariant),
        labelSmall: GoogleFonts.inter(color: onSurfaceVariant),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceContainerLow,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tertiaryDim; 
          }
          return surfaceContainerHighest;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        hintStyle: GoogleFonts.inter(color: onSurfaceVariant.withValues(alpha: 0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary),
        ),
      ),
    );
  }
}
