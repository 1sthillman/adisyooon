import 'package:flutter/material.dart';

class Constants {
  // Supabase credentials
  static const String supabaseUrl = 'https://your-supabase-url.supabase.co';
  static const String supabaseAnonKey = 'your-supabase-anon-key';
  
  // Tasarım değerleri - daha yuvarlak tasarım için
  static const double defaultPadding = 16.0;
  static const double borderRadius = 16.0; // Daha yuvarlak köşeler
  static const double buttonRadius = 24.0; // Butonlar için daha oval
  static const double cardRadius = 20.0; // Kartlar için daha oval
  
  // Animasyon değerleri
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Curve defaultAnimationCurve = Curves.easeInOut;
  
  // Table status values
  static const String statusEmpty = 'empty';
  static const String statusOccupied = 'occupied';
  static const String statusPreparing = 'preparing';
  static const String statusReady = 'ready';
  static const String statusPayment = 'payment';
  static const String statusCall = 'call';
  
  // Modern, transparan ve yumuşak görünüm renkleri
  static const Color primaryColor = Color(0xFFF59E0B); // amber-500 (Turuncu)
  static final Color primaryTransparent = primaryColor.withAlpha((primaryColor.alpha * 0.8).round()); // Transparan turuncu
  static final Color primaryLightTransparent = const Color(0xFFFFE0B2).withAlpha((0xFF * 0.7).round()); // Transparan açık turuncu
  static const Color secondaryColor = Color(0xFFEA580C); // orange-600
  static final Color secondaryTransparent = secondaryColor.withAlpha((secondaryColor.alpha * 0.8).round()); // Transparan koyu turuncu
  static const Color backgroundColor = Color(0xFFF8FAFC); // slate-50
  static const Color textColor = Color(0xFF1E293B); // slate-800
  static final Color textSecondaryColor = const Color(0xFF607D8B).withAlpha((0xFF * 0.8).round()); // Daha açık metin
  static const Color errorColor = Color(0xFFDC2626); // red-600
  static final Color errorTransparent = errorColor.withAlpha((errorColor.alpha * 0.8).round()); // Transparan kırmızı
  static const Color warningColor = Color(0xFFD97706); // amber-600
  static final Color warningTransparent = warningColor.withAlpha((warningColor.alpha * 0.8).round()); // Transparan uyarı
  static const Color successColor = Color(0xFF059669); // emerald-600
  static final Color successTransparent = successColor.withAlpha((successColor.alpha * 0.85).round()); // Transparan yeşil
  static const Color surfaceColor = Color(0xFFFFFFFF); // Beyaz
  static final Color surfaceTransparent = Colors.white.withAlpha((Colors.white.alpha * 0.85).round()); // Yarı saydam beyaz
  
  // Hover efektleri için renkler
  static final Color hoverColor = primaryColor.withAlpha((primaryColor.alpha * 0.1).round());
  static final Color splashColor = primaryColor.withAlpha((primaryColor.alpha * 0.2).round());
  static final Color highlightColor = primaryColor.withAlpha((primaryColor.alpha * 0.15).round());
  
  // Bokeh efektleri için renkler
  static const Color bokehPrimary = Color(0xFFFFECB3); // Açık turuncu
  static const Color bokehSecondary = Color(0xFFFFCC80); // Orta turuncu
  
  // Glassmorphism efekti için
  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withAlpha((Colors.white.alpha * 0.2).round()),
    borderRadius: BorderRadius.circular(buttonRadius),
    border: Border.all(
      color: Colors.white.withAlpha((Colors.white.alpha * 0.3).round()),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha((Colors.black.alpha * 0.05).round()),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ],
  );
  
  // Table status colors map - Transparan renkler
  static Map<String, Color> statusColors = {
    statusEmpty: const Color(0xFFBDBDBD).withAlpha((0xFF * 0.8).round()), // Açık gri
    statusOccupied: primaryTransparent,
    statusPreparing: warningTransparent,
    statusReady: successTransparent,
    statusPayment: secondaryTransparent,
    statusCall: errorTransparent,
  };
  
  // Table status names map
  static Map<String, String> statusNames = {
    statusEmpty: 'Boş',
    statusOccupied: 'Dolu',
    statusPreparing: 'Hazırlanıyor',
    statusReady: 'Hazır',
    statusPayment: 'Ödeme',
    statusCall: 'Çağrı',
  };

  // Gelişmiş stillerle ilgili sabitler
  static const Color cardColor = Color(0xFFFFFFFF);
  static final Color cardTransparentColor = Colors.white.withAlpha((Colors.white.alpha * 0.9).round());
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double smallBorderRadius = 12.0; // Daha oval
  static const double largeBorderRadius = 24.0; // Daha oval
  
  // Roller
  static const String roleWaiter = 'waiter';
  static const String roleKitchen = 'kitchen';
  static const String roleCashier = 'cashier';
  
  // Buton stilleri
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryTransparent,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
    elevation: 2,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  );
  
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondaryTransparent, 
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
    elevation: 2,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  );
  
  static ButtonStyle successButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: successTransparent,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
    elevation: 2,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  );
} 