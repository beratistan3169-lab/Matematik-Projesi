extends Area3D

# BURADAKİ mermi_label satırını silebilirsin, çünkü 
# eşyanın kendisi arayüze dokunmayacak, karakter dokunacak.

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Eğer çarpan şey bizim karakterimizse
	if body is CharacterBody3D:
		# 1. Karakterin mermi sayısını artır
		body.vazo_mermisi += 1
		
		# 2. KARAKTERİN İÇİNDEKİ arayuz_guncelle fonksiyonunu çağır
		# Başına "body." koyduğumuza dikkat et!
		if body.has_method("arayuz_guncelle"):
			body.arayuz_guncelle()
		
		print("Parça alındı! Toplam: ", body.vazo_mermisi)
		
		# 3. RigidBody olan ana düğümü yok et
		get_parent().queue_free()
