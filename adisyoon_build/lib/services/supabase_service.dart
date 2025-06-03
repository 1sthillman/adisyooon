import 'dart:async';
import 'package:adisyoon/constants.dart';
import 'package:adisyoon/models/payment_model.dart';
import 'package:adisyoon/models/product_model.dart';
import 'package:adisyoon/models/table_model.dart';
import 'package:adisyoon/models/user_model.dart';
import 'package:adisyoon/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final _tablesStreamController = StreamController<List<TableModel>>.broadcast();
  final _productsStreamController = StreamController<List<ProductModel>>.broadcast();
  
  Stream<List<TableModel>> get tablesStream => _tablesStreamController.stream;
  Stream<List<ProductModel>> get productsStream => _productsStreamController.stream;
  
  StreamSubscription? _tablesSubscription;
  StreamSubscription? _productsSubscription;
  
  // Lokal veri önbelleği
  List<TableModel> _tables = [];
  List<ProductModel> _products = [];
  DateTime _lastUpdate = DateTime.now();
  
  // Bildirim servisi
  final _notificationService = NotificationService();

  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() {
    _initRealtimeSubscriptions();
  }

  void _initRealtimeSubscriptions() {
    try {
      // Demo için başlangıçta verileri yükle ve akışa ekle
      _loadInitialData();
      
      // Her 5 saniyede bir verileri güncelle (gerçek zamanlı simülasyonu)
      Timer.periodic(const Duration(seconds: 5), (_) {
        _checkForUpdates();
      });
    } catch (e) {
      // Hata durumunda da demo verileri ekle
      _tables = _createDemoTables();
      _products = _createDemoProducts();
      _notifyListeners();
    }
  }
  
  Future<void> _loadInitialData() async {
    _tables = _createDemoTables();
    _products = _createDemoProducts();
    _notifyListeners();
    
    // Başlangıçta tüm ses dosyalarını önbelleğe alarak hazırla
    _preloadSounds();
  }
  
  // Ses dosyalarını önceden yükle
  void _preloadSounds() {
    try {
      final notificationService = NotificationService();
      // Her bildirim türü için sesleri önceden yükle
      notificationService.preloadSounds();
    } catch (e) {
      debugPrint('Ses dosyaları önbelleğe alınamadı: $e');
    }
  }
  
  void _notifyListeners() {
    _tablesStreamController.add(_tables);
    _productsStreamController.add(_products);
  }
  
  void _checkForUpdates() {
    // Gerçek bir backend olsaydı, burada son güncelleme zamanından sonraki
    // değişiklikleri sorgulardık. Şimdi simüle ediyoruz.
    _lastUpdate = DateTime.now();
  }

  Future<UserModel?> login(String username, String password) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .single();
      
      return UserModel.fromJson(response);
          return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<TableModel>> getTables() async {
    try {
      // Gerçek uygulamada burası API'den veri çekerdi
      return _tables;
    } catch (e) {
      return _tables;
    }
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      // Gerçek uygulamada burası API'den veri çekerdi
      return _products;
    } catch (e) {
      return _products;
    }
  }

  Future<void> updateTable(TableModel table) async {
    try {
      // Gerçek uygulamada
      // await _client.from('tables').update(table.toJson()).eq('id', table.id);
      
      // Demo için yerel olarak güncelleme yap
      _updateLocalTable(table);
      
      // Bildirim gönder
      _sendTableUpdateNotification(table);
    } catch (e) {
      // Demo için yerel olarak güncelleme yap
      _updateLocalTable(table);
      
      // Bildirim gönder
      _sendTableUpdateNotification(table);
    }
  }

  void _updateLocalTable(TableModel updatedTable) {
    // Burada gerçek zamanlı değişikliği simüle ediyoruz
    final updatedIndex = _tables.indexWhere((t) => t.id == updatedTable.id);
    
    if (updatedIndex != -1) {
      // Eski durum kontrolü için mevcut tabloyu al
      final oldTable = _tables[updatedIndex];
      
      // Tabloyu güncelle
      _tables[updatedIndex] = updatedTable;
      
      // Eğer durum değiştiyse, ilgili bildirimi göster
      if (oldTable.status != updatedTable.status) {
        _sendTableStatusChangeNotification(oldTable, updatedTable);
      }
    } else {
      _tables.add(updatedTable);
    }
    
    // Stream'i güncelle
    _tablesStreamController.add(_tables);
  }
  
  // Masa durum değişikliği bildirimi
  void _sendTableStatusChangeNotification(TableModel oldTable, TableModel newTable) {
    try {
      final notificationService = NotificationService();
      final tableId = newTable.id;
      
      switch (newTable.status) {
        case Constants.statusOccupied:
          // Masa boşken dolu oldu
          if (oldTable.status == Constants.statusEmpty) {
            notificationService.notifyTableOccupied(tableId);
            
            // Test amaçlı ses dosyasını doğrudan çağır
            notificationService.testNotificationSound(NotificationService.tableOccupied);
          }
          break;
        
        case Constants.statusPreparing:
          // Sipariş mutfağa gönderildi
          notificationService.notifySendToKitchen(tableId);
          // Mutfağa da bildirim gönder
          notificationService.notifyNewOrder(tableId);
          
          // Test amaçlı ses dosyasını doğrudan çağır
          notificationService.testNotificationSound(NotificationService.sendToKitchen);
          break;
          
        case Constants.statusReady:
          // Sipariş hazır (Mutfak tarafından işaretlendi)
          notificationService.notifyOrderReady(tableId);
          
          // Test amaçlı ses dosyasını doğrudan çağır
          notificationService.testNotificationSound(NotificationService.orderReady);
          break;
          
        case Constants.statusCall:
          // Masa garson çağırdı
          notificationService.notifyTableCall(tableId);
          
          // Test amaçlı ses dosyasını doğrudan çağır
          notificationService.testNotificationSound(NotificationService.tableCall);
          break;
          
        case Constants.statusPayment:
          // Masa ödeme için kasaya gönderildi
          notificationService.notifySendToCashier(tableId);
          
          // Test amaçlı ses dosyasını doğrudan çağır
          notificationService.testNotificationSound(NotificationService.sendToCashier);
          break;
          
        default:
          break;
      }
    } catch (e) {
      // Bildirim gösteriminde bir hata olursa uygulamanın çalışmaya devam etmesini sağla
      debugPrint('Bildirim gösterilirken hata oluştu, fakat uygulama çalışmaya devam ediyor: $e');
    }
  }
  
  // Genel masa güncelleme bildirimi
  void _sendTableUpdateNotification(TableModel table) {
    // Buraya gelecek bildirimler özel durumlara göre ayarlanabilir
  }

  Future<void> savePayment(PaymentModel payment) async {
    try {
      // Gerçek uygulamada
      // await _client.from('payments').insert(payment.toJson());
      
      // Demo modunda bir şey yapmıyoruz, sadece tablo güncelleme
      // ile ödeme işlemini simüle ediyoruz
      
      // Ödeme bildirimi
      _notificationService.showNotification(
        title: 'Ödeme Alındı',
        message: 'Masa ${payment.tableId} için ödeme alındı',
        type: NotificationService.paymentReceived,
      );
      
      // Test amaçlı ses dosyasını doğrudan çağır
      _notificationService.testNotificationSound(NotificationService.paymentReceived);
    } catch (e) {
      // Demo modunda bir şey yapmıyoruz
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      // Gerçek uygulamada
      // await _client.from('products').insert(product.toJson());
      
      // Demo için yerel olarak ekleme yap
      _addLocalProduct(product);
    } catch (e) {
      // Demo için yerel olarak ekleme yap
      _addLocalProduct(product);
    }
  }
  
  void _addLocalProduct(ProductModel product) {
    // Yeni ürünü yerel listeye ekle
    _products.add(product);
    
    // Stream'i güncelle
    _productsStreamController.add(_products);
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      // Gerçek uygulamada
      // await _client.from('products').update(product.toJson()).eq('id', product.id);
      
      // Demo için yerel olarak güncelleme yap
      _updateLocalProduct(product);
    } catch (e) {
      // Demo için yerel olarak güncelleme yap
      _updateLocalProduct(product);
    }
  }
  
  void _updateLocalProduct(ProductModel updatedProduct) {
    // Ürünü yerel listede güncelle
    final updatedIndex = _products.indexWhere((p) => p.id == updatedProduct.id);
    
    if (updatedIndex != -1) {
      _products[updatedIndex] = updatedProduct;
    }
    
    // Stream'i güncelle
    _productsStreamController.add(_products);
  }

  // Demo veriler - 50 masa oluştur
  List<TableModel> _createDemoTables() {
    List<TableModel> tables = [];
    
    // 50 masa oluştur
    for (int i = 1; i <= 50; i++) {
      // Tüm masalar boş olarak başlasın, gerçek zamanlı olması için
      tables.add(TableModel(
        id: i,
        status: Constants.statusEmpty,
        order: [],
        total: 0,
      ));
    }
    
    return tables;
  }

  List<ProductModel> _createDemoProducts() {
    return [
      ProductModel(id: 1, name: 'Karışık Pizza', price: 120.0, category: 'food', active: true),
      ProductModel(id: 2, name: 'Margarita Pizza', price: 100.0, category: 'food', active: true),
      ProductModel(id: 3, name: 'Tavuk Şiş', price: 75.0, category: 'food', active: true),
      ProductModel(id: 4, name: 'Izgara Köfte', price: 85.0, category: 'food', active: true),
      ProductModel(id: 5, name: 'Adana Kebap', price: 90.0, category: 'food', active: true),
      ProductModel(id: 6, name: 'Lahmacun', price: 40.0, category: 'food', active: true),
      ProductModel(id: 7, name: 'Tavuk Döner', price: 55.0, category: 'food', active: true),
      ProductModel(id: 8, name: 'Pilav', price: 20.0, category: 'food', active: true),
      ProductModel(id: 9, name: 'Patates Kızartması', price: 35.0, category: 'food', active: true),
      ProductModel(id: 10, name: 'Salata', price: 30.0, category: 'food', active: true),
      
      ProductModel(id: 11, name: 'Kola', price: 15.0, category: 'drinks', active: true),
      ProductModel(id: 12, name: 'Fanta', price: 15.0, category: 'drinks', active: true),
      ProductModel(id: 13, name: 'Sprite', price: 15.0, category: 'drinks', active: true),
      ProductModel(id: 14, name: 'Su', price: 5.0, category: 'drinks', active: true),
      ProductModel(id: 15, name: 'Ayran', price: 10.0, category: 'drinks', active: true),
      ProductModel(id: 16, name: 'Çay', price: 8.0, category: 'drinks', active: true),
      ProductModel(id: 17, name: 'Türk Kahvesi', price: 20.0, category: 'drinks', active: true),
      
      ProductModel(id: 18, name: 'Künefe', price: 60.0, category: 'desserts', active: true),
      ProductModel(id: 19, name: 'Baklava', price: 70.0, category: 'desserts', active: true),
      ProductModel(id: 20, name: 'Dondurma', price: 25.0, category: 'desserts', active: true),
      ProductModel(id: 21, name: 'Sütlaç', price: 30.0, category: 'desserts', active: true),
      ProductModel(id: 22, name: 'Trileçe', price: 45.0, category: 'desserts', active: true),
    ];
  }

  void dispose() {
    _tablesStreamController.close();
    _productsStreamController.close();
    _tablesSubscription?.cancel();
    _productsSubscription?.cancel();
  }
} 