# Adisyoon Bildirim Sesleri

Bu klasör Adisyoon uygulamasının kullandığı bildirim seslerini içerir. Uygulamanın farklı durumları için özel olarak seçilmiş bildirim sesleri bulunmaktadır.

## Ses Dosyaları

1. `new_order.mp3` - Mutfağa yeni sipariş geldiğinde çalınacak ses
2. `order_ready.mp3` - Sipariş hazır olduğunda çalınacak ses
3. `order_delivered.mp3` - Sipariş teslim edildiğinde çalınacak ses
4. `table_call.mp3` - Masa çağrı yaptığında çalınacak ses (dikkat çekici)
5. `payment_received.mp3` - Ödeme alındığında çalınacak ses
6. `table_occupied.mp3` - Masa boşken dolu olduğunda çalınacak ses
7. `send_to_kitchen.mp3` - Sipariş mutfağa gönderildiğinde çalınacak ses
8. `send_to_cashier.mp3` - Masa kasaya gönderildiğinde çalınacak ses

## Ses Dosyalarını Değiştirme

Yukarıdaki ses dosyalarını, aynı dosya adlarını koruyarak kendi ses dosyalarınızla değiştirebilirsiniz. Dosyalar maksimum 5 saniye uzunluğunda olmalı ve MP3 formatında olmalıdır.

## Bildirim Türleri ve Kullanım Durumları

| Bildirim Türü | Çalma Durumu | Hedef Kullanıcı | Önem Seviyesi |
|---------------|--------------|-----------------|---------------|
| new_order | Mutfağa yeni sipariş geldiğinde | Mutfak çalışanları | Yüksek |
| order_ready | Sipariş hazırlandığında | Garsonlar | Yüksek + Titreşim |
| order_delivered | Sipariş masaya teslim edildiğinde | Garsonlar | Normal |
| table_call | Müşteri garson çağırdığında | Garsonlar | Çok Yüksek + Titreşim |
| payment_received | Ödeme işlemi tamamlandığında | Kasiyer | Normal |
| table_occupied | Boş masa dolu hale geldiğinde | Garsonlar | Düşük |
| send_to_kitchen | Sipariş mutfağa gönderildiğinde | Garsonlar, Mutfak | Normal |
| send_to_cashier | Masa ödeme için kasaya yönlendirildiğinde | Garsonlar, Kasiyer | Normal |

## Notlar

- Ses dosyaları 5 saniyeden kısa ve net olmalıdır
- Her ses farklı olmalı ve kolayca ayırt edilebilmelidir
- Özellikle çağrı sesi dikkat çekici olmalıdır
- Daha sessiz bir ortam için sesleri değiştirebilirsiniz

## Nasıl Çalışır?

Bildirim sesleri, NotificationService sınıfı tarafından yönetilir. Bu sınıf, uygulamanın farklı durumlarında uygun bildirimleri gösterir ve sesleri çalar. Ayrıca bazı bildirimlerde (örneğin acil çağrılarda) titreşim de kullanılır.

## Ses Dosyalarını Nereden Bulabilirsiniz?

Ücretsiz bildirim sesleri için şu kaynaklara bakabilirsiniz:

1. [Mixkit Free Sound Effects](https://mixkit.co/free-sound-effects/notification/)
2. [FreeSound](https://freesound.org/search/?q=notification)
3. [Orange Free Sounds](https://orangefreesounds.com/notification-sounds/)

## Önemli Not

Ses dosyalarının telif hakkı olan içerikler olmadığından emin olun ve ticari kullanım için uygun lisansa sahip olduklarını kontrol edin. 