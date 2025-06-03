Supabase ile gerçek zamanlı restoran adisyon sistemi kurmak için adım adım entegrasyon planı:

### 1. Supabase Proje Kurulumu
```bash
npm install @supabase/supabase-js
# veya Flutter için:
flutter pub add supabase_flutter
```

### 2. Tablo Yapıları (SQL)
```sql
-- Kullanıcılar
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('waiter', 'kitchen', 'cashier'))
);

-- Masalar
CREATE TABLE tables (
  id SERIAL PRIMARY KEY,
  number INT UNIQUE NOT NULL,
  status TEXT NOT NULL DEFAULT 'empty' CHECK (status IN ('empty', 'active', 'ready', 'calling')),
  current_order_id UUID REFERENCES orders(id)
);

-- Ürünler
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  category TEXT NOT NULL,
  is_available BOOLEAN NOT NULL DEFAULT true
);

-- Siparişler
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  table_id INT NOT NULL REFERENCES tables(id),
  items JSONB NOT NULL,
  notes TEXT,
  status TEXT NOT NULL DEFAULT 'preparing' CHECK (status IN ('preparing', 'ready', 'delivered')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Çağrılar
CREATE TABLE calls (
  id SERIAL PRIMARY KEY,
  table_id INT NOT NULL REFERENCES tables(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed BOOLEAN DEFAULT false
);
```

### 3. Gerçek Zamanlı Abonelikler (Flutter/Dart)
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Masaları dinle
final tablesStream = supabase
  .from('tables')
  .stream(primaryKey: ['id'])
  .order('number');

// Siparişleri dinle (mutfak için)
final ordersStream = supabase
  .from('orders')
  .stream(primaryKey: ['id'])
  .eq('status', 'preparing')
  .order('created_at', ascending: true);

// Çağrıları dinle (garson için)
final callsStream = supabase
  .from('calls')
  .stream(primaryKey: ['id'])
  .eq('completed', false);
```

### 4. Rol Bazlı Kimlik Doğrulama
```dart
Future<void> login(String username, String password) async {
  final response = await supabase
    .from('users')
    .select()
    .eq('username', username)
    .eq('password', password) // Şifreler hash'lenmeli!
    .single();

  if (response != null) {
    // Rolü localStorage'a kaydet
    await supabase.storage.from('user_settings').setItem(
      'current_role', 
      response['role']
    );
  }
}
```

### 5. QR Çağrı Sistemi Entegrasyonu
```dart
// QR oluştur
String generateQRData(int tableNumber) {
  return 'restocall:$tableNumber';
}

// QR okunduğunda
void onQRScanned(String data) async {
  if (data.startsWith('restocall:')) {
    final tableId = int.parse(data.split(':')[1]);
    await supabase.from('calls').insert({
      'table_id': tableId
    });
    
    // Masayı "calling" durumuna getir
    await supabase.from('tables').update({
      'status': 'calling'
    }).eq('id', tableId);
  }
}
```

### 6. Sesli Bildirim Sistemi
```dart
import 'package:audioplayers/audioplayers.dart';

final player = AudioPlayer();

void playSound(String eventType) async {
  String soundFile;
  switch(eventType) {
    case 'call':
      soundFile = 'sounds/call.mp3';
      break;
    case 'order':
      soundFile = 'sounds/new_order.mp3';
      break;
    case 'payment':
      soundFile = 'sounds/payment.mp3';
      break;
  }
  await player.play(AssetSource(soundFile));
}
```

### 7. Ödeme Hesaplama Mantığı
```dart
class PaymentCalculator {
  double total;
  double cashAmount = 0;
  double cardAmount = 0;

  PaymentCalculator(this.total);

  void setCash(double amount) {
    cashAmount = amount;
    cardAmount = total - cashAmount;
  }

  void setCard(double amount) {
    cardAmount = amount;
    cashAmount = total - cardAmount;
  }

  double get change {
    return cashAmount > total ? cashAmount - total : 0;
  }
}
```

### 8. Güvenlik Ayarları
1. Row Level Security (RLS) tüm tablolarda aktifleştir
2. .env dosyasına SUPABASE_URL ve SUPABASE_ANON_KEY ekle
3. Şifreleri bcrypt ile hash'le
4. JWT token süresi 1 saat ile sınırla

### 9. Performans Optimizasyonu
```sql
-- İndeksler
CREATE INDEX idx_table_status ON tables(status);
CREATE INDEX idx_order_status ON orders(status);
CREATE INDEX idx_products_available ON products(is_available);
```

### 10. Test Senaryoları
```bash
# Garson testi
curl -X POST https://yourapi.com/login -d '{"username":"garson1","password":"garson1"}'

# Mutfak bildirimi
curl -X POST https://yourapi.com/orders -d '{"table_id":5,"items":[...]}'

# Ödeme testi
curl -X POST https://yourapi.com/payments -d '{"order_id":"...","cash":100,"card":50}'
```

**Kritik Notlar:**
1. Tüm veri akışları `supabase.realtime` üzerinden
2. UI güncellemeleri StreamBuilder ile anlık
3. Ses dosyaları pubspec.yaml'da tanımlı olmalı
4. QR kütüphanesi: qr_flutter ve mobile_scanner
5. Her masa için QR kodu önceden generate edilmiş olmalı

Bu yapıyı kullanarak tüm bileşenler gerçek zamanlı senkronize çalışacak ve her rol sadece kendi işlevlerini görebilecektir.

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://crilryndqxtpnyrxfapo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyaWxyeW5kcXh0cG55cnhmYXBvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNzMyNjYsImV4cCI6MjA2Mzg0OTI2Nn0.vIsnVkTnTF2xJ0mU9dICylgouZLcmrzVWQuI6HqW1RU',
  );
  runApp(MyApp());
}
        
        
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Todos',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _future = Supabase.instance.client
      .from('todos')
      .select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final todos = snapshot.data!;
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: ((context, index) {
              final todo = todos[index];
              return ListTile(
                title: Text(todo['name']),
              );
            }),
          );
        },
      ),
    );
  }
}
