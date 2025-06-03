import 'dart:async';
import 'package:adisyoon/constants.dart';
import 'package:adisyoon/models/order_item_model.dart';
import 'package:adisyoon/models/product_model.dart';
import 'package:adisyoon/models/table_model.dart';
import 'package:adisyoon/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableDetailScreen extends StatefulWidget {
  final int tableId;

  const TableDetailScreen({super.key, required this.tableId});

  @override
  State<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  final _supabaseService = SupabaseService();
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();
  
  TableModel? _table;
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  String _selectedCategory = 'all';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showAddItemsPanel = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _fetchTable();
    _listenTableChanges();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _searchController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _fetchTable() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      final tables = await _supabaseService.getTables();
      final table = tables.firstWhere((t) => t.id == widget.tableId);
      final products = await _supabaseService.getProducts();

      if (mounted) {
        setState(() {
          _table = table;
          _products = products;
          _filteredProducts = products;
          _noteController.text = table.note ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        Get.snackbar(
          'Hata',
          'Masa bilgileri yüklenemedi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Constants.errorColor.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    }
  }

  void _listenTableChanges() {
    _subscription = _supabaseService.tablesStream.listen((tables) {
      final updatedTable = tables.firstWhere(
        (t) => t.id == widget.tableId,
        orElse: () => _table ?? TableModel(id: widget.tableId, status: Constants.statusEmpty, order: [], total: 0),
      );
      
      if (mounted && _table != updatedTable) {
        setState(() {
          _table = updatedTable;
          _noteController.text = updatedTable.note ?? '';
        });
      }
    });

    _supabaseService.productsStream.listen((products) {
      setState(() {
        _products = products;
        _filterProducts();
      });
    });
  }

  void _filterProducts() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(searchTerm);
        final matchesCategory = _selectedCategory == 'all' || 
            product.category == _selectedCategory;
        return product.active && matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _addProductToOrder(ProductModel product) {
    if (_table == null) return;

    final order = List<OrderItemModel>.from(_table!.order);
    final existingItemIndex = order.indexWhere((item) => item.id == product.id);

    if (existingItemIndex != -1) {
      // Eğer ürün zaten varsa, miktarını artır
      final existingItem = order[existingItemIndex];
      order[existingItemIndex] = OrderItemModel(
        id: existingItem.id,
        name: existingItem.name,
        price: existingItem.price,
        quantity: existingItem.quantity + 1,
      );
    } else {
      // Yeni ürün ekle
      order.add(OrderItemModel(
        id: product.id,
        name: product.name,
        price: product.price,
        quantity: 1,
      ));
    }

    // Toplam tutarı güncelle
    final total = order.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    setState(() {
      _table = _table!.copyWith(
        order: order,
        total: total,
      );
    });
  }

  Future<void> _sendOrder() async {
    if (_table == null || _table!.order.isEmpty) {
      Get.snackbar(
        'Hata',
        'Lütfen önce sipariş ekleyin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Constants.errorColor.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Notları güncelle
      final updatedTable = _table!.copyWith(
        note: _noteController.text,
        status: Constants.statusPreparing,
        updatedAt: DateTime.now(),
      );

      await _supabaseService.updateTable(updatedTable);

      setState(() {
        _isSaving = false;
        _showAddItemsPanel = false;
      });

      Get.snackbar(
        'Başarılı',
        'Sipariş mutfağa gönderildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Constants.successColor.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      Get.snackbar(
        'Hata',
        'Sipariş gönderilirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Constants.errorColor.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _markAsDelivered() async {
    if (_table == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedTable = _table!.copyWith(
        status: Constants.statusOccupied,
        updatedAt: DateTime.now(),
      );

      await _supabaseService.updateTable(updatedTable);

      setState(() {
        _isSaving = false;
      });

      Get.back();
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      Get.snackbar(
        'Hata',
        'İşlem sırasında bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Constants.errorColor.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendToPayment() async {
    if (_table == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedTable = _table!.copyWith(
        status: Constants.statusPayment,
        updatedAt: DateTime.now(),
      );

      await _supabaseService.updateTable(updatedTable);

      setState(() {
        _isSaving = false;
      });

      Get.back();
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      Get.snackbar(
        'Hata',
        'İşlem sırasında bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Constants.errorColor.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _clearTable() async {
    if (_table == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedTable = _table!.copyWith(
        status: Constants.statusEmpty,
        order: [],
        note: '',
        total: 0,
        partialPayment: false,
        lastPaymentMethod: null,
        lastPaymentAmount: null,
        lastPaymentTime: null,
        readyTime: null,
        updatedAt: DateTime.now(),
      );

      await _supabaseService.updateTable(updatedTable);

      setState(() {
        _isSaving = false;
      });

      Get.back();
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      Get.snackbar(
        'Hata',
        'İşlem sırasında bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Constants.errorColor.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _respondToCall() async {
    if (_table == null || _table!.status != Constants.statusCall) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedTable = _table!.copyWith(
        status: Constants.statusOccupied,
        updatedAt: DateTime.now(),
      );

      await _supabaseService.updateTable(updatedTable);

      setState(() {
        _isSaving = false;
      });

      Get.back();
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
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
        title: Text('Masa ${widget.tableId}'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _table == null
              ? const Center(
                  child: Text('Masa bulunamadı'),
                )
              : _showAddItemsPanel
                  ? _buildAddItemsPanel()
                  : _buildTableDetailsPanel(),
    );
  }

  Widget _buildTableDetailsPanel() {
    return Padding(
      padding: const EdgeInsets.all(Constants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mevcut Sipariş',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAddItemsPanel = true;
                    _selectedCategory = 'all';
                    _searchController.clear();
                    _filterProducts();
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Ürün Ekle'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _table!.order.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'Henüz ürün eklenmedi',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                    itemCount: _table!.order.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = _table!.order[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.name),
                        subtitle: Text('₺${item.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${item.quantity}x'),
                            const SizedBox(width: 16),
                            Text(
                              '₺${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          if (_table!.order.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Toplam:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '₺${_table!.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Not',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'Özel talimatlar ekleyin...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _sendOrder,
                  icon: const Icon(Icons.send),
                  label: const Text('Mutfağa Gönder'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_table!.status == Constants.statusReady)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _markAsDelivered,
                    icon: const Icon(Icons.check),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.successColor,
                    ),
                    label: const Text('Teslim Edildi'),
                  ),
                ),
              if (_table!.status != Constants.statusEmpty && 
                  _table!.status != Constants.statusPayment) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _sendToPayment,
                    icon: const Icon(Icons.payment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.secondaryColor,
                    ),
                    label: const Text('Kasaya Gönder'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _clearTable,
              icon: const Icon(Icons.delete_outline),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              label: const Text('Masayı Temizle'),
            ),
          ),
          if (_table!.status == Constants.statusCall) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _respondToCall,
                icon: const Icon(Icons.support_agent),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.errorColor,
                ),
                label: const Text('Geliyorum'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddItemsPanel() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(Constants.defaultPadding),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Ürün ara...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => _filterProducts(),
              ),
              const SizedBox(height: 16),
              _buildCategoryFilter(),
            ],
          ),
        ),
        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(
                  child: Text(
                    'Ürün bulunamadı',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(Constants.defaultPadding),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return _buildProductCard(product);
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(Constants.defaultPadding),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showAddItemsPanel = false;
                    });
                  },
                  child: const Text('İptal'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAddItemsPanel = false;
                    });
                  },
                  child: const Text('Tamam'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryButton('all', 'Tümü'),
          _buildCategoryButton('food', 'Yemekler'),
          _buildCategoryButton('drinks', 'İçecekler'),
          _buildCategoryButton('desserts', 'Tatlılar'),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category, String label) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _filterProducts();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Constants.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => _addProductToOrder(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Constants.borderRadius),
                topRight: Radius.circular(Constants.borderRadius),
              ),
              child: product.image != null
                  ? Image.network(
                      product.image!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₺${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Constants.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 