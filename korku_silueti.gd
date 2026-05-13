extends Area3D

# Bu silüetin bir kez çalışmasını garantiye alalım
var tetiklendi_mi = false

@onready var gulus_sesi = get_node_or_null("/root/Node3D/SesMerkezi/GulmeSesi") 

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Karakter girdi mi ve daha önce tetiklenmedi mi?
	if body is CharacterBody3D and not tetiklendi_mi:
		tetiklendi_mi = true
		
		# --- HAYALET SAYISINI ARTIRMA VE ARAYÜZÜ GÜNCELLEME ---
		# Karakterin içindeki 'bulunan_hayalet' değişkenini artırıyoruz
		if "bulunan_hayalet" in body:
			body.bulunan_hayalet += 1
			print("Hayalet toplandı! Toplam: ", body.bulunan_hayalet)
			
			# Karakterin içindeki arayüz fonksiyonunu tetikle
			if body.has_method("arayuz_guncelle"):
				body.arayuz_guncelle()
		
		korku_baslat()

func korku_baslat():
	print("DEHŞET VERİCİ GÜLÜŞ BAŞLADI! 👻")
	
	# 1. Gülüş sesini patlat
	if gulus_sesi:
		gulus_sesi.play()
	
	# 2. Silüeti kırmızı yap (Senin yaptığın o güzel kırmızı efekt gibi)
	var mesh = get_node_or_null("MeshInstance3D")
	
	# Önce mesh var mı, sonra materyal var mı diye bakıyoruz
	if mesh != null:
		if mesh.material_override != null:
			mesh.material_override.albedo_color = Color.RED
		else:
			# Materyal yoksa hata verme, sadece uyar
			print("Materyal bulunamadı, silüet rengi değişmiyor.")	
	# 3. Ses bitene kadar bekle ve sonra silüeti sahneden sil
	if gulus_sesi:
		await gulus_sesi.finished
	
	queue_free() 
	print("Korku silüeti yok oldu.")
