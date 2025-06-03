import 'package:adisyoon/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bildirim izinlerini iste
  await _requestNotificationPermissions();
  
  // Supabase'i başlat (demo)
  try {
    await Supabase.initialize(
      url: 'https://demo.supabase.co',
      anonKey: 'demo',
    );
  } catch (e) {
    debugPrint('Supabase başlatılamadı, demo modu etkin: $e');
  }
  
  runApp(const MyApp());
}

// Bildirim izinlerini iste
Future<void> _requestNotificationPermissions() async {
  try {
    await Permission.notification.request();
  } catch (e) {
    debugPrint('Bildirim izni isteği hatası: $e');
  }
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
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.amber,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
