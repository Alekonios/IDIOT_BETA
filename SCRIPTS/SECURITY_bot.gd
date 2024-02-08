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
@onready var hp_lab = $HP_label

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
var recharge = false
var go_back = false
var damage = false
var next_damage = false
var next_three_damage = false
var died = false
var died_anim = false

var health = 100
var recharge_amout = 0

var target = null

#передвижение и цикличные процессы {
func _physics_process(_delta: float):
	if the_path_is_set and !damage and !died:
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
		if !damage and !died:
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
	if nextPosition!= Vector3.ZERO and the_path_is_set and !died:  # Проверяем, что у нас есть следующая позиция пути
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
	if shoot_colider.is_colliding() and !died:
		if shoot_colider.get_collider().is_in_group("idiot"):
			target = shoot_colider.get_collider()
			purpose = target
			walk_and_Shoot = true
			notifications = true
			shoot()
		else:
			walk_and_Shoot = false

func shoot():
	if !shooting and !recharge and !damage:
		var random_bullet_index = randi() % bullets_nodes.size()
		var bullet = bullets_nodes[random_bullet_index]
		var bullet_load = bullet_load_scene.instantiate()
		get_parent().add_child(bullet_load)
		bullet_load.global_position = bullet.global_position
		bullet_load.transform.basis = bullet.global_transform.basis
		sound_blast_shoot.play()
		shooting = true
		recharge_amout += 1
		await get_tree().create_timer(0.2, false).timeout
		shooting = false
	if recharge_amout >= 7:
		recharge = true
		await get_tree().create_timer(5, false).timeout
		recharge_amout = 0
		recharge = false

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

func damage_func():
	if !next_damage and !damage and !next_three_damage:
		animations.stop()
		damage_anim3()
		damage = true
		print("1")
		await get_tree().create_timer(1, false).timeout
		next_damage = true
		await get_tree().create_timer(0.5, false).timeout
		if next_damage:
			next_three_damage = false
			damage = false
			next_damage = false
			
	if next_damage and !next_three_damage:
		animations.stop()
		damage_anim2()
		damage = true
		next_damage = false
		print("2")
		await get_tree().create_timer(1, false).timeout
		next_three_damage = true
		await get_tree().create_timer(0.5, false).timeout
		if next_three_damage:
			damage = false
			next_damage = false
			next_three_damage = false
			
	if next_three_damage and !next_damage:
		animations.stop()
		damage_anim1()
		next_three_damage = false
		next_damage = false
		damage = true
		print("3")
		await get_tree().create_timer(0.5, false).timeout
		damage = false
		
func damage_anim1():
	go_on_damage()
	damage_of_axe_func()
	animations.play("damage_for_axe_v1")
func damage_anim2():
	go_on_damage()
	damage_of_axe_func()
	animations.play("damage_for_axe_v2")
func damage_anim3():
	animations.play("damage_for_axe_3")
	go_on_damage()
	damage_of_axe_func()

func go_on_damage():
	for i in range(5):
		await get_tree().create_timer(0.01, false).timeout
		var attack_offset = transform.basis.z.normalized() * 0.2
		global_translate(attack_offset)

func damage_of_axe_func(axe_damage: int = 10):
	health -= axe_damage
	
func died_func():
	if health <= 0:
		died = true
		died_anim_func()
		
func died_anim_func():
	if !died_anim:
		animations.play("died")
		died_anim = true
	
func _on_while_timer_timeout():
	hp_lab.text = str(health)
	died_func()
