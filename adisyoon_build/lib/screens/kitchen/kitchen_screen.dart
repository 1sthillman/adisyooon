import 'package:adisyoon/constants.dart';
import 'package:adisyoon/models/table_model.dart';
import 'package:adisyoon/screens/auth/login_screen.dart';
import 'package:adisyoon/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  final _supabaseService = SupabaseService();
  List<TableModel> _tables = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTables();
    _listenToTableChanges();
  }

  Future<void> _loadTables() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final tables = await _supabaseService.getTables();
      setState(() {
        _tables = tables.where((table) => 
          table.status == Constants.statusPreparing || 
          table.status == Constants.statusReady
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _listenToTableChanges() {
    _supabaseService.tablesStream.listen((tables) {
      setState(() {
        _tables = tables.where((table) => 
          table.status == Constants.statusPreparing || 
          table.status == Constants.statusReady
        ).toList();
      });
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rms_role');
    await prefs.remove('rms_username');
    Get.offAll(() => const LoginScreen());
  }

  Future<void> _markAsReady(TableModel table) async {
    try {
      final updatedTable = table.copyWith(
        status: Constants.statusReady,
        readyTime: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _supabaseService.updateTable(updatedTable);
      
      Get.snackbar(
        'Başarılı',
        'Sipariş hazır olarak işaretlendi',
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

  String _getOrderTime(TableModel table) {
    // Gerçek uygulamada bu, tablonun son güncelleme zamanını kullanabilir
    // Şimdi rastgele bir süre döndürüyoruz
    final random = DateTime.now().millisecondsSinceEpoch % 15;
    return '${random + 1} dk önce';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        title: const Text('Mutfak'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _tables.isEmpty
              ? const Center(
                  child: Text(
                    'Hazırlanacak sipariş bulunmuyor',
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
                    return _buildOrderCard(table);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.secondaryColor,
        onPressed: _loadTables,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildOrderCard(TableModel table) {
    final isReady = table.status == Constants.statusReady;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(Constants.defaultPadding),
            decoration: BoxDecoration(
              color: isReady ? Constants.successColor : Constants.warningColor,
              borderRadius: const BorderRadius.only(
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
                Text(
                  isReady ? 'Hazır' : 'Hazırlanıyor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
                      'Sipariş Detayları',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      _getOrderTime(table),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: table.order.length,
                  itemBuilder: (context, index) {
                    final item = table.order[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'x${item.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (table.note != null && table.note!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Not:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    table.note!,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (!isReady)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _markAsReady(table),
                      icon: const Icon(Icons.check),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.successColor,
                      ),
                      label: const Text('Hazır'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 