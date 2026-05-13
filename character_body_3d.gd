extends CharacterBody3D

@export_group("Fırlatma Ayarları")
@export var SPEED = 5.0
@export var THROW_FORCE = 25.0
@export var GRAVITY_SCALE = 1.0
@export var COOLDOWN_TIME = 1.0667
@export var esya_sahnesi : PackedScene 

# --- MERMİ SİSTEMİ ---
@export_group("Mermi Ayarları")
@export var vazo_mermisi : int = 0  # Başlangıçta 0, topladıkça artacak
@onready var mermi_label = get_node_or_null("/root/Node3D/Arayuz/Control/MermiYazisi")

@onready var hayalet_label = get_node_or_null("/root/Node3D/Arayuz/Control/HayaletYazisi")
@export var bulunan_hayalet : int = 0

var boss_sahnesi = preload("res://boss.tscn")
var can_throw = true 
var boss_dogdu_mu : bool = false

@onready var anim_player = $Rogue_Hooded/AnimationPlayer
@onready var firlatma_sesi = get_node_or_null("/root/Node3D/SesMerkezi/ThrowSound") 

func _physics_process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Fırlatma animasyonu oynarken yürüme animasyonu girmesin
	var su_an_firlatiyor = anim_player.current_animation == "1H_Ranged_Shoot"

	if move_dir:
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
		$Rogue_Hooded.look_at(global_position - move_dir, Vector3.UP)
		
		if not su_an_firlatiyor and anim_player.current_animation != "Running_A":
			anim_player.play("Running_A")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if not su_an_firlatiyor and anim_player.current_animation != "Idle":
			anim_player.play("Idle")

	move_and_slide()

func _input(event):
	# Q tuşu veya fırlat aksiyonu kontrolü
	if (event.is_action_pressed("firlat") or (event is InputEventKey and event.pressed and event.keycode == KEY_Q)) and can_throw:
		# Önce mermi var mı diye bakıyoruz
		if vazo_mermisi > 0:
			throw_item()
		else:
			print("Mermin yok! Vazo parçalaman lazım.")

func throw_item():
	if not esya_sahnesi: return
	
	can_throw = false
	vazo_mermisi -= 1 # Mermiyi azalt
	arayuz_guncelle()
	
	anim_player.play("1H_Ranged_Shoot")
	
	var item = esya_sahnesi.instantiate()
	get_tree().root.add_child(item)
	
	# Modelin baktığı yönü referans al
	var firlatma_yonu = $Rogue_Hooded.global_transform.basis.z.normalized()
	item.global_position = global_position + (firlatma_yonu * 1.2) + Vector3(0, 1.2, 0)
	
	if item is RigidBody3D:
		item.gravity_scale = GRAVITY_SCALE
		var kuvvet = firlatma_yonu * THROW_FORCE + Vector3(0, 2, 0) 
		item.apply_central_impulse(kuvvet)
	
	if firlatma_sesi:
		firlatma_sesi.play()

	# Animasyon süresi kadar bekle
	await get_tree().create_timer(COOLDOWN_TIME).timeout
	can_throw = true
func _ready():
	# Oyun başlarken sayıyı yazdır
	arayuz_guncelle()

# Mermiyi ekranda gösteren yeni fonksiyon
func arayuz_guncelle():
	# 1. MERMİ / VAZO KONTROLÜ
	if mermi_label:
		mermi_label.text = "🏺=" + str(vazo_mermisi)
		if vazo_mermisi == 0:
			mermi_label.add_theme_color_override("font_color", Color.RED)
		else:
			mermi_label.add_theme_color_override("font_color", Color.WHITE)
			
	# 2. HAYALET VE BOSS DOĞUŞ KONTROLÜ
	if hayalet_label:
		hayalet_label.text = "👻 " + str(bulunan_hayalet) + "/5"
		
		if bulunan_hayalet >= 5 and boss_dogdu_mu == false:
			boss_dogdu_mu = true
			hayalet_label.add_theme_color_override("font_color", Color.GREEN)
			vazo_mermisi == 999999999
			
			# --- BOSS DOĞUŞ SEKANSI ---
			var yeni_boss = boss_sahnesi.instantiate()
			
			# Sahne ağacında en üstten başlayarak BossSpawn'ı arıyoruz
			var spawn_noktasi = get_node_or_null("/root/Node3D/BossSpawn") 
			# NOT: Eğer ana sahnenin adı "Node3D" ise yukarıyı "/root/Node3D/BossSpawn" yap
			
			if spawn_noktasi:
				yeni_boss.global_position = spawn_noktasi.global_position
				get_tree().current_scene.add_child(yeni_boss)
				print("Boss doğdu! Savaş başlasın.")
			else:
				print("HATA: BossSpawn bulunamadı! Lütfen sahne adını kontrol et.")
			
# --- ARAYÜZ DEĞİŞİMİ ---
			hayalet_label.visible = false 
			mermi_label.visible = false
			
			# Sahne ağacında en üstten (root) başlayarak tam yolu yazıyoruz:
			# Not: Eğer ana sahnenin adı 'Node3D' ise yol budur. 
			# Eğer ana sahnenin adı 'son' ise 'Node3D' yerine 'son' yaz.
			var arayuz_yolu = "/root/Node3D/Arayuz/Control/"
			
			var o_can = get_node_or_null(arayuz_yolu + "OyuncuCanLabel")
			var b_can = get_node_or_null(arayuz_yolu + "BossCanLabel")
			
			if o_can:
				o_can.visible = true
				o_can.text = "❤️ 3/3"
				print("Oyuncu canı açıldı!")
			else:
				# Eğer hala bulamazsa alternatif yolu deneyelim (find_child)
				o_can = get_tree().current_scene.find_child("OyuncuCanLabel", true, false)
				if o_can: o_can.visible = true

			if b_can:
				b_can.visible = true
				b_can.text = "💀 20/20"
				print("Boss canı açıldı!")
			else:
				b_can = get_tree().current_scene.find_child("BossCanLabel", true, false)
				if b_can: b_can.visible = true
