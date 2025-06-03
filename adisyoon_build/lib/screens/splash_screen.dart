import 'package:adisyoon/constants.dart';
import 'package:adisyoon/screens/auth/login_screen.dart';
import 'package:adisyoon/screens/cashier/cashier_screen.dart';
import 'package:adisyoon/screens/kitchen/kitchen_screen.dart';
import 'package:adisyoon/screens/waiter/waiter_screen.dart';
import 'package:adisyoon/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('rms_role');
    
    if (role != null) {
      // Kullanıcı giriş yapmış, role göre panele yönlendir
      _navigateToPanel(role);
    } else {
      // Kullanıcı giriş yapmamış, giriş ekranına yönlendir
      Get.off(() => const LoginScreen());
    }
  }

  void _navigateToPanel(String role) {
    switch (role) {
      case Constants.roleWaiter:
        Get.off(() => const WaiterScreen());
        break;
      case Constants.roleKitchen:
        Get.off(() => const KitchenScreen());
        break;
      case Constants.roleCashier:
        Get.off(() => const CashierScreen());
        break;
      default:
        Get.off(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Constants.primaryColor, Constants.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Constants.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 70,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'ADİSYOON',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Restoran Sipariş Yönetim Sistemi',
              style: TextStyle(
                fontSize: 18,
                color: Constants.textColor,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Constants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
} 