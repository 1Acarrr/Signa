import os
from fpdf import FPDF
from fpdf.enums import XPos, YPos

class DetailedReportPDF(FPDF):
    def header(self):
        if self.page_no() > 1:
            self.set_font("Arial", 'B', 10)
            self.set_text_color(100, 100, 100)
            self.cell(0, 10, "Yapay Zeka Destekli İşaret Dili Çeviri Uygulaması - Detaylı Proje Raporu", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align="R")
            self.line(10, 20, 200, 20)
            self.set_y(25)

    def footer(self):
        if self.page_no() > 1:
            self.set_y(-15)
            self.set_font("Arial", 'I', 8)
            self.set_text_color(128, 128, 128)
            self.line(10, 282, 200, 282)
            self.cell(0, 10, f"Sayfa {self.page_no()}", align="C")

def create_detailed_report(output_path):
    pdf = DetailedReportPDF(orientation='P', unit='mm', format='A4')
    pdf.set_auto_page_break(auto=True, margin=20)
    
    font_path = "C:/Windows/Fonts/arial.ttf"
    font_bold_path = "C:/Windows/Fonts/arialbd.ttf"
    
    if os.path.exists(font_path) and os.path.exists(font_bold_path):
        pdf.add_font("Arial", "", font_path)
        pdf.add_font("Arial", "B", font_bold_path)
    else:
        print("Uyarı: Arial fontu bulunamadı.")
    
    # ================= SAYFA 1: KAPAK =================
    pdf.add_page()
    pdf.set_y(70)
    pdf.set_font("Arial", 'B', 26)
    pdf.set_text_color(0, 0, 0)
    pdf.multi_cell(0, 15, "YAPAY ZEKA DESTEKLİ İŞARET DİLİ ÇEVİRİ VE İLETİŞİM UYGULAMASI", align="C")
    
    pdf.ln(20)
    pdf.set_font("Arial", 'B', 16)
    pdf.cell(0, 10, "KAPSAMLI PROJE VE TEKNİK MİMARİ RAPORU", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align="C")
    
    pdf.ln(60)
    pdf.set_font("Arial", '', 14)
    pdf.cell(0, 10, "Haziran 2026", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align="C")
    
    def add_chapter(title, text):
        pdf.add_page()
        pdf.set_font("Arial", 'B', 18)
        pdf.set_text_color(0, 0, 0)
        pdf.cell(0, 12, title, new_x=XPos.LMARGIN, new_y=YPos.NEXT)
        pdf.line(10, pdf.get_y(), 200, pdf.get_y())
        pdf.ln(8)
        pdf.set_font("Arial", '', 12)
        pdf.multi_cell(0, 7, text)
        
    def add_subchapter(title, text):
        pdf.ln(6)
        pdf.set_font("Arial", 'B', 14)
        pdf.cell(0, 10, title, new_x=XPos.LMARGIN, new_y=YPos.NEXT)
        pdf.set_font("Arial", '', 12)
        pdf.multi_cell(0, 7, text)

    # 1. GİRİŞ
    c1 = "1. GİRİŞ VE PROJENİN KAPSAMI"
    c1_txt = (
        "İşitme engelli bireylerin toplumla iletişim kurarken karşılaştıkları en büyük engel, işaret dilinin geniş kitleler tarafından bilinmemesidir. "
        "Bu proje, sadece bir 'çeviri' uygulaması değil; aynı zamanda eğitim, yazıya dökme ve uçtan uca (p2p) iletişim aracı olarak tasarlanmış devasa bir erişilebilirlik ekosistemidir.\n\n"
        "Flutter framework'ü kullanılarak geliştirilen bu uygulama, 'Provider' mimarisi ile state (durum) yönetimini sağlarken, sayfa geçişleri (routing) için 'GoRouter' kütüphanesini kullanmaktadır. "
        "Arka planda (Backend) ise güvenlik ve veritabanı yönetimi tamamen Firebase üzerine inşa edilmiştir."
    )
    add_chapter(c1, c1_txt)

    # 2. GİRİŞ VE KAYIT EKRANLARI
    c2 = "2. KULLANICI YÖNETİMİ: GİRİŞ VE KAYIT EKRANLARI"
    c2_txt = (
        "Uygulamaya giriş yapacak kullanıcıların yetkilendirmesi, güvenlik açıklarını önlemek adına Google tarafından sağlanan 'firebase_auth' paketi ile gerçekleştirilmektedir."
    )
    add_chapter(c2, c2_txt)
    add_subchapter("A. Giriş ve Kayıt Ol (Authentication)", 
                   "Kullanıcı, e-posta ve şifre ile sisteme kayıt olur veya giriş yapar. Şifreler doğrudan Firebase bulut sunucularında hash'lenerek (şifrelenerek) güvenle saklanır. "
                   "Giriş esnasında yaşanabilecek 'Hatalı Şifre' veya 'Kullanıcı Bulunamadı' gibi istisnai durumlar (exceptions) try-catch bloklarıyla yakalanarak kullanıcıya anlaşılır toast/snackbar mesajları ile anında bildirilir.")
    add_subchapter("B. Firestore Profil Yönetimi", 
                   "Sisteme başarıyla kayıt olan her kullanıcı için 'cloud_firestore' NoSQL veritabanında özel bir 'users' dokümanı oluşturulur. "
                   "Bu dokümanda kişinin adı, alıştırma puanları, profil fotoğrafı linki (firebase_storage destekli) ve hesap tercihleri tutulur. Bu yapı 'AuthProvider' servisi aracılığıyla uygulamanın her sayfasına global olarak dağıtılır.")

    # 3. ANASAYFA VE İŞARET ÇEVİRİ SAYFASI
    c3 = "3. ANASAYFA VE YAPAY ZEKA ÇEVİRİ SAYFASI"
    c3_txt = (
        "Kullanıcı giriş yaptıktan sonra zengin bir arayüze sahip 'Anasayfa' (Dashboard) ekranına yönlendirilir. "
        "Bu ekranda uygulamayı simgeleyen göz alıcı bir 'İşareti Çevir' butonu ve altında farklı işlevlere yönlendiren modüller (Hızlı Erişim) bulunur."
    )
    add_chapter(c3, c3_txt)
    add_subchapter("A. İşareti Çevir (Sign Translation Screen)", 
                   "Uygulamanın temelini oluşturan ana sayfa burasıdır. Arka planda 3 adet büyük kütüphane birbiriyle senkronize çalışır:\n"
                   "- 'camera' paketi: Cihazın kamerasını saniyede 30 kare (30 FPS) hızında yakalar.\n"
                   "- 'hand_landmarker' paketi: Kameradan gelen görüntülerdeki eli anlık tespit edip 21 farklı eklem noktasının (x,y,z) koordinatlarını çıkarır.\n"
                   "- 'tflite_flutter' paketi: Google'ın TFLite makine öğrenimi motorunu çalıştırır. Çıkarılan koordinatlar (Normalizasyon işleminden geçtikten sonra), saniyenin onda biri hızında eğitilmiş DNN (Dense Neural Network) modeline beslenir ve anında harfe/kelimeye çevrilir.\n\n"
                   "Optimizasyon: Cihazın ısınmasını ve donmasını önlemek adına kamera tam hızında çalışırken, yapay zekanın tahmin işlemi 'Throttle' metodu ile saniyede 3-4 defa ile sınırlandırılmıştır. Ayrıca Ön Kamera Ayna (Mirror) efektinden kaynaklanan sağ/sol el kargaşası, model içinde her iki ihtimalin aynı anda test edildiği yenilikçi 'Çift Permütasyon Algoritması' ile kusursuz şekilde çözülmüştür.")

    # 4. HIZLI ERİŞİM: KONUŞMAYI YAZIYA ÇEVİR
    c4 = "4. KONUŞMAYI YAZIYA ÇEVİR EKRANI (Speech-to-Text)"
    c4_txt = (
        "Bu sayfa özel olarak işitme engelli bireylerin, işaret dili bilmeyen kişilerle günlük yaşamlarındaki iletişimini hızlandırmak ve engelleri kaldırmak adına tasarlanmıştır."
    )
    add_chapter(c4, c4_txt)
    add_subchapter("A. Kullanılan Kütüphane ve Yapı", 
                   "Sayfanın kalbinde 'speech_to_text' kütüphanesi yer almaktadır. İşitme engelli birey bu sayfayı açıp, mikrofon tuşuna basarak telefonu karşısındaki kişiye yöneltir. "
                   "Kütüphane, cihaz donanımının sağladığı yerleşik (native) STT motorlarını kullanarak karşı tarafın söylediklerini dinler ve bu sesleri anlık (streaming) olarak metne döker.")
    add_subchapter("B. Arayüz Tasarımı", 
                   "Görüntülenen metin, işitme engelli kullanıcının okumasını kolaylaştırmak adına oldukça büyük, dinamik puntolarla ve yüksek kontrastlı bir tasarımla ekrana basılır. "
                   "Bu özellik internet üzerinden çalıştığı için doğruluk oranı oldukça yüksektir.")

    # 5. HIZLI ERİŞİM: KARŞILIKLI İLETİŞİM (WebRTC)
    c5 = "5. KARŞILIKLI İLETİŞİM EKRANI (P2P WebRTC)"
    c5_txt = (
        "Uygulamanın mühendislik açısından en karmaşık, öte yandan toplumsal etkisi en güçlü modülüdür. Uzaktaki veya aynı odadaki iki kişinin (biri işaret dili kullanan, diğeri konuşan/yazan) eşzamanlı iletişim kurmasını sağlar."
    )
    add_chapter(c5, c5_txt)
    add_subchapter("A. Kullanılan Kütüphane: flutter_webrtc", 
                   "Görüntülü görüşme uygulamalarının (Zoom, WhatsApp vb.) altyapısında yatan WebRTC teknolojisi projeye 'flutter_webrtc' kütüphanesi ile entegre edilmiştir. "
                   "Bu sayede iki cihaz arasında yüksek hızlı P2P (Peer-to-Peer) bir görüntü ve ses tüneli açılır.")
    add_subchapter("B. Signaling Service (Sinyalleşme)", 
                   "WebRTC ile iki cihazın birbirini bulabilmesi için bir 'Sinyalleşme Sunucusuna' ihtiyaç vardır. Projede ayrı bir sunucu kiralama maliyetinden kaçınılarak, bu sistem doğrudan 'cloud_firestore' üzerine kurulmuştur. "
                   "Cihazlar SDP (Session Description Protocol) ve ICE Candidates bağlantı bilgilerini Firestore 'rooms' (odalar) koleksiyonu üzerinden eşzamanlı olarak birbirlerine iletir ve ardından doğrudan video/veri kanalı kurulur. "
                   "Ekranda bir taraftan işaret yaparken öteki taraf metni okuyabilir, aynı anda sesini veya klavye sistemini kullanarak hızlıca yanıt verebilir.")

    # 6. EĞİTİM VE ALIŞTIRMA MODÜLLERİ
    c6 = "6. EĞİTİM: İŞARETLERİ ÖĞREN VE ALIŞTIRMA YAP"
    c6_txt = (
        "Bu iki sayfa uygulamanın eğitim merkezidir. Amaç yalnızca çeviri yapmak değil, aynı zamanda toplumun bu dili kolayca öğrenmesini ve pekiştirmesini sağlamaktır."
    )
    add_chapter(c6, c6_txt)
    add_subchapter("A. İşaretleri Öğren (Learn Signs)", 
                   "İşaret dilindeki harfler, sayılar, temel eylemler (fiiller), kişiler ve günlük ihtiyaçlara göre kategorilendirilmiş bir görsel sözlüğe sahiptir. "
                   "Her işaret, statik bir fotoğraf yerine 'gif' kütüphanesi desteğiyle hareketli olarak kullanıcıya gösterilir, böylece kullanıcı hareketin yapılış yönünü ve şeklini tam olarak anlayabilir.")
    add_subchapter("B. Alıştırma Yap (Practice Mode)", 
                   "Kullanıcı öğrendiği işaretleri cihaz kamerasını kullanarak test edebilir. Sistem ekrana rastgele bir harf veya kelime basar ve geri sayım başlar. "
                   "Arka planda yine TFLite motoru devreye girer. Kullanıcı doğru işareti kameraya gösterirse harf yeşile döner ve kullanıcıya Firestore üzerinden profil puanları eklenerek oyunlaştırma (Gamification) sistemi işletilir.")

    # 7. PROFİL VE AYARLAR
    c7 = "7. ALT NAVİGASYON: PROFİL VE AYARLAR"
    c7_txt = (
        "GoRouter ile sayfa yapısı uygulamanın en altındaki gezinme çubuğuna (BottomNavigationBar) bağlanmıştır. Buradan geçiş yapılan Profil ve Ayarlar sayfaları uygulamanın kişiselleştirme merkezleridir."
    )
    add_chapter(c7, c7_txt)
    add_subchapter("A. Profil Sayfası", 
                   "Firestore'dan gerçek zamanlı (snapshot) çekilen kullanıcı istatistikleri, başarı oranları ve alıştırma modunda kazanılan puanlar bu sayfada görselleştirilir. "
                   "Profil fotoğrafı 'firebase_storage' servisi ile buluta yüklenip anında güncellenebilmektedir.")
    add_subchapter("B. Ayarlar Sayfası", 
                   "Uygulamanın genel teması (Karanlık Mod / Aydınlık Mod), bildirim ayarları ve oturumu kapatma/hesap silme gibi Firebase fonksiyonları bu sayfada yer alır. "
                   "Karanlık mod ve dil tercihleri, 'shared_preferences' paketi kullanılarak cihazın yerel depolamasında (local storage) tutulur; böylece uygulama her açılışında kullanıcının kendi seçtiği renk tonuyla başlatılır.")
    
    # 8. SONUÇ
    c8 = "8. SONUÇ DEĞERLENDİRMESİ"
    c8_txt = (
        "Sonuç olarak bu proje; WebRTC destekli ileri düzey ağ mimarisi, uçta yapay zekayı mobil kamerayla buluşturan Çift Permütasyon algoritmali TFLite motoru ve "
        "gerçek zamanlı Firestore veritabanı altyapısıyla oluşturulmuş inanılmaz kapsamlı bir mühendislik eseridir.\n\n"
        "Konuşmayı yazıya çevirmekten (Speech-to-text) karşılıklı sohbete ve işaret dili eğitim modülüne kadar, bir uygulamada bulunması gereken tüm erişilebilirlik standartları en son teknoloji "
        "(Flutter, Firebase, MediaPipe) ile olağanüstü bir başarıyla harmanlanmıştır."
    )
    add_chapter(c8, c8_txt)
    
    pdf.output(output_path)

if __name__ == '__main__':
    output_pdf = "C:/Users/isaca/OneDrive/Desktop/MobilProgramlama/Proje_Raporu_Detayli.pdf"
    create_detailed_report(output_pdf)
    print("Mimarisi Detaylandirilmis Turkce PDF Rapor olusturuldu:", output_pdf)
