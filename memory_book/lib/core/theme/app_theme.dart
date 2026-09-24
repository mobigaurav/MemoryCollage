import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class MbTheme {
  static const _sans = TextStyle(fontFamily: MbTokens.sans);
  static const _serif = TextStyle(fontFamily: MbTokens.serif);

  static ThemeData get darkroom => _build(Brightness.dark);

  /// Paper studio for the tab shell: Books, Studio, You.
  static ThemeData get studio => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final ink = dark ? MbTokens.cream : MbTokens.ink;
    final muted = dark ? MbTokens.paper : MbTokens.inkSoft;
    final surface = dark ? MbTokens.leather : MbTokens.paper;
    final scaffold = dark ? MbTokens.leatherDark : MbTokens.cream;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: dark ? MbTokens.foil : MbTokens.leather,
      onPrimary: dark ? MbTokens.ink : MbTokens.cream,
      secondary: MbTokens.foil,
      onSecondary: MbTokens.ink,
      surface: surface,
      onSurface: ink,
      error: MbTokens.danger,
      onError: MbTokens.cream,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = TextTheme(
      displayLarge: _serif.copyWith(
        fontSize: 44,
        height: 1.05,
        color: ink,
        letterSpacing: -0.6,
      ),
      headlineMedium: _serif.copyWith(
        fontSize: 32,
        height: 1.1,
        color: ink,
      ),
      titleLarge: _serif.copyWith(fontSize: 26, height: 1.15, color: ink),
      titleMedium: _sans.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: ink,
      ),
      bodyLarge: _sans.copyWith(fontSize: 16, height: 1.45, color: muted),
      bodyMedium: _sans.copyWith(fontSize: 15, height: 1.45, color: muted),
      labelLarge: _sans.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: ink,
      ),
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(MbTokens.radiusMd),
    );
    return base.copyWith(
      scaffoldBackgroundColor: scaffold,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: ink,
        titleTextStyle: _serif.copyWith(fontSize: 22, color: ink),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: MbTokens.ink,
        contentTextStyle: TextStyle(
          fontFamily: MbTokens.sans,
          color: MbTokens.cream,
          fontSize: 15,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: dark
          ? MbTokens.leather.withValues(alpha: 0.8)
          : MbTokens.linen,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: dark ? MbTokens.foil : MbTokens.leather,
          foregroundColor: dark ? MbTokens.ink : MbTokens.cream,
          minimumSize: const Size(64, MbTokens.tap),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: MbTokens.sans,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(64, MbTokens.tap),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          side: BorderSide(color: dark ? const Color(0x66C4A35A) : MbTokens.leather),
          textStyle: const TextStyle(
            fontFamily: MbTokens.sans,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dark ? MbTokens.foil : MbTokens.leather,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: MbTokens.sans,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
          foregroundColor: ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? MbTokens.leather : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        labelStyle: _sans.copyWith(color: muted, fontSize: 15),
        hintStyle: _sans.copyWith(color: MbTokens.caption),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MbTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? MbTokens.leather : Colors.white,
        selectedColor: dark ? MbTokens.foil : MbTokens.leather,
        labelStyle: _sans.copyWith(fontSize: 15, color: ink),
        secondaryLabelStyle: _sans.copyWith(
          fontSize: 15,
          color: dark ? MbTokens.ink : MbTokens.cream,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        side: BorderSide(color: dark ? MbTokens.filmBorder : MbTokens.linen),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: dark ? MbTokens.foil : MbTokens.leather,
        textColor: ink,
        minTileHeight: 64,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        titleTextStyle: _sans.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        subtitleTextStyle: _sans.copyWith(fontSize: 14, height: 1.35, color: muted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: MbTokens.paper,
        indicatorColor: MbTokens.leather,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: MbTokens.sans,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? MbTokens.leather : MbTokens.caption,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 26,
            color: selected ? MbTokens.cream : MbTokens.inkSoft,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MbTokens.leatherDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
