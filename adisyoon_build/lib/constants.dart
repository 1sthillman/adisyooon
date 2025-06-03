import 'package:flutter/material.dart';

class Constants {
  // Supabase credentials
  static const String supabaseUrl = 'https://your-supabase-url.supabase.co';
  static const String supabaseAnonKey = 'your-supabase-anon-key';
  
  // Default values
  static const double defaultPadding = 16.0;
  static const double borderRadius = 8.0;
  
  // Table status values
  static const String statusEmpty = 'empty';
  static const String statusOccupied = 'occupied';
  static const String statusPreparing = 'preparing';
  static const String statusReady = 'ready';
  static const String statusPayment = 'payment';
  static const String statusCall = 'call';
  
  // Table status colors
  static const Color primaryColor = Color(0xFFF59E0B); // amber-500 (Turuncu)
  static const Color secondaryColor = Color(0xFFEA580C); // orange-600
  static const Color backgroundColor = Color(0xFFF8FAFC); // slate-50
  static const Color textColor = Color(0xFF1E293B); // slate-800
  static const Color errorColor = Color(0xFFDC2626); // red-600
  static const Color warningColor = Color(0xFFD97706); // amber-600
  static const Color successColor = Color(0xFF059669); // emerald-600
  
  // Table status colors map
  static Map<String, Color> statusColors = {
    statusEmpty: Colors.grey,
    statusOccupied: primaryColor,
    statusPreparing: warningColor,
    statusReady: successColor,
    statusPayment: secondaryColor,
    statusCall: errorColor,
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

  // Renkler
  static const Color cardColor = Color(0xFFFFFFFF);
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Roller
  static const String roleWaiter = 'waiter';
  static const String roleKitchen = 'kitchen';
  static const String roleCashier = 'cashier';
} 