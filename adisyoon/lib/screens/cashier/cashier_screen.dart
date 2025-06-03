import 'package:adisyoon/constants.dart';
import 'package:adisyoon/models/product_model.dart';
import 'package:adisyoon/models/table_model.dart';
import 'package:adisyoon/screens/auth/login_screen.dart';
import 'package:adisyoon/screens/cashier/payment_screen.dart';
import 'package:adisyoon/screens/cashier/product_form_screen.dart';
import 'package:adisyoon/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> with SingleTickerProviderStateMixin {
  final _supabaseService = SupabaseService();
  List<TableModel> _tables = [];
  List<ProductModel> _products = [];
  bool _isLoading = true;
  
  // Tab controller için değişkenler
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    
    _loadData();
    _listenToChanges();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final tables = await _supabaseService.getTables();
      final products = await _supabaseService.getProducts();
      
      setState(() {
        _tables = tables.where((table) => 
          table.status == Constants.statusPayment || 
          (table.status != Constants.statusEmpty && table.partialPayment == true)
        ).toList();
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _listenToChanges() {
    _supabaseService.tablesStream.listen((tables) {
      setState(() {
        _tables = tables.where((table) => 
          table.status == Constants.statusPayment || 
          (table.status != Constants.statusEmpty && table.partialPayment == true)
        ).toList();
      });
    });
    
    _supabaseService.productsStream.listen((products) {
      setState(() {
        _products = products;
      });
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rms_role');
    await prefs.remove('rms_username');
    Get.offAll(() => const LoginScreen());
  }

  void _goToPaymentScreen(TableModel table) {
    Get.to(() => PaymentScreen(table: table));
  }
  
  void _goToProductFormScreen({ProductModel? product}) {
    Get.to(() => ProductFormScreen(product: product));
  }
  
  Future<void> _toggleProductStatus(ProductModel product) async {
    try {
      final updatedProduct = product.copyWith(
        active: !product.active,
      );
      
      await _supabaseService.updateProduct(updatedProduct);
      
      Get.snackbar(
        'Başarılı',
        'Ürün durumu güncellendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Constants.successColor.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'İşlem sırasında bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Constants.errorColor.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        title: const Text('Kasa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ödemeler'),
            Tab(text: 'Ürünler'),
          ],
          labelColor: Constants.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Constants.primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Ödemeler Sekmesi
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tables.isEmpty
                  ? const Center(
                      child: Text(
                        'Bekleyen ödeme bulunmuyor',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(Constants.defaultPadding),
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
                        final table = _tables[index];
                        return _buildPaymentCard(table);
                      },
                    ),
          
          // Ürünler Sekmesi
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(Constants.defaultPadding),
                      child: ElevatedButton.icon(
                        onPressed: () => _goToProductFormScreen(),
                        icon: const Icon(Icons.add),
                        label: const Text('Yeni Ürün Ekle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primaryColor,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Constants.defaultPadding,
                          vertical: 8,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return _buildProductCard(product);
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.secondaryColor,
        onPressed: _loadData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildPaymentCard(TableModel table) {
    final hasPartialPayment = table.partialPayment == true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _goToPaymentScreen(table),
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(Constants.defaultPadding),
              decoration: const BoxDecoration(
                color: Constants.secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Constants.borderRadius),
                  topRight: Radius.circular(Constants.borderRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Masa ${table.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (hasPartialPayment)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Kısmi Ödeme',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Constants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toplam Tutar:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '₺${table.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  if (hasPartialPayment && table.lastPaymentAmount != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ödenen:'),
                        Text(
                          '₺${table.lastPaymentAmount!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Constants.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kalan:'),
                        Text(
                          '₺${(table.total - table.lastPaymentAmount!).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Constants.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (table.lastPaymentMethod != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ödeme Tipi:'),
                          Text(
                            table.lastPaymentMethod!,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _goToPaymentScreen(table),
                      icon: const Icon(Icons.payment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.secondaryColor,
                      ),
                      label: Text(hasPartialPayment ? 'Ödemeyi Tamamla' : 'Ödeme Al'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductCard(ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Ürün görseli
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: product.image != null
                    ? DecorationImage(
                        image: NetworkImage(product.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[200],
              ),
              child: product.image == null
                  ? const Icon(Icons.fastfood, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            // Ürün bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '₺${product.price.toStringAsFixed(2)} · ${_getCategoryName(product.category)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Aktif/Pasif switch
            Switch(
              value: product.active,
              onChanged: (value) => _toggleProductStatus(product),
              activeColor: Constants.primaryColor,
            ),
            // Düzenleme butonu
            IconButton(
              icon: const Icon(Icons.edit, color: Constants.secondaryColor),
              onPressed: () => _goToProductFormScreen(product: product),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getCategoryName(String category) {
    switch (category) {
      case 'food':
        return 'Yemekler';
      case 'drinks':
        return 'İçecekler';
      case 'desserts':
        return 'Tatlılar';
      default:
        return category;
    }
  }
} 