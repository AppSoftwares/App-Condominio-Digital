import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary    = Color(0xFFB5541A); // terracota/teja
  static const secondary  = Color(0xFFD4A843); // dorado/arena
  static const background = Color(0xFFF5F0E8); // beige cálido
  static const surface    = Color(0xFFFFFFFF);
  static const onPrimary  = Color(0xFFFFFFFF);
  static const textDark   = Color(0xFF2C1A0E); // marrón oscuro
  static const green      = Color(0xFF4A7C3F); // verde jardín

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      background: background,
      surface: surface,
      onPrimary: onPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 2,
      titleTextStyle: GoogleFonts.merriweather(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: onPrimary,
      ),
    ),
    textTheme: GoogleFonts.latoTextTheme().copyWith(
      displayLarge: GoogleFonts.merriweather(fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.merriweather(fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: surface,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: surface,
    ),
  );

  static ThemeData get dark => light; // Para simplificar, usamos una variante similar
}
