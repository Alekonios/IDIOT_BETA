extends CharacterBody3D

@onready var camorigin = $camorigin
@onready var animations = $AnimationPlayer
@onready var camera_shake = $camorigin/camera_anim
@onready var camera = $camorigin/SpringArm3D/Camera3D
@onready var springarm = $camorigin/SpringArm3D
@onready var cam_orig_pos = $cam_orig_pos
@onready var cam_orig_pos_for_sit = $cam_orig_pos_for_sit
@onready var cam_orig_pos_for_dir = $camorigin_on_dir
@onready var cam_died_pos = $died_cam_origin
@onready var hearth = $SOUNDS/SERDCE
@onready var breath = $SOUNDS/DYHANIE
@onready var sit_shape = $sit_shape
@onready var normal_shape = $def_shape
@onready var naprag_sound = $"../../audio/naprag"
@onready var health_label = $"2D/1675946236Grizly-club-p-ramka-v-stile-stimpank-klipart-5/1706433580316/Label"
@onready var died_shape = $died_shape
@onready var cam_anim = $camorigin/camera_anim
@onready var died_sound = $SOUNDS/died
@onready var screen_anim = $"2D/RedVignette/AnimationPlayer"
@onready var axe = $Armature/Skeleton3D/right_hand/weapons/AXE
@onready var axe_on_back = $Armature/Skeleton3D/spina/AXE2
@onready var air = null
@onready var weapons = []
@onready var axe_vfx = $Armature/Skeleton3D/right_hand/weapons/AXE/VFX_EFFECT
@onready var axe_vfx_particles = [$Armature/Skeleton3D/right_hand/weapons/AXE/VFX_EFFECT/GPUParticles3D, $Armature/Skeleton3D/right_hand/weapons/AXE/VFX_EFFECT/GPUParticles3D2, $Armature/Skeleton3D/right_hand/weapons/AXE/VFX_EFFECT/GPUParticles3D3, $Armature/Skeleton3D/right_hand/weapons/AXE/VFX_EFFECT/GPUParticles3D4]
@onready var axe_vfx_light = [$Armature/Skeleton3D/right_hand/weapons/AXE/VFX_EFFECT/OmniLight3D, $Armature/Skeleton3D/right_hand/weapons/AXE/VFX_EFFECT/OmniLight3D2, $Armature/Skeleton3D/right_hand/weapons/AXE/VFX_EFFECT/OmniLight3D3, $Armature/Skeleton3D/right_hand/weapons/AXE/VFX_EFFECT/OmniLight3D4]
@onready var cam_orig_pos_for_attack = $Armature/Skeleton3D/right_hand/weapons/AXE/orig_pos


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var SPEED = 6.5
const JUMP_VELOCITY = 4.5
var shake_amount = 1.0
var sens = 0.08
var health = 100



var cycle_shake = false
var going = false
var sit = false
var boost = false
var noticed = false
var died = false
var died_anim = false
var damageing = false
var axe_unlocked = false
var slot1 = false
var slot2 = false
var slot3 = false
var axe_in_hand = false
var air_in_hand = true
var attacking = false
var next_attack = false
var three_next_attack = false


func _ready():
	axe_vfx.transparency = 1
	died_shape.disabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func _physics_process(delta):
	if attacking:
		attack_interpalation()
	if died:
		died_interpalation()
	shake_on_direction()
	# гравитация{
	if not is_on_floor():
		velocity.y -= gravity * delta * 2
		if !died and !attacking:
			animations.play("my/jump")
	#}
	#функции нажатия кнопок{
	#прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !died and !attacking:
		velocity.y = JUMP_VELOCITY
		
	#ускорение
	if Input.is_action_pressed("ctrl") and !died:
		boost = true
		SPEED = 9.0
	else:
		boost = false
		SPEED = 5.0
		
	#присед
	if Input.is_action_pressed("shift") and !boost and !died and !attacking:
		sit = true
	else:
		sit = false
#}
	
	#вся логика передвижения {
	#получение направления передвидения в зависимости какая клавиша зажата
	var input_dir = Input.get_vector("d", "a", "s", "w")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#что будет когда начато передвмжение
	if direction and !died and !attacking:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if !sit:
			#логика анимаций
			if !boost:
				interpalation_direction()
				animations.play("walk")
			if boost:
				interpalation_direction()
				animations.play("my/running")
		going = true
		#движение сидя
		if sit:
			SPEED = 4.0
			animations.play("my/sit_run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if !sit and !died and !attacking:
			animations.play("my/idle")
		if sit and !died and !attacking:
			SPEED = 4.0
			animations.play("my/sit")
			await get_tree().create_timer(0.2, false).timeout
		going = false
	move_and_slide()
	if sit:
		sit_shape.disabled = false
		normal_shape.disabled = true
		interpalation_on_sit()
	else:
		interpalation()
		normal_shape.disabled = false
		sit_shape.disabled = true
#}

#тряска экрана при движении{
func shake_on_direction():
	if going and !died:
		if !sit and !boost:
			if !cycle_shake:
				springarm.global_position.y += 0.02
				await get_tree().create_timer(0.2, false).timeout
				cycle_shake = true
			if cycle_shake:
				springarm.global_position.y -= 0.01
				await get_tree().create_timer(0.2, false).timeout
				cycle_shake = false
		if sit and !boost:
			if !cycle_shake:
				springarm.global_position.y += 0.02
				await get_tree().create_timer(0.3, false).timeout
				cycle_shake = true
			if cycle_shake:
				springarm.global_position.y -= 0.01
				await get_tree().create_timer(0.3, false).timeout
				cycle_shake = false
		if boost:
			if !cycle_shake:
				springarm.global_position.y += 0.024
				await get_tree().create_timer(0.1, false).timeout
				cycle_shake = true
			if cycle_shake:
				springarm.global_position.y -= 0.012
				await get_tree().create_timer(0.1, false).timeout
				cycle_shake = false
#}

#седцебиение и дыхание при обнаружении{
func notifications():
	if !noticed and !died:
		naprag_sound.play()
		hearth.play()
		breath.play()
		hearth.volume_db = -15
		breath.volume_db = -15
		naprag_sound.volume_db = -30
		noticed = true
		await get_tree().create_timer(20, false).timeout
		for i in range(6):
			await get_tree().create_timer(0.3, false).timeout
			hearth.volume_db -= 10
			breath.volume_db -= 10
			naprag_sound.volume_db -= 10
		await get_tree().create_timer(3, false).timeout
		hearth.stop()
		breath.stop()
		naprag_sound.stop()
		noticed = false
		

#интерполяция для плавного возвращения камеры в исходную точку{
func interpalation():
	if !died:
		springarm.global_position.y = lerp(springarm.global_position.y, cam_orig_pos.global_position.y, 0.07)  # Здесь 0.1 - коэффициент интерполяции
		springarm.global_position.x = lerp(springarm.global_position.x, cam_orig_pos.global_position.x, 0.07)  # Здесь 0.1 - коэффициент интерполяции
		springarm.global_position.z = lerp(springarm.global_position.z, cam_orig_pos.global_position.z, 0.07)  # Здесь 0.1 - коэффициент интерполяци
	
func interpalation_on_sit():
	if !died:
		springarm.global_position.y = lerp(springarm.global_position.y, cam_orig_pos_for_sit.global_position.y, 0.1)  # Здесь 0.1 - коэффициент интерполяции
		springarm.global_position.x = lerp(springarm.global_position.x, cam_orig_pos_for_sit.global_position.x, 0.1)  # Здесь 0.1 - коэффициент интерполяции
		springarm.global_position.z = lerp(springarm.global_position.z, cam_orig_pos_for_sit.global_position.z, 0.1)  # Здесь 0.1 - коэффициент интерполяци
	
func interpalation_direction():
	if !died:
		springarm.global_position.y = lerp(springarm.global_position.y, cam_orig_pos_for_dir.global_position.y, 0.1)  # Здесь 0.1 - коэффициент интерполяции
		springarm.global_position.x = lerp(springarm.global_position.x, cam_orig_pos_for_dir.global_position.x, 0.1)  # Здесь 0.1 - коэффициент интерполяции
		springarm.global_position.z = lerp(springarm.global_position.z, cam_orig_pos_for_dir.global_position.z, 0.1)  # Здесь 0.1 - коэффициент интерполяци
	
func died_interpalation():
	springarm.global_position.x = lerp(springarm.global_position.x, cam_died_pos.global_position.x, 0.1)  # Здесь 0.1 - коэффициент интерполяции
	springarm.global_position.y = lerp(springarm.global_position.y, cam_died_pos.global_position.y, 0.1)  # Здесь 0.1 - коэффициент интерполяции
	springarm.global_position.z = lerp(springarm.global_position.z, cam_died_pos.global_position.z, 0.1)  # Здесь 0.1 - коэффициент интерполяции
	
func attack_interpalation():
	if !died:
		springarm.global_position.y = lerp(springarm.global_position.y, cam_orig_pos_for_attack.global_position.y, 0.04)  
		springarm.global_position.x = lerp(springarm.global_position.x, cam_orig_pos_for_attack.global_position.x, 0.04)  
		springarm.global_position.z = lerp(springarm.global_position.z, cam_orig_pos_for_attack.global_position.z, 0.04)  
#camera shake{
func camera_shake_func():
	for i in range(10):
		var shake_offset = Vector3(
		randf_range(-0.2, 0.2), # Случайное смещение вдоль оси X
		randf_range(-0.2, 0.2), # Случайное смещение вдоль оси Y
		randf_range(-0.2, 0.2) # Случайное смещение вдоль оси Z
		)
		await get_tree().create_timer(0.03, false).timeout
		camera.global_transform.origin += shake_offset
#}
#input func{
func _input(event):
	if event is InputEventMouseMotion and !died:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		camorigin.rotate_x(deg_to_rad(event.relative.y * sens))
		camorigin.rotation.x = clamp(camorigin.rotation.x, deg_to_rad(-20), deg_to_rad(30))
	if Input.is_action_just_pressed("AXE"):
		axe_unlocked = true
	if Input.is_action_just_pressed("num_1") and !attacking and !died:
		slot1 = true
		slot2 = false
		slot3 = false
		weapon_swap_func()
	if Input.is_action_just_pressed("num_2") and !attacking and !died:
		slot1 = false
		slot2 = true
		slot3 = false
		weapon_swap_func()
	if Input.is_action_just_pressed("num_3") and !attacking and !died:
		slot1 = false
		slot2 = false
		slot3 = true
		weapon_swap_func()
	if Input.is_action_just_pressed("LC") and !attacking and !died:
		attack()
#}
#damage amd attack system and died {
#damage{
func visual_health():
	health_label.text = str(health)

func damaging_def_blaster():
	health -= 30
	camera_shake_func()
	if health <= 0:
		health = 0
	damageing = true
	if damageing and !died:
		screen_anim.play("red-true")
		await get_tree().create_timer(3, false).timeout
		screen_anim.play("red-false")
		damageing = false
	
func _on_health_update_timer_timeout():
	visual_health()
	if health <= 0:
		died_func()
		
func died_func():
	normal_shape.disabled = true
	sit_shape.disabled = true
	died_shape.disabled = false
	died = true
	died_anim_func()
	
func died_anim_func():
	if died:
		if !died_anim:
			animations.play("my/dyeing")
			died_sound.play()
			died_anim = true
#}

#add_new_weapon{
func add_new_weapon_func():
	if axe_unlocked:
		if air or axe not in weapons:
			air_add_func()
			axe_add_func()
			
func air_add_func():
	weapons.append(air)
			
func axe_add_func():
	weapons.append(axe)
	axe.show()

func weapon_swap_func():
	if weapons.size() >= 2:
		if slot1:
			axe_on_back.show()
			axe.hide()
			air_in_hand = true
			axe_in_hand = false
		if slot2:
			axe_on_back.hide()
			axe.show()
			axe_in_hand = true
func _on_weapons_update_timer_timeout():
	add_new_weapon_func()
	print(weapons)
#}
#attack{
func attack():
	if axe_in_hand and !attacking and !next_attack and !three_next_attack:
		next_attack = true
		attacking = true
		animations.speed_scale = 1.2
		animations.play("my/axe_attack1")
		axe_vfx_on_func()
		await get_tree().create_timer(1.4, false).timeout
		animations.speed_scale = 1
		attacking = false
		axe_vfx_off_func()
		await get_tree().create_timer(0.5, false).timeout
		next_attack = false
	#two axe attack
	if next_attack and !attacking and axe_in_hand:
		attacking = true
		animations.speed_scale = 1.2
		two_axe_anim()
		await get_tree().create_timer(1.7, false).timeout
		animations.speed_scale = 1
		attacking = false
		axe_vfx_off_func()
		three_next_attack = true
		await get_tree().create_timer(1, false).timeout
		three_next_attack = false
	#three axe attack
	if three_next_attack and !attacking and axe_in_hand:
		attacking = true
		animations.speed_scale = 1.2
		three_axe_anim()
		await get_tree().create_timer(1.7, false).timeout
		animations.speed_scale = 1
		attacking = false
		axe_vfx_off_func()
		await get_tree().create_timer(1, false).timeout
		animations.speed_scale = 1
		three_next_attack = false

func two_axe_anim():
	axe_vfx_on_func()
	animations.play("my/axe_attack2")
	await get_tree().create_timer(0.2, false).timeout
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.2, false).timeout
	Engine.time_scale = 1
	await get_tree().create_timer(0.4, false).timeout
	Engine.time_scale = 1
	go_on_attack()

func three_axe_anim():
	axe_vfx_on_func()
	animations.play("my/axe_attack3")
	await get_tree().create_timer(0.2, false).timeout
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.2, false).timeout
	Engine.time_scale = 1
	await get_tree().create_timer(0.2, false).timeout
	go_on_attack()
	
func go_on_attack():
	for i in range(5):
		await get_tree().create_timer(0.01, false).timeout
		var attack_offset = transform.basis.z.normalized() * 0.3
		global_translate(attack_offset)
#}
#vfx{
func axe_vfx_on_func():
	if attacking:
		await get_tree().create_timer(0.2, false).timeout
		for light in axe_vfx_light:
			light.show()
		for particles in axe_vfx_particles:
			particles.emitting = true
		for i in range(10):
			await get_tree().create_timer(0.01, false).timeout
			axe_vfx.transparency -= 0.1
func axe_vfx_off_func():
	if !attacking:
		await get_tree().create_timer(0.1, false).timeout
		for light in axe_vfx_light:
			light.hide()
		for particles in axe_vfx_particles:
			particles.emitting = false
		for i in range(10):
			await get_tree().create_timer(0.01, false).timeout
			axe_vfx.transparency += 0.1
#}
