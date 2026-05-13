extends CharacterBody3D

@export var speed: float = 1.5 
@export var stop_distance: float = 1.5 
@onready var anim = $Skeleton_Warrior/AnimationPlayer

var can = 20
var oldu_mu = false
var animasyon_suresi = 1.667 
var doguyor_mu = true # Boss'un şu an doğma aşamasında olduğunu kontrol eder
var dokunulmaz = false

func _ready():
	add_to_group("dusman")
	if anim:
		# 1. YUKARIDAN/YERDEN ÇIKMA ANİMASYONUNU BAŞLAT
		anim.play("Spawn_Ground_Skeletons")
		
		# 2. ANİMASYON BİTENE KADAR BEKLE
		# 'await' kullanarak animasyon bitene kadar aşağıdaki kodlara geçmiyoruz
		await anim.animation_finished
		
		# Animasyon bitti, artık yürüyebilir!
		doguyor_mu = false

func _physics_process(delta):
	if oldu_mu or doguyor_mu: return # Doğuyorsa veya öldüyse hiçbir şey yapma
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		var target_pos = player.global_position
		var distance = global_position.distance_to(target_pos)
		
		if distance > stop_distance:
			# YÜRÜME MANTIĞI
			var direction = (target_pos - global_position).normalized()
			direction.y = 0 
			velocity = direction * speed
			
			# YÜRÜME ANİMASYONU
			if anim:
				if anim.current_animation != "Walking_B":
					anim.play("Walking_B")
					anim.speed_scale = 1.0 / animasyon_suresi 
			
			# DOĞRU BAKMA
			var look_target = target_pos
			look_target.y = global_position.y
			if global_position.distance_to(look_target) > 0.1:
				look_at(look_target, Vector3.UP)
				rotate_y(PI) 
			
			move_and_slide()
		else:
			velocity = Vector3.ZERO
			# Durunca yürüme animasyonunu durdur (veya Idle oynat)
			if anim and anim.current_animation == "Walking_B":
				anim.stop()

func hasar_al(miktar):
	# Eğer ölüyse veya şu an dokunulmazsa (hasar yemişse) bir şey yapma
	if oldu_mu or dokunulmaz: return 
	
	can -= miktar
	dokunulmaz = true # Hasar aldı, artık bir süre dokunulmaz
	
	var boss_label = get_node_or_null("/root/Node3D/Arayuz/Control/BossCanLabel")
	if boss_label:
		boss_label.text = "💀 " + str(can) + "/20"
	
	# Hasar yeme animasyonu veya efekt ekleyebilirsin (Kırmızı parlama gibi)
	
	# 0.5 saniye bekle ve sonra tekrar hasar alabilir hale getir
	await get_tree().create_timer(0.5).timeout
	dokunulmaz = false
	
	if can <= 0:
		oldu_mu = true
		get_tree().change_scene_to_file("res://FinalSahnesi.tscn")
