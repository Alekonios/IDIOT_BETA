extends CharacterBody3D

@onready var camorigin = $camorigin
@onready var animations = $AnimationPlayer
@onready var camera_shake = $camorigin/camera_anim
@onready var camera = $camorigin/SpringArm3D/Camera3D
@onready var springarm = $camorigin/SpringArm3D
@onready var cam_orig_pos = $cam_orig_pos
@onready var cam_orig_pos_for_sit = $cam_orig_pos_for_sit
@onready var cam_orig_pos_for_dir = $camorigin_on_dir
@onready var hearth = $SOUNDS/SERDCE
@onready var breath = $SOUNDS/DYHANIE
@onready var sit_shape = $sit_shape
@onready var normal_shape = $def_shape
@onready var naprag_sound = $"../../audio/naprag"

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var SPEED = 6.5
const JUMP_VELOCITY = 4.5
var shake_amount = 1.0
var sens = 0.08
var cycle_shake = false
var going = false
var sit = false
var boost = false
var noticed = false

func _ready():
	normal_shape.show()
	sit_shape.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func _physics_process(delta):
	shake_on_direction()
	# гравитация{
	if not is_on_floor():
		velocity.y -= gravity * delta * 2
		animations.play("my/jump")
	#}
	#функции нажатия кнопок{
	#прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#ускорение
	if Input.is_action_pressed("ctrl"):
		boost = true
		SPEED = 9.0
	else:
		boost = false
		SPEED = 5.0
		
	#присед
	if Input.is_action_pressed("shift") and !boost:
		sit = true
	else:
		sit = false
#}
	
	#вся логика передвижения {
	#получение направления передвидения в зависимости какая клавиша зажата
	var input_dir = Input.get_vector("d", "a", "s", "w")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#что будет когда начато передвмжение
	if direction:
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
		if !sit:
			animations.play("my/idle")
		if sit:
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
#функции мышки{
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		camorigin.rotate_x(deg_to_rad(event.relative.y * sens))
		camorigin.rotation.x = clamp(camorigin.rotation.x, deg_to_rad(-20), deg_to_rad(30))
#}
		
#тряска экрана при движении{
func shake_on_direction():
	if going:
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
	if !noticed:
		print('dssssssssssss')
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
		

#func stop_notifications():
	#if noticed:
		#print(">>>>>")
		#hearth.volume_db = -80
		#breath.volume_db = -80
		#noticed = false
#}

#интерполяция для плавного возвращения камеры в исходную точку{
func interpalation():
	springarm.global_position.y = lerp(springarm.global_position.y, cam_orig_pos.global_position.y, 0.1)  # Здесь 0.1 - коэффициент интерполяции
	springarm.global_position.x = lerp(springarm.global_position.x, cam_orig_pos.global_position.x, 0.1)  # Здесь 0.1 - коэффициент интерполяции
	springarm.global_position.z = lerp(springarm.global_position.z, cam_orig_pos.global_position.z, 0.1)  # Здесь 0.1 - коэффициент интерполяци
	
func interpalation_on_sit():
	springarm.global_position.y = lerp(springarm.global_position.y, cam_orig_pos_for_sit.global_position.y, 0.1)  # Здесь 0.1 - коэффициент интерполяции
	springarm.global_position.x = lerp(springarm.global_position.x, cam_orig_pos_for_sit.global_position.x, 0.1)  # Здесь 0.1 - коэффициент интерполяции
	springarm.global_position.z = lerp(springarm.global_position.z, cam_orig_pos_for_sit.global_position.z, 0.1)  # Здесь 0.1 - коэффициент интерполяци
	
func interpalation_direction():
	springarm.global_position.y = lerp(springarm.global_position.y, cam_orig_pos_for_dir.global_position.y, 0.1)  # Здесь 0.1 - коэффициент интерполяции
	springarm.global_position.x = lerp(springarm.global_position.x, cam_orig_pos_for_dir.global_position.x, 0.1)  # Здесь 0.1 - коэффициент интерполяции
	springarm.global_position.z = lerp(springarm.global_position.z, cam_orig_pos_for_dir.global_position.z, 0.1)  # Здесь 0.1 - коэффициент интерполяци
#}
