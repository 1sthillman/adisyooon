import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TailwindCSS benzeri bir tema yapısı oluşturuyoruz
class AppTheme {
  // Tailwind CSS renk paleti
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  
  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);
  
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color indigo800 = Color(0xFF3730A3);
  static const Color indigo900 = Color(0xFF312E81);
  
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);
  
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);
  
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);
  static const Color red900 = Color(0xFF7F1D1D);
  
  // Tema renkleri - önceki constants.dart'taki renkleri referans alıyoruz
  static const Color primaryColor = amber500;
  static const Color secondaryColor = amber600;
  static const Color backgroundColor = slate50;
  static const Color cardColor = Colors.white;
  static const Color errorColor = red600;
  static const Color warningColor = amber600;
  static const Color successColor = emerald600;
  static const Color textColor = slate800;
  static const Color textSecondaryColor = slate600;
  static const Color textTertiaryColor = slate400;
  
  // Tailwind CSS boşluk değerleri
  static const double spacing0 = 0.0;
  static const double spacing0_5 = 2.0;  // 0.125rem
  static const double spacing1 = 4.0;    // 0.25rem
  static const double spacing1_5 = 6.0;  // 0.375rem
  static const double spacing2 = 8.0;    // 0.5rem
  static const double spacing2_5 = 10.0; // 0.625rem
  static const double spacing3 = 12.0;   // 0.75rem
  static const double spacing3_5 = 14.0; // 0.875rem
  static const double spacing4 = 16.0;   // 1rem
  static const double spacing5 = 20.0;   // 1.25rem
  static const double spacing6 = 24.0;   // 1.5rem
  static const double spacing7 = 28.0;   // 1.75rem
  static const double spacing8 = 32.0;   // 2rem
  static const double spacing9 = 36.0;   // 2.25rem
  static const double spacing10 = 40.0;  // 2.5rem
  static const double spacing11 = 44.0;  // 2.75rem
  static const double spacing12 = 48.0;  // 3rem
  static const double spacing14 = 56.0;  // 3.5rem
  static const double spacing16 = 64.0;  // 4rem
  static const double spacing20 = 80.0;  // 5rem
  static const double spacing24 = 96.0;  // 6rem
  static const double spacing28 = 112.0; // 7rem
  static const double spacing32 = 128.0; // 8rem
  static const double spacing36 = 144.0; // 9rem
  static const double spacing40 = 160.0; // 10rem
  static const double spacing44 = 176.0; // 11rem
  static const double spacing48 = 192.0; // 12rem
  static const double spacing52 = 208.0; // 13rem
  static const double spacing56 = 224.0; // 14rem
  static const double spacing60 = 240.0; // 15rem
  static const double spacing64 = 256.0; // 16rem
  static const double spacing72 = 288.0; // 18rem
  static const double spacing80 = 320.0; // 20rem
  static const double spacing96 = 384.0; // 24rem
  
  // Tailwind CSS kenar yuvarlaklık değerleri
  static const double radiusNone = 0.0;
  static const double radiusSm = 2.0;
  static const double radiusBase = 4.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radius2xl = 16.0;
  static const double radius3xl = 24.0;
  static const double radiusFull = 9999.0;
  
  // Tailwind CSS font boyutu değerleri
  static const double textXs = 12.0;
  static const double textSm = 14.0;
  static const double textBase = 16.0;
  static const double textLg = 18.0;
  static const double textXl = 20.0;
  static const double text2xl = 24.0;
  static const double text3xl = 30.0;
  static const double text4xl = 36.0;
  static const double text5xl = 48.0;
  static const double text6xl = 60.0;
  static const double text7xl = 72.0;
  static const double text8xl = 96.0;
  static const double text9xl = 128.0;
  
  // Tailwind CSS font ağırlığı değerleri
  static const FontWeight fontThin = FontWeight.w100;
  static const FontWeight fontExtralight = FontWeight.w200;
  static const FontWeight fontLight = FontWeight.w300;
  static const FontWeight fontNormal = FontWeight.w400;
  static const FontWeight fontMedium = FontWeight.w500;
  static const FontWeight fontSemibold = FontWeight.w600;
  static const FontWeight fontBold = FontWeight.w700;
  static const FontWeight fontExtrabold = FontWeight.w800;
  static const FontWeight fontBlack = FontWeight.w900;
  
  // Gölge değerleri
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 1.0,
      spreadRadius: 0.0,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> shadowBase = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 3.0,
      spreadRadius: 0.0,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 2.0,
      spreadRadius: 0.0,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6.0,
      spreadRadius: -1.0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 4.0,
      spreadRadius: -2.0,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 15.0,
      spreadRadius: -3.0,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 6.0,
      spreadRadius: -2.0,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 25.0,
      spreadRadius: -5.0,
      offset: const Offset(0, 20),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10.0,
      spreadRadius: -5.0,
      offset: const Offset(0, 10),
    ),
  ];
  
  // Flutter ThemeData oluştur
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: cardColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: const TextStyle(
          fontSize: text6xl,
          fontWeight: fontBold,
          color: textColor,
        ),
        displayMedium: const TextStyle(
          fontSize: text5xl,
          fontWeight: fontBold,
          color: textColor,
        ),
        displaySmall: const TextStyle(
          fontSize: text4xl,
          fontWeight: fontBold,
          color: textColor,
        ),
        headlineLarge: const TextStyle(
          fontSize: text3xl,
          fontWeight: fontBold,
          color: textColor,
        ),
        headlineMedium: const TextStyle(
          fontSize: text2xl,
          fontWeight: fontSemibold,
          color: textColor,
        ),
        headlineSmall: const TextStyle(
          fontSize: textXl,
          fontWeight: fontSemibold,
          color: textColor,
        ),
        titleLarge: const TextStyle(
          fontSize: textLg,
          fontWeight: fontMedium,
          color: textColor,
        ),
        titleMedium: const TextStyle(
          fontSize: textBase,
          fontWeight: fontMedium,
          color: textColor,
        ),
        titleSmall: const TextStyle(
          fontSize: textSm,
          fontWeight: fontMedium,
          color: textSecondaryColor,
        ),
        bodyLarge: const TextStyle(
          fontSize: textBase,
          fontWeight: fontNormal,
          color: textColor,
        ),
        bodyMedium: const TextStyle(
          fontSize: textSm,
          fontWeight: fontNormal,
          color: textColor,
        ),
        bodySmall: const TextStyle(
          fontSize: textXs,
          fontWeight: fontNormal,
          color: textSecondaryColor,
        ),
        labelLarge: const TextStyle(
          fontSize: textSm,
          fontWeight: fontMedium,
          color: primaryColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: textLg,
          fontWeight: fontSemibold,
          color: textColor,
        ),
        iconTheme: const IconThemeData(color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing6,
            vertical: spacing3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: textSm,
            fontWeight: fontMedium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing6,
            vertical: spacing3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: textSm,
            fontWeight: fontMedium,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing4,
            vertical: spacing2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: textSm,
            fontWeight: fontMedium,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(spacing4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(
          fontSize: textSm,
          fontWeight: fontNormal,
          color: textSecondaryColor,
        ),
        hintStyle: const TextStyle(
          fontSize: textSm,
          fontWeight: fontNormal,
          color: textTertiaryColor,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: slate200,
        thickness: 1,
        space: spacing4,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        side: const BorderSide(color: slate400),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return slate400;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return slate300;
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: slate500,
        selectedLabelStyle: TextStyle(
          fontSize: textXs,
          fontWeight: fontMedium,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: textXs,
          fontWeight: fontNormal,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: slate800,
        contentTextStyle: const TextStyle(
          fontSize: textSm,
          fontWeight: fontNormal,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: slate200,
        linearTrackColor: slate200,
      ),
    );
  }
} 