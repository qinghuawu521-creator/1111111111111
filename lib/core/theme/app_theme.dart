import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette - Deep indigo
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // Accent
  static const Color accent = Color(0xFF06B6D4);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutrals
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // Tag colors
  static const List<Color> tagColors = [
    Color(0xFFEF4444), // red
    Color(0xFFF97316), // orange
    Color(0xFFF59E0B), // amber
    Color(0xFF10B981), // emerald
    Color(0xFF06B6D4), // cyan
    Color(0xFF3B82F6), // blue
    Color(0xFF6366F1), // indigo
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFF78716C), // stone
  ];

  // Category colors
  static const List<Color> categoryColors = [
    Color(0xFF4F46E5), // indigo
    Color(0xFF0891B2), // cyan
    Color(0xFF059669), // emerald
    Color(0xFFD97706), // amber
    Color(0xFFDC2626), // red
    Color(0xFF7C3AED), // violet
    Color(0xFFDB2777), // pink
    Color(0xFF65A30D), // lime
    Color(0xFF0284C7), // sky
    Color(0xFF9333EA), // purple
  ];

  // Entry type colors
  static const Map<String, Color> typeColors = {
    'text': Color(0xFF3B82F6),
    'password': Color(0xFFEF4444),
    'image': Color(0xFF10B981),
    'file': Color(0xFFF59E0B),
    'link': Color(0xFF8B5CF6),
  };

  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

class AppTheme {
  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.accent,
      surface: Colors.white,
      background: AppColors.neutral50,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.neutral900,
      onBackground: AppColors.neutral900,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.neutral50,
      textTheme: GoogleFonts.notoSansScTextTheme().copyWith(
        headlineLarge: GoogleFonts.notoSansSc(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral900,
        ),
        headlineMedium: GoogleFonts.notoSansSc(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
        ),
        headlineSmall: GoogleFonts.notoSansSc(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral800,
        ),
        titleLarge: GoogleFonts.notoSansSc(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral800,
        ),
        titleMedium: GoogleFonts.notoSansSc(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral700,
        ),
        titleSmall: GoogleFonts.notoSansSc(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral700,
        ),
        bodyLarge: GoogleFonts.notoSansSc(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.neutral700,
        ),
        bodyMedium: GoogleFonts.notoSansSc(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.neutral600,
        ),
        bodySmall: GoogleFonts.notoSansSc(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.neutral500,
        ),
        labelLarge: GoogleFonts.notoSansSc(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
        labelMedium: GoogleFonts.notoSansSc(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral500,
        ),
        labelSmall: GoogleFonts.notoSansSc(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral400,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSansSc(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neutral200, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.notoSansSc(
          color: AppColors.neutral400,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.notoSansSc(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(color: AppColors.primary),
          textStyle: GoogleFonts.notoSansSc(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: GoogleFonts.notoSansSc(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.notoSansSc(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.notoSansSc(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: AppColors.primary.withOpacity(0.15),
        labelStyle: GoogleFonts.notoSansSc(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: GoogleFonts.notoSansSc(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral800,
        contentTextStyle: GoogleFonts.notoSansSc(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        modalBarrierColor: Colors.black54,
      ),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primaryLight,
      primaryContainer: AppColors.primary,
      secondary: AppColors.accent,
      surface: const Color(0xFF1E1E2E),
      background: const Color(0xFF11111B),
      error: const Color(0xFFF38BA8),
      onPrimary: AppColors.neutral900,
      onSecondary: AppColors.neutral900,
      onSurface: AppColors.neutral100,
      onBackground: AppColors.neutral100,
      onError: AppColors.neutral900,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF11111B),
      textTheme: GoogleFonts.notoSansScTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E2E),
        foregroundColor: AppColors.neutral100,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E2E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: const Color(0xFF313244), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF181825),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFF313244)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFF313244)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.neutral900,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.neutral900,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E2E),
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: const Color(0xFF313244),
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
