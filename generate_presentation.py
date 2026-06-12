import os
from fpdf import FPDF

class PresentationPDF(FPDF):
    def header(self):
        # Yalnızca kapak sayfası değilse üst bilgi ekle
        if self.page_no() > 1:
            self.set_font("Arial", 'B', 10)
            self.set_text_color(100, 100, 100)
            self.cell(0, 10, "İşaret Dili Çeviri ve İletişim Uygulaması Proje Sunumu", ln=True, align="R")
            self.ln(5)

    def footer(self):
        # Yalnızca kapak sayfası değilse alt bilgi ekle
        if self.page_no() > 1:
            self.set_y(-15)
            self.set_font("Arial", 'I', 8)
            self.set_text_color(128, 128, 128)
            self.cell(0, 10, f"Sayfa {self.page_no()}", align="C")

def create_presentation(output_path):
    pdf = PresentationPDF(orientation='L', unit='mm', format='A4')
    
    # Windows Arial fontunu ekle (Türkçe karakter desteği için)
    font_path = "C:/Windows/Fonts/arial.ttf"
    font_bold_path = "C:/Windows/Fonts/arialbd.ttf"
    
    if os.path.exists(font_path) and os.path.exists(font_bold_path):
        pdf.add_font("Arial", "", font_path)
        pdf.add_font("Arial", "B", font_bold_path)
    else:
        print("Uyarı: Arial fontu bulunamadı, varsayılan font kullanılacak. Türkçe karakterlerde sorun çıkabilir.")
    
    pdf.set_auto_page_break(auto=True, margin=15)
    
    # ================= SAYFA 1: KAPAK =================
    pdf.add_page()
    pdf.set_fill_color(37, 99, 235) # Mavi arkaplan
    pdf.rect(0, 0, 297, 210, 'F')
    
    pdf.set_text_color(255, 255, 255)
    pdf.ln(50)
    pdf.set_font("Arial", 'B', 36)
    pdf.cell(0, 20, "İŞARET DİLİ ÇEVİRİ VE İLETİŞİM UYGULAMASI", ln=True, align="C")
    
    pdf.ln(10)
    pdf.set_font("Arial", '', 20)
    pdf.cell(0, 15, "Yapay Zeka Destekli Erişilebilirlik Projesi", ln=True, align="C")
    
    pdf.ln(30)
    pdf.set_font("Arial", '', 14)
    pdf.cell(0, 10, "Proje Sunumu", ln=True, align="C")
    
    # ================= SAYFA 2: PROJENİN AMACI =================
    pdf.add_page()
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "1. Projenin Amacı ve Problemin Tanımı", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "Problem:\n\n"
        "• İşitme engelli bireyler ile işaret dili bilmeyen bireyler arasındaki iletişim kopukluğu.\n"
        "• Mevcut işaret dili çeviri sistemlerinin internet bağlantısı gerektirmesi veya yavaş çalışması.\n"
        "• Günlük hayatta hızlı ve karşılıklı iletişime izin veren pratik çözümlerin eksikliği.\n\n"
        "Amacımız:\n\n"
        "• Kamera aracılığıyla kullanıcının el hareketlerini anlık olarak metne çevirmek.\n"
        "• Tamamen cihaz üzerinde (çevrimdışı) ve çok yüksek hızda çalışan bir yapay zeka sunmak.\n"
        "• Karşılıklı iletişim modülü ile iki kişi arasındaki engelleri tamamen ortadan kaldırmak."
    )
    pdf.multi_cell(0, 10, text)
    
    # ================= SAYFA 3: ÇÖZÜMÜMÜZ =================
    pdf.add_page()
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "2. Çözüm Önerimiz ve Mimari", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "Geliştirdiğimiz mobil uygulama 3 ana temel üzerine kuruludur:\n\n"
        "1. Uçta Yapay Zeka (Edge AI): Veriler uzak bir sunucuya gitmez. Çeviri işlemi "
        "kullanıcının telefonunda yerel olarak milisaniyeler içinde gerçekleşir.\n\n"
        "2. Anlık Kamera İşleme: MediaPipe teknolojisi ile saniyede 30 kareye kadar el tespiti "
        "yapılır. Koordinatlar yapay zeka modeline beslenir.\n\n"
        "3. Güvenli Karşılıklı İletişim: Firebase altyapısı sayesinde hesap oluşturma ve "
        "kullanıcılar arası mesajlaşma/sinyalleşme işlemleri güvenle yürütülür."
    )
    pdf.multi_cell(0, 10, text)

    # ================= SAYFA 4: KULLANILAN TEKNOLOJİLER =================
    pdf.add_page()
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "3. Kullanılan Teknolojiler (Teknoloji Yığını)", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "• Frontend (Mobil Uygulama): Flutter & Dart\n"
        "   - Çapraz platform desteği ile hem Android hem iOS uyumluluğu.\n"
        "   - Zengin ve akıcı kullanıcı arayüzü.\n\n"
        "• Makine Öğrenimi (Makine Görüşü): Google MediaPipe (Hand Landmarker)\n"
        "   - Ellerden 3 boyutlu (x, y, z) 21 adet eklem noktasının (landmark) çıkarılması.\n\n"
        "• Derin Öğrenme Modeli: TensorFlow & Keras (Eğitim) -> TensorFlow Lite (Çıkarım)\n"
        "   - Özel mimari ile eğitilen ağın TFLite formatına dönüştürülüp mobil entegrasyonu.\n\n"
        "• Backend & Kimlik Doğrulama: Firebase Authentication & Cloud Firestore\n"
        "   - Kullanıcı yönetimi ve karşılıklı iletişim odaları yönetimi."
    )
    pdf.multi_cell(0, 10, text)

    # ================= SAYFA 5: VERİ HAZIRLIĞI =================
    pdf.add_page()
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "4. Yapay Zeka: Veri Toplama ve İşleme", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "Modelin başarılı olması için verinin doğru işlenmesi kritik bir aşamaydı:\n\n"
        "• İskelet Çıkarımı: Ham fotoğraflar yerine MediaPipe ile sadece el iskeletleri (21 nokta x 3 eksen) kullanıldı. "
        "Bu sayede model arka plan, ışık, ten rengi gibi etkenlerden bağımsızlaştı.\n\n"
        "• Normalizasyon (Ölçeklendirme): Elin kameraya uzaklığına bağlı olarak büyüklüğü değişir. "
        "Tüm koordinatlar bilek noktasına (0,0,0) göre merkeze alındı ve -1 ile +1 arasına ölçeklendi.\n\n"
        "• Veri Formatı: Her bir kare (frame) için sol el (63 değer) + sağ el (63 değer) olmak üzere toplam 126 özellikli (feature) bir vektör oluşturuldu."
    )
    pdf.multi_cell(0, 10, text)

    # ================= SAYFA 6: MODEL MİMARİSİ =================
    pdf.add_page()
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "5. Model Mimarisi: DNN (Derin Sinir Ağı)", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "Başlangıçta LSTM (Uzun Kısa Vadeli Bellek) ağları test edilmiş, ancak hız ve mobil cihaz "
        "kısıtlamaları nedeniyle çok daha çevik olan DNN (Dense Neural Network) mimarisine geçilmiştir.\n\n"
        "Model Yapısı:\n"
        "• Giriş Katmanı: 126 Düğüm (Anlık karedeki x,y,z koordinatları)\n"
        "• Gizli Katman 1: 256 Nöron (ReLU) + Batch Normalization + Dropout(%40)\n"
        "• Gizli Katman 2: 128 Nöron (ReLU) + Batch Normalization + Dropout(%30)\n"
        "• Gizli Katman 3: 64 Nöron (ReLU) + Batch Normalization + Dropout(%20)\n"
        "• Çıkış Katmanı: Sınıf sayısı kadar nöron (Softmax Aktivasyonu)\n\n"
        "Bu yapı sayesinde ezberleme (overfitting) engellenmiş ve anlık tahmin yeteneği maksimize edilmiştir."
    )
    pdf.multi_cell(0, 10, text)

    # ================= SAYFA 7: VERİ ARTIRIMI =================
    pdf.add_page()
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "6. Eğitim Stratejisi: Veri Artırımı (Data Augmentation)", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "Sınırlı veri setiyle yüksek başarı elde etmek için uyguladığımız özel taktik:\n\n"
        "Gürültü Ekleme (Noise Injection):\n"
        "Statik işaret fotoğraflarından elde edilen 126 koordinatın her biri, "
        "rastgele küçük matematiksel sapmalar (Gaussian Noise) ile 5 katına kadar çoğaltıldı.\n\n"
        "Bu sayede:\n"
        "1. Model, kullanıcının elinin biraz titremesini veya tam mükemmel açı yapamamasını tolere etmeyi öğrendi.\n"
        "2. Veri seti sanal olarak büyütüldü.\n"
        "3. Doğruluk (Accuracy) oranı %95'in üzerine çıkarıldı."
    )
    pdf.multi_cell(0, 10, text)

    # ================= SAYFA 8: OPTİMİZASYON =================
    pdf.add_page()
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "7. Model Optimizasyonu: TFLite ve Quantization", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "Yapay zeka modelini eğittikten sonra mobil telefona direkt koymak işlemciyi yorar. "
        "Bu yüzden iki aşamalı optimizasyon uygulandı:\n\n"
        "1. TensorFlow Lite (TFLite) Dönüşümü:\n"
        "Python'da eğitilen ağır Keras (.keras) modeli, mobil telefonların işlemcilerinde (Edge) "
        "çalışmaya uygun, hafifletilmiş (.tflite) formatına çevrildi.\n\n"
        "2. Int8 Quantization:\n"
        "Modelin içindeki ondalıklı ağırlıklar (Float32), temsil gücü yüksek 8-bit tam sayılara (Int8) yuvarlandı. "
        "Sonuç: Model boyutu yaklaşık 500 KB gibi devasa küçük bir boyuta indirildi, işlem hızı "
        "4 kat arttırıldı ve ısınma/kasma sorunu sıfıra indirildi."
    )
    pdf.multi_cell(0, 10, text)

    # ================= SAYFA 9: İŞARET ÇEVİRİ EKRANI =================
    pdf.add_page()
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "8. Uygulama: İşaret Çeviri Ekranı", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "Bu ekran uygulamanın kalbidir. Kullanıcı telefonunun ön veya arka kamerasını açar:\n\n"
        "• Saniyede ~30 kare fotoğraf çekilir, MediaPipe bunları yakalar.\n"
        "• Ekrandaki kasıntıyı (FPS düşüşünü) önlemek için tahmin işlemi (Throttle) sınırlandırıldı. "
        "Kamera tam hızda çalışırken, yapay zeka saniyede sadece 3 kez devreye girip sonucu günceller.\n"
        "• 'Harf Sabitleme' algoritması sayesinde, kullanıcı aynı harfte 0.8 saniye sabit kalırsa, "
        "harf otomatik olarak ekrandaki 'Tanınan Metin' cümlesine eklenir.\n"
        "• Boşluk (Space) ve Silme (Del) işaretleriyle klavye kullanmadan tam cümleler kurulabilir."
    )
    pdf.multi_cell(0, 10, text)

    # ================= SAYFA 10: ALGORİTMİK ÇÖZÜM =================
    pdf.add_page()
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "9. Karşılaşılan Zorluklar: Sağ/Sol El Aynalanma Problemi", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "Problem: Telefonun ön kamerası ayna (mirror) efekti yapar. Sağ elini kaldıran bir kullanıcıyı, "
        "model sol el olarak algılıyordu ve koordinatlar tersti, bu da güven oranını ve doğruluğu mahvediyordu.\n\n"
        "Çözüm (Çift Permütasyonlu Değerlendirme Algoritması):\n"
        "Modele 'Acaba bu sağ el mi?' diye karar vermek yerine, aynı anda iki ihtimali de sorduk:\n"
        "1. Modele sol ele aitmiş gibi sor (Permütasyon 1)\n"
        "2. Modele sağ ele aitmiş gibi sor (Permütasyon 2)\n\n"
        "Yapay zeka, yanlış ele beslenen veride çok düşük doğruluk (%5) üretirken, doğru el yerleşiminde "
        "(%99) doğruluk verdi. Kod arka planda bu ikisini çarpıştırıp her zaman yüksek olanı seçiyor! "
        "Bu sayede hata oranı sıfırlandı."
    )
    pdf.multi_cell(0, 10, text)

    # ================= SAYFA 11: KARŞILIKLI İLETİŞİM =================
    pdf.add_page()
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "10. Uygulama: Karşılıklı İletişim Ekranı", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "İşitme engelli bir birey ile işaret dili bilmeyen bir bireyin etkileşimi:\n\n"
        "• İletişim ekranında iki bölme bulunur.\n"
        "• Bir tarafta işaret dili kamerası aktiftir, kullanıcı işaret yaptıkça yazılı metne dönüşür.\n"
        "• Karşı taraf ise yazdıklarını veya söylediklerini (Sesten Metne) ekrana aktarabilir.\n"
        "• Firebase altyapısı ve Signaling Service ile bu iletişim uzaktaki iki cihaz arasında "
        "bir chat uygulaması kadar sorunsuz bir şekilde senkronize edilebilir."
    )
    pdf.multi_cell(0, 10, text)

    # ================= SAYFA 12: GELECEK PLANLARI =================
    pdf.add_page()
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "11. Gelecek Hedefleri ve Geliştirmeler", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "1. Dinamik İşaretlerin (Kelimelerin) Eklenmesi:\n"
        "Sadece statik harfler değil, zamana yayılan hareketli işaretlerin de (örn: Merhaba, Teşekkürler) "
        "Sequence LSTM mimarisi ile projeye dahil edilmesi.\n\n"
        "2. Çift Elli Karışık İşaretler:\n"
        "İki elin birbirine temas ettiği kompleks TİD (Türk İşaret Dili) işaretleri için model girişinin genişletilmesi.\n\n"
        "3. Metinden İşaret Diline (Avatar 3D):\n"
        "Yazılan metinlerin ekranda bir 3D karakter tarafından işaret diline çevrilmesi."
    )
    pdf.multi_cell(0, 10, text)

    # ================= SAYFA 13: SONUÇ =================
    pdf.add_page()
    pdf.set_font("Arial", 'B', 24)
    pdf.set_text_color(37, 99, 235)
    pdf.cell(0, 20, "12. Sonuç ve Katkılarımız", ln=True)
    pdf.line(10, 40, 287, 40)
    pdf.ln(10)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Arial", '', 16)
    text = (
        "Bu proje sayesinde:\n\n"
        "• Erişilebilirlik alanında yüksek teknolojili, yerli ve bağımsız bir çözüm üretildi.\n"
        "• Bulut maliyeti olmaksızın çalışan Edge AI (TFLite) sistemlerinin mobil cihazlardaki potansiyeli kanıtlandı.\n"
        "• Ayna efekti, FPS dalgalanması ve çift el optimizasyonu gibi karmaşık mühendislik "
        "problemlerine yaratıcı ve performans dostu algoritmalarla çözüm getirildi.\n\n"
        "Dinlediğiniz için teşekkürler."
    )
    pdf.multi_cell(0, 10, text)
    
    pdf.output(output_path)

if __name__ == '__main__':
    output_pdf = "C:/Users/isaca/OneDrive/Desktop/MobilProgramlama/Proje_Sunumu.pdf"
    create_presentation(output_pdf)
    print("PDF oluşturuldu:", output_pdf)
