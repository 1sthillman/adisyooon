### Adisyon Uygulaması Proje Tanımı (2000 Karakter)

**1. Tek Giriş Sistemi**  
- Tüm kullanıcılar (garson/mutfak/kasiyer) aynı ekrandan giriş yapar  
- Rol seçimi için dropdown menü  
- Şifreler:  
  - Garson: `garson1`  
  - Mutfak: `mutfak1`  
  - Kasiyer: `kasiyer1`  
- Kimlik doğrulama sonrası role özel panele yönlendirme  

**2. Garson Paneli**  
- **50 Masalı Izgara Sistemi**  
  - Boş: Gri  
  - Dolu: #FF9200 (Turuncu)  
  - Hazırlanıyor: Sarı  
  - Hazır: Yeşil  
  - Müşteri Çağrısı: Kırmızı  
- Masa Detay Ekranı:  
  - Yeni sipariş ekleme (mevcut siparişe ürün ekleyebilir)  
  - Not ekleme (mutfağa iletilir)  
  - "Siparişi Gönder" butonu  
  - "Teslim Aldım/Teslim Ettim" butonları  
  - QR çağrısı geldiğinde "Gidiyorum" butonu  

**3. Mutfak Paneli**  
- Gerçek zamanlı sipariş listesi:  
  - Masa numarası  
  - Ürün detayları (adet, özel notlar)  
  - "Hazırlandı" butonu (basınca garson panelinde masa yeşile döner)  
- Siparişler hazırlık durumuna göre sıralı  
- Görsel renk kodlaması: Hazırlanan siparişler sarı, hazır olanlar yeşil  

**4. Kasiyer Paneli**  
- **Aktif Masalar Listesi**  
  - Sadece ödeme bekleyen masalar gösterilir  
- Ödeme Sistemi:  
  - Nakit: Verilen para otomatik üst hesaplama  
  - Kredi Kartı: Tek tıkla işlem  
  - Bölünmüş Ödeme: Kısmi tutar girişi (örn. 250 TL nakit + 250 TL kart)  
- **Ürün Yönetimi**  
  - Yeni ürün ekleme (ad, fiyat, fotoğraf URL/dosya)  
  - Ürün aktif/pasif durumu (garson panelinde görünürlük kontrolü)  
  - Stok takibi olmadan temel CRUD işlemleri  

**5. QR Çağrı Sistemi**  
- Her masada özel QR kodu  
- Müşteri okuttuğunda:  
  - İlgili masa garson panelinde kırmızı yanar  
  - Garson "Gidiyorum" butonuna basınca renk normale döner  
- Bildirim sesli/renkli uyarı  

**6. İş Akış Özeti**  
1. Garson masayı "Dolu" yapar → Ürün/not ekler → "Gönder"e basar  
2. Mutfak siparişi görür → Hazırlayınca "Hazır" butonuna basar  
3. Garson teslim eder → Masayı "Ödeme Bekliyor" durumuna alır  
4. Kasiyer ödemeyi alır (nakit/kart/bölünmüş) → Masayı boşaltır  
5. Müşteri QR ile çağrı yaparsa → Garson yanıt verir  

**7. Özel Fonksiyonlar**  
- Garsonun eklediği ürünler mevcut siparişe entegre olur (yeni sipariş oluşmaz)  
- Mutfak notları gerçek zamanlı görür  
- Kasiyerin eklediği ürünler anında garson panelinde belirir  
- Tüm panellerde otomatik senkronizasyon  

**8. Renk Kodlu Durum Takibi**  
- Boş: Gri  
- Dolu (Sipariş alındı): #FF9200  
- Hazırlanıyor: Sarı  
- Hazır (Teslim almayı bekliyor): Yeşil  
- Ödeme Bekliyor: Mavi  
- Müşteri Çağrısı: Kırmızı  

**9. Güvenlik & Erişim**  
- Roller arası geçiş yok  
- Kritik işlemler (ödeme/ürün silme) onay gerektirir  
- Veriler şifreli iletilir  

**10. Kullanıcı Deneyimi**  
- Garson: Sürükle-bırak masa durumu değiştirme  
- Mutfak: Siparişleri hazırlama süresine göre sıralama  
- Kasiyer: Tek ekranda ödeme ve ürün yönetimi  

Bu yapı tüm iş akışlarını kapsar, renk kodlamasıyla görsel takip sağlar ve role özel optimize paneller sunar. Proje Firebase/Socket.IO ile gerçek zamanlı senkronizasyonu destekler.