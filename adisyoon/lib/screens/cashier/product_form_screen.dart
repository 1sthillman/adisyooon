import 'package:adisyoon/constants.dart';
import 'package:adisyoon/models/product_model.dart';
import 'package:adisyoon/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  
  String _selectedCategory = 'food';
  bool _isActive = true;
  bool _isSaving = false;
  
  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    
    // Eğer düzenleme modundaysa, ürün bilgilerini form alanlarına yerleştir
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _imageController.text = widget.product!.image ?? '';
      _selectedCategory = widget.product!.category;
      _isActive = widget.product!.active;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
      
      if (widget.product != null) {
        // Var olan ürünü güncelle
        final updatedProduct = widget.product!.copyWith(
          name: _nameController.text.trim(),
          price: price,
          category: _selectedCategory,
          image: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
          active: _isActive,
        );
        
        await _supabaseService.updateProduct(updatedProduct);
        
        Get.back();
        Get.snackbar(
          'Başarılı',
          'Ürün güncellendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Constants.successColor.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        // Yeni ürün ekle
        // Mevcut en büyük ID'yi bul
        final products = await _supabaseService.getProducts();
        int maxId = 0;
        for (var product in products) {
          if (product.id > maxId) {
            maxId = product.id;
          }
        }
        
        final newProduct = ProductModel(
          id: maxId + 1,
          name: _nameController.text.trim(),
          price: price,
          category: _selectedCategory,
          image: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
          active: _isActive,
        );
        
        await _supabaseService.addProduct(newProduct);
        
        Get.back();
        Get.snackbar(
          'Başarılı',
          'Yeni ürün eklendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Constants.successColor.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
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
    final isEditMode = widget.product != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Ürün Düzenle' : 'Yeni Ürün Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Constants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün Adı
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Adı',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ürün adı gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Fiyat
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Fiyat',
                  prefixText: '₺',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Fiyat gereklidir';
                  }
                  final price = double.tryParse(value.replaceAll(',', '.'));
                  if (price == null || price <= 0) {
                    return 'Geçerli bir fiyat girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Kategori
              Text(
                'Kategori',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(Constants.borderRadius),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'food',
                        child: Text('Yemekler'),
                      ),
                      DropdownMenuItem(
                        value: 'drinks',
                        child: Text('İçecekler'),
                      ),
                      DropdownMenuItem(
                        value: 'desserts',
                        child: Text('Tatlılar'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Resim URL
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Resim URL (İsteğe Bağlı)',
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              const SizedBox(height: 16),
              
              // Aktif/Pasif
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value ?? true;
                      });
                    },
                    activeColor: Constants.primaryColor,
                  ),
                  const Text('Aktif'),
                ],
              ),
              const SizedBox(height: 24),
              
              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(isEditMode ? 'Güncelle' : 'Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 