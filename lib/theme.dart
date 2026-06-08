import 'package:flutter/material.dart';

/// Central brand palette for BeeHive Online.
/// Blue + white identity, with bee yellow used only as a small accent.
class BeehiveColors {
  static const Color blue = Color(0xFF1A73E8); // primary accent
  static const Color blueDark = Color(0xFF1557B0); // gradients / pressed
  static const Color blueTint = Color(0xFFE8F1FE); // soft blue surface
  static const Color yellow = Color(0xFFFFC107); // bee accent — use sparingly
  static const Color ink = Color(0xFF1F2A37); // primary text
  static const Color muted = Color(0xFF6B7280); // secondary text
  static const Color bg = Color(0xFFF7F9FC); // app background (near white)
  static const Color field = Color(0xFFEFF3F9); // input fill
  static const Color border = Color(0xFFE3E8EF); // hairline borders
}

ThemeData buildBeehiveTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: BeehiveColors.bg,
    primaryColor: BeehiveColors.blue,
    colorScheme: base.colorScheme.copyWith(
      primary: BeehiveColors.blue,
      onPrimary: Colors.white,
      secondary: BeehiveColors.blue,
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
        borderSide: const BorderSide(color: BeehiveColors.blue, width: 1.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BeehiveColors.blue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFD7DEE8),
        disabledForegroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BeehiveColors.blue,
        side: const BorderSide(color: BeehiveColors.blue, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: BeehiveColors.blue,
      side: const BorderSide(color: BeehiveColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}
