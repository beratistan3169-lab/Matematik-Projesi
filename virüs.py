import tkinter as tk
import random
import os
from PIL import Image, ImageTk

# --- 1. YENİ ÖZELLİK: HİKAYE DOSYASINI OLUŞTURMA ---
def hikaye_olustur():
    try:
        masaustu = os.path.join(os.path.expanduser("~"), "Desktop")
        dosya_yolu = os.path.join(masaustu, "kola.txt")
        
        icerik = """Kola
YAZAN: Ali Coşkun
Bugün çok güzel geçecek, inanıyorum. “Hayat bana artık meydan okuyamayacak” derken yerde bir kola buldum. İçsem mi? Neyse içeyim çünkü çok canım çekti. Vücuduma ne oluyor? O kolaya dönüşüyorum! Neden ben… Neden… Artık bir kolayım 
Neyse moral bozmak yok, bugün en mutlu günümdür. Bir dakika telefonumun üstünde neden bir “brainrot” birleşimi var? Ahh! Bu saçma çocuk şeylerine dokunmaktan nefret ediyorum. Al dokundum! Dur, ben telefonumun içindeyim. Sonunda biraz dinleneyim derken bir oyunun içinden çatışma sesleri gelir. Hemen oraya gittim. Cumhurbaşkanı seçiyorlardı ve Neel Bebeği cumhurbaşkanı seçtiler. Adı da L.C.
Neyse derken o! Beni gördü, bana doğru geliyor. “Dur alamaz” derken beni eline aldı ve beni bir binaya götürüyor. Neyce konuşuyor çok merak ettim. Binaya vardık. Oğlum kola küçük olduğu için beni beşiğe koydu. Oğlumm ben bundan büyüğümdür! Çok gıcığıma gitti. Bu çocuk cumhurbaşkanı niye seçildi heh! Neden seçtiniz bu bir ucube? N’olur kurtarın beni ahh!
Yanımda mekanik parçalar var, galiba kendime robot yapacağım. Yaptım ama beni gördüler. Hadi zorlasan çıkarsın hadiii! Oh çıktım, çok rahatladım. Şimdi robotumu alıp telefonu yok edecektim. Robota bindim, intikamımı alacaktım. Yeni başkanı buldum ve kendimi imha ettim."""

        with open(dosya_yolu, "w", encoding="utf-8") as f:
            f.write(icerik)
        print("Kola hikayesi masaüstüne sızdırıldı!")
    except Exception as e:
        print(f"Dosya oluşturulamadı: {e}")

# --- AYARLAR ---
RESIM_YOLU = os.path.expanduser("~\\Pictures") 

def resim_bul():
    valid_extensions = ('.jpg', '.jpeg', '.png', '.bmp')
    resimler = []
    for root_dir, dirs, files in os.walk(RESIM_YOLU):
        for file in files:
            if file.lower().endswith(valid_extensions):
                resimler.append(os.path.join(root_dir, file))
        if len(resimler) > 50: break 
    return resimler

tüm_resimler = resim_bul()

# --- 2. YENİ ÖZELLİK: EKRAN TİTREME (DEPREM) EFEKTİ ---
def deprem_efekti():
    # Ana paneli hafifçe sallar
    x = root.winfo_x()
    y = root.winfo_y()
    root.geometry(f"+{x + random.randint(-5, 5)}+{y + random.randint(-5, 5)}")
    
    # Arka planı "alarm" modunda değiştirir
    mevcut_renk = root.cget("bg")
    yeni_renk = "red" if mevcut_renk != "red" else "black"
    root.configure(bg=yeni_renk)
    
    root.after(100, deprem_efekti)

def virus_dongusu():
    pencere = tk.Toplevel()
    pencere.title("bloxycola")
    
    secim = random.choice(["yazi", "resim"])
    
    if secim == "resim" and tüm_resimler:
        try:
            rastgele_resim_yolu = random.choice(tüm_resimler)
            img = Image.open(rastgele_resim_yolu)
            img.thumbnail((250, 250)) 
            photo = ImageTk.PhotoImage(img)
            
            label = tk.Label(pencere, image=photo)
            label.image = photo 
            label.pack()
        except:
            secim = "yazi"

    if secim == "yazi":
        pencere.geometry("250x100")
        label = tk.Label(pencere, text="🥤 bloxycola ele geçirdi!", 
                         font=("Arial", 12, "bold"), fg="red")
        label.pack(expand=True)

    x = random.randint(0, root.winfo_screenwidth() - 250)
    y = random.randint(0, root.winfo_screenheight() - 250)
    pencere.geometry(f"+{x}+{y}")
    
    root.after(500, virus_dongusu)

def durdur():
    print("Sistem kurtarıldı!")
    root.destroy()

# --- ANA PANEL ---
root = tk.Tk()
root.title("KONTROL PANELİ")
root.geometry("350x150")

# Hikayeyi en başta oluştur
hikaye_olustur()

tk.Label(root, text="⚠ SİSTEM BLOXYCOLA TARAFINDAN ELE GEÇİRİLDİ ⚠", 
         fg="white", bg="black", font=("Arial", 10, "bold")).pack(pady=10)

tk.Button(root, text="DURDUR (BLOXYCOLA EXIT)", 
          command=durdur, bg="green", fg="white", font=("Arial", 10, "bold")).pack(pady=10)

# Efektleri başlat
root.after(1000, virus_dongusu)
root.after(500, deprem_efekti)

root.mainloop()
