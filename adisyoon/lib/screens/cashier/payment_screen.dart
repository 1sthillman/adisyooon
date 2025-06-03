import 'package:adisyoon/constants.dart';
import 'package:adisyoon/models/payment_model.dart';
import 'package:adisyoon/models/table_model.dart';
import 'package:adisyoon/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatefulWidget {
  final TableModel table;

  const PaymentScreen({super.key, required this.table});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _supabaseService = SupabaseService();
  final _amountController = TextEditingController();
  final _cashAmountController = TextEditingController();
  
  String _selectedPaymentMethod = 'Nakit';
  bool _isPartialPayment = false;
  bool _isSplitPayment = false;
  bool _isSaving = false;
  double _remainingAmount = 0;
  double _changeAmount = 0;
  
  List<Map<String, dynamic>> _splitPayments = [];

  @override
  void initState() {
    super.initState();
    
    // Toplam tutarı veya kalan tutarı ödeme kutucuğuna yerleştir
    if (widget.table.partialPayment == true && widget.table.lastPaymentAmount != null) {
      _remainingAmount = widget.table.total - widget.table.lastPaymentAmount!;
      _amountController.text = _remainingAmount.toStringAsFixed(2);
    } else {
      _amountController.text = widget.table.total.toStringAsFixed(2);
      _remainingAmount = widget.table.total;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _cashAmountController.dispose();
    super.dispose();
  }
  
  // Para üstünü hesapla
  void _calculateChange() {
    final cashAmount = double.tryParse(_cashAmountController.text.replaceAll(',', '.')) ?? 0.0;
    final paymentAmount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    
    setState(() {
      _changeAmount = cashAmount > paymentAmount ? cashAmount - paymentAmount : 0;
    });
  }
  
  // Bölünmüş ödeme ekle
  void _addSplitPayment() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    
    if (amount <= 0 || amount > _remainingAmount) {
      Get.snackbar(
        'Hata',
        'Geçerli bir tutar girin (0 ile $_remainingAmount arasında)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Constants.errorColor.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }
    
    setState(() {
      _splitPayments.add({
        'method': _selectedPaymentMethod,
        'amount': amount,
      });
      
      _remainingAmount -= amount;
      _amountController.text = _remainingAmount.toStringAsFixed(2);
    });
  }
  
  // Bölünmüş ödemeyi kaldır
  void _removeSplitPayment(int index) {
    setState(() {
      final removedPayment = _splitPayments.removeAt(index);
      _remainingAmount += removedPayment['amount'];
      _amountController.text = _remainingAmount.toStringAsFixed(2);
    });
  }

  Future<void> _processPayment() async {
    // Bölünmüş ödeme durumunda
    if (_isSplitPayment && _splitPayments.isEmpty) {
      Get.snackbar(
        'Hata',
        'Lütfen en az bir ödeme ekleyin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Constants.errorColor.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }
    
    // Normal ödeme durumunda
    if (!_isSplitPayment) {
      // Boş veya geçersiz tutar kontrolü
      if (_amountController.text.isEmpty) {
        Get.snackbar(
          'Hata',
          'Lütfen bir ödeme tutarı girin',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Constants.errorColor.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
      if (amount == null || amount <= 0) {
        Get.snackbar(
          'Hata',
          'Geçerli bir ödeme tutarı girin',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Constants.errorColor.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Tutar kalan tutardan büyük olamaz
      if (amount > _remainingAmount) {
        Get.snackbar(
          'Hata',
          'Ödeme tutarı kalan tutardan büyük olamaz',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Constants.errorColor.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isSplitPayment) {
        // Bölünmüş ödeme işlemi
        for (var payment in _splitPayments) {
          await _savePayment(payment['amount'], payment['method'], _remainingAmount <= 0);
        }
        
        // Kalan tutar varsa son durumu güncelle
        if (_remainingAmount > 0) {
          final updatedTable = widget.table.copyWith(
            status: Constants.statusPayment,
            partialPayment: true,
            lastPaymentMethod: _splitPayments.isNotEmpty ? _splitPayments.last['method'] : widget.table.lastPaymentMethod,
            lastPaymentAmount: (widget.table.lastPaymentAmount ?? 0) + _calculateTotalPaid(),
            lastPaymentTime: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _supabaseService.updateTable(updatedTable);
        }
      } else {
        // Normal ödeme işlemi
        final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
        final isFullPayment = amount >= _remainingAmount || !_isPartialPayment;
        
        await _savePayment(amount, _selectedPaymentMethod, isFullPayment);
      }

      setState(() {
        _isSaving = false;
      });

      Get.back();
      
      Get.snackbar(
        'Başarılı',
        _remainingAmount <= 0 ? 'Ödeme tamamlandı' : 'Kısmi ödeme alındı',
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
        'Ödeme işlemi sırasında bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Constants.errorColor.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }
  
  // Toplam ödenen tutarı hesapla
  double _calculateTotalPaid() {
    return _splitPayments.fold(0.0, (sum, payment) => sum + payment['amount']);
  }
  
  // Ödeme kaydetme
  Future<void> _savePayment(double amount, String method, bool isFullPayment) async {
    // Ödeme kaydı oluştur
    final paymentId = DateTime.now().millisecondsSinceEpoch;
    final payment = PaymentModel(
      id: paymentId,
      tableId: widget.table.id,
      order: widget.table.order,
      total: widget.table.total,
      paymentMethod: method,
      paymentTime: DateTime.now(),
      isPartial: !isFullPayment,
      partialAmount: !isFullPayment ? amount : null,
      remainingAmount: !isFullPayment ? _remainingAmount - amount : null,
    );

    // Ödemeyi kaydet
    await _supabaseService.savePayment(payment);

    // Masa durumunu güncelle
    final updatedTable = widget.table.copyWith(
      status: isFullPayment ? Constants.statusEmpty : widget.table.status,
      partialPayment: !isFullPayment,
      lastPaymentMethod: method,
      lastPaymentAmount: !isFullPayment 
          ? (widget.table.lastPaymentAmount ?? 0) + amount
          : widget.table.total,
      lastPaymentTime: DateTime.now(),
      order: isFullPayment ? [] : widget.table.order,
      note: isFullPayment ? '' : widget.table.note,
      total: isFullPayment ? 0 : widget.table.total,
      updatedAt: DateTime.now(),
    );

    await _supabaseService.updateTable(updatedTable);
  }

  @override
  Widget build(BuildContext context) {
    final hasPartialPayment = widget.table.partialPayment == true;
    
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        title: Text('Masa ${widget.table.id} Ödeme'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Constants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(Constants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sipariş Özeti',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.table.order.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = widget.table.order[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text('${item.quantity}x'),
                            const SizedBox(width: 8),
                            Text(
                              '₺${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(thickness: 1),
                    Row(
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
                          '₺${widget.table.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (hasPartialPayment && widget.table.lastPaymentAmount != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ödenen:'),
                          Text(
                            '₺${widget.table.lastPaymentAmount!.toStringAsFixed(2)}',
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
                            '₺${_remainingAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Constants.errorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Ödeme Modu Seçimi
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isSplitPayment = false;
                        // Kısmi ödeme kısmını resetle
                        if (widget.table.partialPayment == true && widget.table.lastPaymentAmount != null) {
                          _remainingAmount = widget.table.total - widget.table.lastPaymentAmount!;
                        } else {
                          _remainingAmount = widget.table.total;
                        }
                        _amountController.text = _remainingAmount.toStringAsFixed(2);
                        _splitPayments = [];
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isSplitPayment ? Constants.primaryColor : Colors.grey[300],
                      foregroundColor: !_isSplitPayment ? Colors.white : Colors.grey[700],
                    ),
                    child: const Text('Tek Ödeme'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isSplitPayment = true;
                        // Kısmi ödeme kısmını resetle
                        if (widget.table.partialPayment == true && widget.table.lastPaymentAmount != null) {
                          _remainingAmount = widget.table.total - widget.table.lastPaymentAmount!;
                        } else {
                          _remainingAmount = widget.table.total;
                        }
                        _amountController.text = _remainingAmount.toStringAsFixed(2);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSplitPayment ? Constants.primaryColor : Colors.grey[300],
                      foregroundColor: _isSplitPayment ? Colors.white : Colors.grey[700],
                    ),
                    child: const Text('Bölünmüş Ödeme'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Ödeme Bilgileri',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Tek Ödeme Modu
            if (!_isSplitPayment) ...[
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Ödeme Tutarı',
                  prefixText: '₺',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              Text(
                'Ödeme Yöntemi',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentMethodButton('Nakit', Icons.money),
                  const SizedBox(width: 8),
                  _buildPaymentMethodButton('Kredi Kartı', Icons.credit_card),
                  const SizedBox(width: 8),
                  _buildPaymentMethodButton('Havale/EFT', Icons.account_balance),
                ],
              ),
              
              // Nakit ödeme için para üstü hesaplama
              if (_selectedPaymentMethod == 'Nakit') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _cashAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Alınan Nakit Tutar',
                    prefixText: '₺',
                    hintText: 'Müşteriden alınan tutarı girin',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _calculateChange(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Para Üstü:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₺${_changeAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              if (!hasPartialPayment) ...[
                Row(
                  children: [
                    Checkbox(
                      value: _isPartialPayment,
                      onChanged: (value) {
                        setState(() {
                          _isPartialPayment = value ?? false;
                        });
                      },
                    ),
                    const Text('Kısmi Ödeme'),
                  ],
                ),
              ],
            ],
            
            // Bölünmüş Ödeme Modu
            if (_isSplitPayment) ...[
              // Bölünmüş ödemeler listesi
              if (_splitPayments.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Ödemeler',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _splitPayments.length,
                  itemBuilder: (context, index) {
                    final payment = _splitPayments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(payment['method']),
                        subtitle: Text('₺${payment['amount'].toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Constants.errorColor),
                          onPressed: () => _removeSplitPayment(index),
                        ),
                      ),
                    );
                  },
                ),
                
                // Toplam ödenen ve kalan
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Toplam Ödenen:'),
                    Text(
                      '₺${_calculateTotalPaid().toStringAsFixed(2)}',
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
                      '₺${_remainingAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _remainingAmount > 0 ? Constants.errorColor : Constants.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Kalan tutardan fazla ödeme alınamaz
              if (_remainingAmount > 0) ...[
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Ödeme Tutarı',
                    prefixText: '₺',
                    hintText: 'Maksimum: ₺${_remainingAmount.toStringAsFixed(2)}',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ödeme Yöntemi',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPaymentMethodButton('Nakit', Icons.money),
                    const SizedBox(width: 8),
                    _buildPaymentMethodButton('Kredi Kartı', Icons.credit_card),
                    const SizedBox(width: 8),
                    _buildPaymentMethodButton('Havale/EFT', Icons.account_balance),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addSplitPayment,
                    icon: const Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.secondaryColor,
                    ),
                    label: const Text('Ödeme Ekle'),
                  ),
                ),
              ],
            ],
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _processPayment,
                icon: const Icon(Icons.payment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                label: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _remainingAmount <= 0 || (!_isSplitPayment && !_isPartialPayment) 
                            ? 'Ödemeyi Tamamla'
                            : 'Kısmi Ödeme Al'
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(String method, IconData icon) {
    final isSelected = _selectedPaymentMethod == method;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Constants.secondaryColor : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(height: 4),
              Text(
                method,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 