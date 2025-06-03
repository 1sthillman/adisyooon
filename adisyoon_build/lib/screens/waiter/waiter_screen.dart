import 'package:adisyoon/constants.dart';
import 'package:adisyoon/models/table_model.dart';
import 'package:adisyoon/screens/auth/login_screen.dart';
import 'package:adisyoon/screens/waiter/table_detail_screen.dart';
import 'package:adisyoon/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaiterScreen extends StatefulWidget {
  const WaiterScreen({super.key});

  @override
  State<WaiterScreen> createState() => _WaiterScreenState();
}

class _WaiterScreenState extends State<WaiterScreen> {
  final _supabaseService = SupabaseService();
  List<TableModel> _tables = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTables();
    _listenToTableChanges();
  }

  @override
  void dispose() {
    super.dispose();
    _supabaseService.dispose();
  }

  Future<void> _loadTables() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final tables = await _supabaseService.getTables();
      setState(() {
        _tables = tables;
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
        _tables = tables;
      });
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rms_role');
    await prefs.remove('rms_username');
    Get.offAll(() => const LoginScreen());
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Constants.statusEmpty:
        return Colors.grey.shade300;
      case Constants.statusOccupied:
        return Constants.primaryColor;
      case Constants.statusPreparing:
        return Constants.warningColor;
      case Constants.statusReady:
        return Constants.successColor;
      case Constants.statusCall:
        return Constants.errorColor;
      case Constants.statusPayment:
        return Constants.secondaryColor;
      default:
        return Colors.grey.shade300;
    }
  }

  String _getStatusText(String status, TableModel table) {
    switch (status) {
      case Constants.statusEmpty:
        return 'Boş';
      case Constants.statusOccupied:
        return 'Dolu';
      case Constants.statusPreparing:
        return 'Hazırlanıyor';
      case Constants.statusReady:
        if (table.readyTime != null) {
          final readyMinutes = DateTime.now().difference(table.readyTime!).inMinutes;
          return 'Hazır ${readyMinutes}d';
        }
        return 'Hazır';
      case Constants.statusCall:
        return 'Çağrı';
      case Constants.statusPayment:
        return 'Ödeme';
      default:
        return 'Boş';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Masalar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Constants.primaryColor,
              ),
            )
          : Column(
              children: [
                _buildStatusLegend(),
                Expanded(
                  child: RefreshIndicator(
                    color: Constants.primaryColor,
                    onRefresh: _loadTables,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(Constants.defaultPadding),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
                        final table = _tables[index];
                        return _buildTableCard(table);
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.primaryColor,
        onPressed: _loadTables,
        elevation: 4,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStatusLegend() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem('Boş', Colors.grey.shade300),
          _buildLegendItem('Dolu', Constants.primaryColor),
          _buildLegendItem('Hazırlanıyor', Constants.warningColor),
          _buildLegendItem('Hazır', Constants.successColor),
          _buildLegendItem('Ödeme', Constants.secondaryColor),
          _buildLegendItem('Çağrı', Constants.errorColor),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(TableModel table) {
    final statusColor = _getStatusColor(table.status);
    final statusText = _getStatusText(table.status, table);

    return GestureDetector(
      onTap: () => Get.to(
        () => TableDetailScreen(tableId: table.id),
        transition: Transition.rightToLeft,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (table.partialPayment == true)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Kısmi Ödeme',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${table.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
} 