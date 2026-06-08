import 'package:flutter/material.dart';

/// Central brand palette for Beehive Online.
/// Bee/honey identity: warm honey amber accents on a charcoal "hive ink".
class BeehiveColors {
  static const Color honey = Color(0xFFF6A609); // primary accent / fills
  static const Color honeyDark = Color(0xFFB45309); // accent text on light bg (accessible)
  static const Color honeyTint = Color(0xFFFFF3DC); // soft honey surface
  static const Color ink = Color(0xFF2A2521); // primary text / dark actions
  static const Color cream = Color(0xFFFFFCF6); // app background
  static const Color field = Color(0xFFF3EEE4); // input fill
  static const Color border = Color(0xFFEFE7D6); // hairline borders
  static const Color muted = Color(0xFF8A8178); // secondary text
}

ThemeData buildBeehiveTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: BeehiveColors.cream,
    primaryColor: BeehiveColors.honey,
    colorScheme: base.colorScheme.copyWith(
      primary: BeehiveColors.honey,
      onPrimary: BeehiveColors.ink,
      secondary: BeehiveColors.ink,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: BeehiveColors.ink,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: BeehiveColors.ink,
      displayColor: BeehiveColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: BeehiveColors.ink,
      titleTextStyle: TextStyle(
        color: BeehiveColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: BeehiveColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BeehiveColors.field,
      hintStyle: const TextStyle(color: BeehiveColors.muted),
      labelStyle: const TextStyle(color: BeehiveColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: BeehiveColors.honey, width: 1.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BeehiveColors.honey,
        foregroundColor: BeehiveColors.ink,
        disabledBackgroundColor: const Color(0xFFE7E0D4),
        disabledForegroundColor: BeehiveColors.muted,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BeehiveColors.ink,
        side: const BorderSide(color: BeehiveColors.ink, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: BeehiveColors.honey,
      side: const BorderSide(color: BeehiveColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}
