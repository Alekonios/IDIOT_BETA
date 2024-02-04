extends CharacterBody3D
const speed = 2.5


@onready var new_agent := $NavigationAgent3D as NavigationAgent3D
@onready var animations = $AnimationPlayer
@onready var animations2 = $orig_anim
@onready var coliders = [$Armature/Skeleton3D/head/RayCast3D, $Armature/Skeleton3D/head/RayCast3D2, $Armature/Skeleton3D/head/RayCast3D3, $Armature/Skeleton3D/head/RayCast3D4, $Armature/Skeleton3D/head/RayCast3D5, $Armature/Skeleton3D/head/RayCast3D6, $Armature/Skeleton3D/head/RayCast3D22, $Armature/Skeleton3D/head/RayCast3D23, $Armature/Skeleton3D/head/RayCast3D24, $Armature/Skeleton3D/head/RayCast3D7, $Armature/Skeleton3D/head/RayCast3D8, $Armature/Skeleton3D/head/RayCast3D9, $Armature/Skeleton3D/head/RayCast3D25, $Armature/Skeleton3D/head/RayCast3D26, $Armature/Skeleton3D/head/RayCast3D27, $Armature/Skeleton3D/head/RayCast3D10, $Armature/Skeleton3D/head/RayCast3D11, $Armature/Skeleton3D/head/RayCast3D12, $Armature/Skeleton3D/head/RayCast3D13, $Armature/Skeleton3D/head/RayCast3D14, $Armature/Skeleton3D/head/RayCast3D15, $Armature/Skeleton3D/head/RayCast3D16, $Armature/Skeleton3D/head/RayCast3D17, $Armature/Skeleton3D/head/RayCast3D18, $Armature/Skeleton3D/head/RayCast3D19, $Armature/Skeleton3D/head/RayCast3D20, $Armature/Skeleton3D/head/RayCast3D21]
@onready var shagi_sound = $shagi
@onready var shoot_colider =  $RayCast3D
@onready var bullets_nodes = [$bullets_nodes/bullet_node, $bullets_nodes/bullet_node2, $bullets_nodes/bullet_node3, $bullets_nodes/bullet_node4, $bullets_nodes/bullet_node5]
@onready var sound_blast_shoot = $blast_shoot

@export var purpose: Node3D
@export var Navpoint := Node3D
@export var ramka_nav_point := Node3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var bullet_load_scene = preload("res://ASSETS/weapons/bullet.tscn")

var the_path_is_set = false
var play_shagi = true
var signalization = false
var walk_and_Shoot = false
var shooting = false
var notifications = false
var go_back = false

var health = 100


var target = null

#передвижение и цикличные процессы {
func _physics_process(_delta: float):
	if the_path_is_set:
		var dir = (new_agent.get_next_path_position() - global_position).normalized()
		velocity = dir * speed
		looked_at()
		move_and_slide()
		if dir:
			if !walk_and_Shoot:
				animations.play("walk")
				if play_shagi:
					shagi_aud()
			else:
				animations.play("go_and_shoot4")
				if play_shagi:
					shagi_aud()
	else:
		animations.play("idle")
func _on_colide_timer_timeout():
	colide()
	shoot_colide()
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

#получение новой позиции{
func new_pos_point():
	purpose.global_position = Navpoint.global_position
	the_path_is_set = true
#}
	
func stop_path():
	the_path_is_set = false

		
func shagi_aud():
	play_shagi = false
	shagi_sound.play()
	await get_tree().create_timer(0.65, false).timeout
	play_shagi = true
	
func colide():
	for colider in coliders:
		if colider.is_colliding() and !walk_and_Shoot:
			if colider.get_collider().is_in_group("idiot"):
				target = colider.get_collider()
				purpose = target
				the_path_is_set = true
				signalization = true
				notifications = true
				
func shoot_colide():
	if shoot_colider.is_colliding():
		if shoot_colider.get_collider().is_in_group("idiot"):
			target = shoot_colider.get_collider()
			purpose = target
			walk_and_Shoot = true
			notifications = true
			shoot()
		else:
			walk_and_Shoot = false

func shoot():
	if !shooting:
		for bullet in bullets_nodes:
			var bullet_load = bullet_load_scene.instantiate()
			get_parent().add_child(bullet_load)
			bullet_load.global_position = bullet.global_position
			bullet_load.transform.basis = bullet.global_transform.basis
			sound_blast_shoot.play()
			shooting = true
			await get_tree().create_timer(0.2, false).timeout
			shooting = false

func player_nav_point_body_entered(_body):
	if _body.is_in_group("SEC_BOT"):
		if !notifications:
			the_path_is_set = false
			await get_tree().create_timer(10, false).timeout
			if !notifications and !the_path_is_set:
				the_path_is_set = true
				purpose.global_position = ramka_nav_point.global_position

func _on_ramka_3d_body_entered(_body):
	if _body.is_in_group("SEC_BOT"):
		if !notifications:
			the_path_is_set = false
	
