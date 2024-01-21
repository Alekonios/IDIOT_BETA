extends CharacterBody3D
const speed = 2.5

@export var purpose: Node3D
@onready var new_agent := $NavigationAgent3D  as NavigationAgent3D
@onready var animations = $AnimationPlayer
@onready var NavpointS = [$"../../../navigation/nav1", $"../../../navigation/nav2", $"../../../navigation/nav3", $"../../../navigation/nav4", $"../../../navigation/nav5", $"../../../navigation/nav6", $"../../../navigation/nav7", $"../../../navigation/nav8", $"../../../navigation/nav9", $"../../../navigation/nav10", $"../../../navigation/nav11"]
@onready var coliders = [$Armature/Skeleton3D/BoneAttachment3D/RayCast3D, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D2, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D3, $Armature/Skeleton3D/BoneAttachment3D/RayCast3D4]

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var the_path_is_set = false
var play_shagi = true
var signalization = false

var target = null

func _ready():
	_on_next_pos_timeout()
#передвижение {
func _physics_process(_delta: float):
	colide()
	if the_path_is_set:
		var dir = (new_agent.get_next_path_position() - global_position).normalized()
		velocity = dir * speed
		looked_at()
		move_and_slide()
		if dir:
			animations.play("walk1")
			#if play_shagi:
				#shagi_aud()
	else:
		animations.play("idle2")
#}	

#получение пути{
func make_path():
	new_agent.target_position = purpose.global_position
#}
#движение по маршруту{
func _process(_delta):
	if the_path_is_set:
		make_path()
#}w
	
#смотреть на путь{
func looked_at():
	var nextPosition = new_agent.get_next_path_position()
	if nextPosition!= Vector3.ZERO and the_path_is_set:  # Проверяем, что у нас есть следующая позиция пути
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

		
#func shagi_aud():
	#play_shagi = false
	#await get_tree().create_timer(0.6, false).timeout
	#play_shagi = true
	
func colide():
	for colider in coliders:
		if colider.is_colliding():
			if colider.get_collider().is_in_group("idiot"):
				target = colider.get_collider()
				target.notifications()
				print(target)
				signalization = true
