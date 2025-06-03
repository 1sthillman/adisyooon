import 'package:adisyoon/constants.dart';
import 'package:adisyoon/screens/splash_screen.dart';
import 'package:adisyoon/services/notification_service.dart';
import 'package:adisyoon/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase bağlantısını başlat
  await Supabase.initialize(
    url: Constants.supabaseUrl,
    anonKey: Constants.supabaseAnonKey,
    debug: true,
  );
  
  // Bildirim servisini başlat
  NotificationService();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Adisyoon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          primary: AppTheme.primaryColor,
          secondary: AppTheme.secondaryColor,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
