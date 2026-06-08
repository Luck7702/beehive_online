import 'package:flutter/material.dart';

/// Central brand palette for BeeHive Online.
/// Blue + white identity, with bee yellow used as a warm accent.
class BeehiveColors {
  static const Color blue = Color(0xFF1A73E8); // primary accent
  static const Color blueDark = Color(0xFF1557B0); // gradients / pressed
  static const Color blueTint = Color(0xFFE8F1FE); // soft blue surface
  static const Color yellow = Color(0xFFFFC107); // bee accent
  static const Color yellowDark = Color(0xFFF59E0B); // deeper honey accent
  static const Color ink = Color(0xFF111827); // primary text
  static const Color muted = Color(0xFF6B7280); // secondary text
  static const Color bg = Color(0xFFF5F7FB); // app background (near white)
  static const Color field = Color(0xFFEFF3F9); // input fill
  static const Color border = Color(0xFFE8ECF3); // hairline borders
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);

  /// Brand gradient for hero surfaces (banners, headers).
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF2B86F0), blueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warm honey gradient used by the brand logo.
  static const LinearGradient honeyGradient = LinearGradient(
    colors: [Color(0xFFFFD24D), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft, diffuse shadow that lifts cards and buttons gently off the page.
  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x12101828), blurRadius: 18, offset: Offset(0, 8)),
  ];
}

ThemeData buildBeehiveTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: BeehiveColors.bg,
    primaryColor: BeehiveColors.blue,
    colorScheme: base.colorScheme.copyWith(
      primary: BeehiveColors.blue,
      onPrimary: Colors.white,
      secondary: BeehiveColors.yellowDark,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: BeehiveColors.ink,
      error: BeehiveColors.danger,
    ),
    textTheme: _buildTextTheme(base.textTheme),
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
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 3,
      shadowColor: const Color(0x14101828),
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: BeehiveColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: BeehiveColors.muted),
      labelStyle: const TextStyle(color: BeehiveColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BeehiveColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BeehiveColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BeehiveColors.blue, width: 1.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BeehiveColors.blue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFCBD5E1),
        disabledForegroundColor: Colors.white,
        elevation: 2,
        shadowColor: BeehiveColors.blue.withValues(alpha: 0.35),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BeehiveColors.blue,
        backgroundColor: Colors.white,
        side: const BorderSide(color: BeehiveColors.blue, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BeehiveColors.blue,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: BeehiveColors.blue,
      side: const BorderSide(color: BeehiveColors.border),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: BeehiveColors.ink,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(color: BeehiveColors.border, thickness: 1),
  );
}

TextTheme _buildTextTheme(TextTheme base) {
  final t = base.apply(bodyColor: BeehiveColors.ink, displayColor: BeehiveColors.ink);
  return t.copyWith(
    headlineMedium: t.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
    headlineSmall: t.headlineSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
    titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.3),
    titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    bodyMedium: t.bodyMedium?.copyWith(height: 1.4),
  );
}
