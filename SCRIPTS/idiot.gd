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

func _ready():
	died_shape.disabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func _physics_process(delta):
	if died:
		died_interpalation()
	shake_on_direction()
	# гравитация{
	if not is_on_floor():
		velocity.y -= gravity * delta * 2
		if !died:
			animations.play("my/jump")
	#}
	#функции нажатия кнопок{
	#прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !died:
		velocity.y = JUMP_VELOCITY
		
	#ускорение
	if Input.is_action_pressed("ctrl") and !died:
		boost = true
		SPEED = 9.0
	else:
		boost = false
		SPEED = 5.0
		
	#присед
	if Input.is_action_pressed("shift") and !boost and !died:
		sit = true
	else:
		sit = false
#}
	
	#вся логика передвижения {
	#получение направления передвидения в зависимости какая клавиша зажата
	var input_dir = Input.get_vector("d", "a", "s", "w")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#что будет когда начато передвмжение
	if direction and !died:
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
		if !sit and !died:
			animations.play("my/idle")
		if sit and !died:
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
	if event is InputEventMouseMotion and !died:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		camorigin.rotate_x(deg_to_rad(event.relative.y * sens))
		camorigin.rotation.x = clamp(camorigin.rotation.x, deg_to_rad(-20), deg_to_rad(30))
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
		springarm.global_position.y = lerp(springarm.global_position.y, cam_orig_pos.global_position.y, 0.1)  # Здесь 0.1 - коэффициент интерполяции
		springarm.global_position.x = lerp(springarm.global_position.x, cam_orig_pos.global_position.x, 0.1)  # Здесь 0.1 - коэффициент интерполяции
		springarm.global_position.z = lerp(springarm.global_position.z, cam_orig_pos.global_position.z, 0.1)  # Здесь 0.1 - коэффициент интерполяци
	
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
	springarm.global_position.x = lerp(springarm.global_position.x, cam_died_pos.global_position.x, 0.2)  # Здесь 0.1 - коэффициент интерполяции
	springarm.global_position.y = lerp(springarm.global_position.y, cam_died_pos.global_position.y, 0.2)  # Здесь 0.1 - коэффициент интерполяции
	springarm.global_position.z = lerp(springarm.global_position.z, cam_died_pos.global_position.z, 0.2)  # Здесь 0.1 - коэффициент интерполяции
#}

#damage amd attack system and died {
func damaging_def_blaster():
	health -= 30
	cam_anim.play("camera_shake")
	if health <= 0:
		health = 0
	damageing = true
	if damageing and !died:
		screen_anim.play("red-true")
		await get_tree().create_timer(3, false).timeout
		screen_anim.play("red-false")
		damageing = false

		
func visual_health():
	health_label.text = str(health)
	
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
		
