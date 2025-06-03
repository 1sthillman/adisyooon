import 'package:adisyoon/constants.dart';
import 'package:adisyoon/screens/cashier/cashier_screen.dart';
import 'package:adisyoon/screens/kitchen/kitchen_screen.dart';
import 'package:adisyoon/screens/waiter/waiter_screen.dart';
import 'package:adisyoon/theme/app_container.dart';
import 'package:adisyoon/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _selectedRole;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_selectedRole == null) {
      setState(() {
        _errorMessage = 'Lütfen bir rol seçin';
      });
      return;
    }

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Kullanıcı adı ve şifre gereklidir';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Gerçek uygulamada Supabase ile doğrulama
      // final user = await SupabaseService().login(
      //   _usernameController.text,
      //   _passwordController.text,
      // );
      
      // Demo için basit doğrulama
      final validCredentials = {
        Constants.roleWaiter: {'username': 'garson1', 'password': 'garson1'},
        Constants.roleKitchen: {'username': 'mutfak1', 'password': 'mutfak1'},
        Constants.roleCashier: {'username': 'kasa1', 'password': 'kasa1'},
      };

      final credentials = validCredentials[_selectedRole];
      final isValid = credentials != null &&
          credentials['username'] == _usernameController.text &&
          credentials['password'] == _passwordController.text;

      if (isValid) {
        // Kullanıcı bilgilerini kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('rms_role', _selectedRole!);
        await prefs.setString('rms_username', _usernameController.text);

        // Rol ekranına yönlendir
        _navigateToPanel(_selectedRole!);
      } else {
        setState(() {
          _errorMessage = 'Geçersiz kullanıcı adı veya şifre';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Giriş sırasında bir hata oluştu';
        _isLoading = false;
      });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.amber100,
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppTheme.spacing10),
                  // Logo ve başlık
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.amber400, AppTheme.amber500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.amber500.withOpacity(0.3),
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
                  const SizedBox(height: AppTheme.spacing6),
                  Text(
                    'ADİSYOON',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: AppTheme.fontBold,
                      color: AppTheme.amber600,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    'Restoran Yönetim Sistemi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing10),
                  
                  // Login Card
                  AppCard(
                    padding: const EdgeInsets.all(AppTheme.spacing6),
                    boxShadow: AppTheme.shadowLg,
                    borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hoş Geldiniz',
                          style: TextStyle(
                            fontSize: AppTheme.text2xl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing2),
                        const Text(
                          'Devam etmek için lütfen giriş yapın',
                          style: TextStyle(
                            fontSize: AppTheme.textBase,
                            color: AppTheme.slate600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        const Text(
                          'Rol Seçin',
                          style: TextStyle(
                            fontSize: AppTheme.textBase,
                            fontWeight: AppTheme.fontMedium,
                            color: AppTheme.slate700,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        _buildRoleSelection(),
                        const SizedBox(height: AppTheme.spacing8),
                        _buildLoginForm(),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppTheme.spacing4),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacing4),
                            decoration: BoxDecoration(
                              color: AppTheme.red100,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(color: AppTheme.red200),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppTheme.errorColor,
                                  size: 20,
                                ),
                                const SizedBox(width: AppTheme.spacing3),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppTheme.red800,
                                      fontSize: AppTheme.textSm,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacing8),
                        AppButton(
                          onPressed: _login,
                          isLoading: _isLoading,
                          width: double.infinity,
                          backgroundColor: AppTheme.amber500,
                          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  fontSize: AppTheme.textBase,
                                  fontWeight: AppTheme.fontSemibold,
                                  letterSpacing: 1,
                                ),
                              ),
                              if (!_isLoading) ...[
                                const SizedBox(width: AppTheme.spacing2),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  _buildDemoCredentials(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCredentials() {
    return Card(
      elevation: 0,
      color: AppTheme.amber50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          children: [
            const Text(
              'Demo Giriş Bilgileri',
              style: TextStyle(
                fontSize: AppTheme.textSm,
                fontWeight: AppTheme.fontMedium,
                color: AppTheme.amber700,
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCredentialChip('garson1', AppTheme.amber100, AppTheme.amber700),
                _buildCredentialChip('mutfak1', AppTheme.amber100, AppTheme.amber700),
                _buildCredentialChip('kasa1', AppTheme.amber100, AppTheme.amber700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: AppTheme.textXs,
          fontWeight: AppTheme.fontSemibold,
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildRoleButton(
          title: 'Garson',
          role: Constants.roleWaiter,
          iconData: Icons.people,
          primaryColor: AppTheme.amber500,
          secondaryColor: AppTheme.amber100,
        ),
        _buildRoleButton(
          title: 'Mutfak',
          role: Constants.roleKitchen,
          iconData: Icons.restaurant,
          primaryColor: AppTheme.amber600,
          secondaryColor: AppTheme.amber100,
        ),
        _buildRoleButton(
          title: 'Kasa',
          role: Constants.roleCashier,
          iconData: Icons.point_of_sale,
          primaryColor: AppTheme.amber700,
          secondaryColor: AppTheme.amber100,
        ),
      ],
    );
  }

  Widget _buildRoleButton({
    required String title,
    required String role,
    required IconData iconData,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isSelected ? primaryColor : AppTheme.slate200,
            width: 1.5,
          ),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.3) : secondaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: isSelected ? Colors.white : primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textColor,
                fontSize: AppTheme.textBase,
                fontWeight: isSelected ? AppTheme.fontBold : AppTheme.fontMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        AppTextField(
          label: "Kullanıcı Adı",
          hint: "Kullanıcı adınızı girin",
          controller: _usernameController,
          textInputAction: TextInputAction.next,
          prefix: const Icon(Icons.person_outline, color: AppTheme.slate400),
        ),
        const SizedBox(height: AppTheme.spacing4),
        AppTextField(
          label: "Şifre",
          hint: "Şifrenizi girin",
          controller: _passwordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          prefix: const Icon(Icons.lock_outline, color: AppTheme.slate400),
        ),
      ],
    );
  }
} 