extends RigidBody3D

@onready var isik = $OmniLight3D
# Ses yolunu senin hiyerarşine göre güncelledim
@onready var ses = get_node("/root/Node3D/SesMerkezi/ThrowSound") 

func _ready():
	# Başlangıçta ışık kapalı olsun
	isik.hide()
	# Çarpışmayı izlemek için bu ayarları açmalısın
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# 1. Çarptığımız şeyin canı var mı? (Boss mu?)
	if body.has_method("hasar_al"):
		body.hasar_al(1) # Boss'un canını 1 düşür
		print("Boss'a vurdum! 🎯")
	
	# 2. Her durumda (duvara veya boss'a) çarptığı an patla!
	patlat()
	
func patlat():
	if isik.visible: return # Zaten patladıysa tekrar çalışma
	
	isik.show()
	if ses: ses.play() # Fırlatma/Çarpma sesini çal
	
	# Senin istediğin 1 saniyelik alan küçülmesi
	var tween = create_tween()
	isik.omni_range = 10.0 # Patlama anında geniş alan
	tween.tween_property(isik, "omni_range", 0.0, 1.0) # 1 saniyede 'fıçık' diye söner
	
	# Işık tamamen sönünce objeyi sil
	await tween.finished
	queue_free()
