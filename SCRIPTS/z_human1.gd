extends CharacterBody3D
const speed = 2.5

@export var purpose: Node3D
@onready var new_agent := $NavigationAgent3D  as NavigationAgent3D
@onready var animations = $AnimationPlayer
@onready var shagi_sound = $shagi
@onready var znak = $znak
@export var navpoint_player := Node3D
@onready var collision = $CollisionShape3D
@onready var died_sound = $Armature/Skeleton3D/BoneAttachment3D/died_sound

@onready var sounds = [$Armature/Skeleton3D/BoneAttachment3D/gde, $Armature/Skeleton3D/BoneAttachment3D/ill, $Armature/Skeleton3D/BoneAttachment3D/uaa]
@export var NavpointS : Array[Node3D] = []
@onready var coliders = [$Armature/Skeleton3D/BoneAttachment3D/RayCast3D, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D5, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D6, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D8, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D9, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D10, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D11, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D12, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D13, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D7, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D2, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D3, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D4]

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var the_path_is_set = false
var play_shagi = true
var signalization = false
var died = false
var died_anim = false

var sec_bot = null
var target = null
var impulse = false

var push_force = 200

func _ready():
	random_sound()
	_on_next_pos_timeout()
#передвижение и цикличные процессы {
func _physics_process(_delta: float):
	if the_path_is_set and !died:
		var dir = (new_agent.get_next_path_position() - global_position).normalized()
		velocity = dir * speed
		looked_at()
		move_and_slide()
		if dir:
			animations.play("walk1")
			if play_shagi:
				shagi_aud()
	else:
		if !died:
			animations.play("idle2")
func _on_colide_timer_timeout():
	colide()
#}	
	

#получение пути{
func make_path():
	new_agent.target_position = purpose.global_position
#}
#движение по маршруту{
func _process(_delta):
	if the_path_is_set and !died:
		make_path()
#}w
	
#смотреть на путь{
func looked_at():
	var nextPosition = new_agent.get_next_path_position()
	if nextPosition!= Vector3.ZERO and the_path_is_set and !died:  # Проверяем, что у нас есть следующая позиция пути
		look_at(nextPosition)
#}

#получение рандомной ноды из списка{
func new_pos_point():
	randomize()  # инициализация генератора случайных чисел
	var randomIndex = randi() % NavpointS.size()
	var randomValue = NavpointS[randomIndex]
	purpose = randomValue
#}

#таймер обновления нового маршрута {
func _on_next_pos_timeout():
	var randomSec = randi() % 5
	var randomSec2 = 5 + randi() % 8
	await get_tree().create_timer(randomSec, false).timeout
	the_path_is_set = true
	new_pos_point()
	await get_tree().create_timer(randomSec2, false).timeout
	stop_path()
#}
	
func stop_path():
	the_path_is_set = false

		
func shagi_aud():
	play_shagi = false
	shagi_sound.play()
	await get_tree().create_timer(0.7, false).timeout
	play_shagi = true
	
func colide():
	if !died:
		for colider in coliders:
			if colider.is_colliding():
				if colider.get_collider().is_in_group("idiot"):
					target = colider.get_collider()
					target.notifications()
					navpoint_player.global_position = target.global_position
					signalization = true
					znak.show()
					sec_bot.new_pos_point()
					await get_tree().create_timer(6, false).timeout
					znak.hide()


func _on_load_hunters_body_entered(body):
		if body.is_in_group("SEC_BOT") and !died:
			sec_bot = body
			
func died_func():
	died = true
	collision.queue_free()
	died_anim_func()
	
func died_anim_func():
	if !died_anim:
		died_sound.play()
		animations.play("dye")
		died_anim = true

func random_sound():
	if !died:
		var random_number = randi() % 25 + 10
		var _random_number = randi() % 30 + 10
		var random_index = randi() % sounds.size()
		var _random_sound = sounds[random_index]
		await get_tree().create_timer(random_number, false).timeout
		_random_sound.play()
		await get_tree().create_timer(_random_number, false).timeout
		random_sound()


		
		
