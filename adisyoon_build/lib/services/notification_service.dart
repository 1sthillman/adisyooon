import 'package:adisyoon/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _hasPermission = false;
  
  // Notification types
  static const String newOrder = 'new_order';               // Mutfağa yeni sipariş geldiğinde
  static const String orderReady = 'order_ready';           // Sipariş hazır olduğunda
  static const String orderDelivered = 'order_delivered';   // Sipariş teslim edildiğinde
  static const String tableCall = 'table_call';             // Masa çağrı yaptığında
  static const String paymentReceived = 'payment_received'; // Ödeme alındığında
  static const String tableOccupied = 'table_occupied';     // Masa boşken dolu olduğunda
  static const String sendToKitchen = 'send_to_kitchen';    // Sipariş mutfağa gönderildiğinde
  static const String sendToCashier = 'send_to_cashier';    // Masa kasaya gönderildiğinde
  
  // Sound paths - Her bildirim tipi için farklı ses dosyaları
  final Map<String, String> _soundPaths = {
    newOrder: 'assets/sounds/new_order.mp3',                 // Yeni sipariş sesi
    orderReady: 'assets/sounds/order_ready.mp3',             // Sipariş hazır sesi
    orderDelivered: 'assets/sounds/order_delivered.mp3',     // Sipariş teslim edildi sesi
    tableCall: 'assets/sounds/table_call.mp3',               // Masa çağrı sesi (özel ve dikkat çekici)
    paymentReceived: 'assets/sounds/payment_received.mp3',   // Ödeme alındı sesi
    tableOccupied: 'assets/sounds/table_occupied.mp3',       // Masa dolu sesi
    sendToKitchen: 'assets/sounds/send_to_kitchen.mp3',      // Mutfağa gönderme sesi
    sendToCashier: 'assets/sounds/send_to_cashier.mp3',      // Kasaya gönderme sesi
  };

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _requestPermissions();
    preloadSounds(); // Başlangıçta tüm sesleri yükle
  }
  
  // Ses dosyalarını önbelleğe alma
  Future<void> preloadSounds() async {
    try {
      debugPrint('Ses dosyaları önbelleğe alınıyor...');
      
      // Tüm ses tiplerini döngüye al ve önbelleğe yükle
      for (final type in _soundPaths.keys) {
        try {
          // Asset kaynağını yükle ve önbelleğe al
          final player = AudioPlayer();
          await player.setAsset(_soundPaths[type]!);
          debugPrint('Ses dosyası önbelleğe alındı: ${_soundPaths[type]}');
        } catch (e) {
          debugPrint('Ses dosyası önbelleğe alınamadı: ${_soundPaths[type]} - $e');
        }
      }
      
      debugPrint('Tüm ses dosyaları önbelleğe alındı.');
    } catch (e) {
      debugPrint('Ses dosyaları önbelleğe alınırken genel hata: $e');
    }
  }
  
  // Gerekli bildirimlerin iznini iste
  Future<void> _requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      _hasPermission = status.isGranted;
      
      if (!_hasPermission) {
        debugPrint('Bildirim izni reddedildi. Bildirimler gösterilemeyecek.');
        // Kullanıcıya izin vermesi için bir dialog gösterebiliriz
        _showPermissionDialog();
      }
    } catch (e) {
      debugPrint('İzin alınırken hata oluştu: $e');
    }
  }
  
  // İzin alma dialog'u göster
  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Bildirim İzni'),
        content: const Text(
          'Adisyoon uygulaması, sipariş bildirimleri ve ses uyarıları için bildirim iznine ihtiyaç duyar. '
          'Lütfen Ayarlar > Uygulamalar > Adisyoon > İzinler yolunu izleyerek bildirim iznini etkinleştirin.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Ayarları Aç'),
          ),
        ],
      ),
    );
  }

  // Show in-app notification
  void showNotification({
    required String title,
    required String message,
    String? type,
    bool playSound = true,
    bool vibrate = false,
    VoidCallback? onTap,
    SnackPosition position = SnackPosition.TOP,
  }) {
    // Play sound if needed
    if (playSound && type != null && _soundPaths.containsKey(type)) {
      _playSound(type);
    }
    
    // Titreşim ekle (özellikle garson için sipariş hazır bildiriminde)
    if (vibrate) {
      _vibrate();
    }
    
    // Show snackbar
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: _getBackgroundColor(type),
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 5),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      icon: _getIcon(type),
      onTap: onTap != null ? (_) => onTap() : null,
      mainButton: onTap != null 
          ? TextButton(
              onPressed: onTap,
              child: const Text(
                'Görüntüle',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
  
  // Titreşim
  void _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }
  
  // Play notification sound with just_audio
  Future<void> _playSound(String type) async {
    if (_soundPaths.containsKey(type)) {
      try {
        debugPrint('Ses dosyası çalınıyor: ${_soundPaths[type]}');
        
        // Mevcut ses çalmayı durdur
        await _audioPlayer.stop();
        
        // Ses dosyasının yolu
        final soundPath = _soundPaths[type]!;
        
        // Just_audio ile çalma
        try {
          // Asset kaynağını kullan
          await _audioPlayer.setAsset(soundPath);
          await _audioPlayer.setVolume(1.0);
          await _audioPlayer.play();
        } catch (e) {
          debugPrint('Just Audio ses çalma hatası: $e');
          // Alternatif çalma mekanizmasını dene
          _playFallbackSound(type);
        }
      } catch (e) {
        debugPrint('Ses dosyası çalınamadı: $e');
      }
    }
  }
  
  // Alternatif ses çalma mekanizması
  Future<void> _playFallbackSound(String type) async {
    try {
      // AudioPlayers kullanılabilir ancak burada just_audio kullanıyoruz
      final player = AudioPlayer();
      await player.setAsset(_soundPaths[type]!);
      await player.play();
    } catch (e) {
      debugPrint('Alternatif ses çalma da başarısız oldu: $e');
    }
  }
  
  // Test bildirim sesi - elle çağırmak için
  Future<void> testNotificationSound(String type) async {
    if (_soundPaths.containsKey(type)) {
      try {
        debugPrint('Test sesi çalınıyor: ${_soundPaths[type]}');
        await _playSound(type);
      } catch (e) {
        debugPrint('Test sesi çalınamadı: $e');
      }
    }
  }
  
  // Get background color based on notification type
  Color _getBackgroundColor(String? type) {
    switch (type) {
      case newOrder:
        return Constants.warningColor;
      case orderReady:
        return Constants.successColor;
      case orderDelivered:
        return Constants.primaryColor;
      case tableCall:
        return Constants.errorColor;
      case paymentReceived:
        return Constants.secondaryColor;
      case tableOccupied:
        return Constants.primaryColor;
      case sendToKitchen:
        return Constants.warningColor;
      case sendToCashier:
        return Constants.secondaryColor;
      default:
        return Colors.grey.shade800;
    }
  }
  
  // Get icon based on notification type
  Icon? _getIcon(String? type) {
    switch (type) {
      case newOrder:
        return const Icon(Icons.restaurant, color: Colors.white);
      case orderReady:
        return const Icon(Icons.check_circle, color: Colors.white);
      case orderDelivered:
        return const Icon(Icons.delivery_dining, color: Colors.white);
      case tableCall:
        return const Icon(Icons.support_agent, color: Colors.white);
      case paymentReceived:
        return const Icon(Icons.attach_money, color: Colors.white);
      case tableOccupied:
        return const Icon(Icons.event_seat, color: Colors.white);
      case sendToKitchen:
        return const Icon(Icons.kitchen, color: Colors.white);
      case sendToCashier:
        return const Icon(Icons.point_of_sale, color: Colors.white);
      default:
        return const Icon(Icons.notifications, color: Colors.white);
    }
  }
  
  // Sipariş bildirimi (masa -> mutfak)
  void notifyNewOrder(int tableId) {
    showNotification(
      title: 'Yeni Sipariş',
      message: 'Masa $tableId yeni sipariş verdi',
      type: newOrder,
      vibrate: false,
    );
  }
  
  // Sipariş hazır bildirimi (mutfak -> garson)
  void notifyOrderReady(int tableId) {
    showNotification(
      title: 'Sipariş Hazır',
      message: 'Masa $tableId siparişi hazır',
      type: orderReady,
      vibrate: true, // Garson için titreşim ekle
    );
  }
  
  // Masa çağrı bildirimi
  void notifyTableCall(int tableId) {
    showNotification(
      title: 'Masa Çağrısı',
      message: 'Masa $tableId garson çağırıyor',
      type: tableCall,
      vibrate: true, // Acil durum, titreşim ekle
    );
  }
  
  // Masa dolduğunda bildirim
  void notifyTableOccupied(int tableId) {
    showNotification(
      title: 'Masa Dolu',
      message: 'Masa $tableId şimdi dolu',
      type: tableOccupied,
    );
  }
  
  // Siparişi mutfağa gönderme bildirimi
  void notifySendToKitchen(int tableId) {
    showNotification(
      title: 'Sipariş Mutfağa Gönderildi',
      message: 'Masa $tableId siparişi mutfağa gönderildi',
      type: sendToKitchen,
    );
  }
  
  // Masayı kasaya gönderme bildirimi
  void notifySendToCashier(int tableId) {
    showNotification(
      title: 'Masa Kasaya Gönderildi',
      message: 'Masa $tableId ödeme için kasaya gönderildi',
      type: sendToCashier,
    );
  }
  
  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
} 