extends CharacterBody3D


const speed = 1500  # Скорость пули

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

var purpose = null


func _process(delta):
	# Движение пули
	position += transform.basis * Vector3(0, 0, -speed) * delta



func _on_area_3d_body_entered(_body):
	#if _body.is_in_group("idiot"):
		#purpose = _body
		#purpose.damaging_def_blaster()
	#if _body.is_in_group("Z"):
		#purpose = _body
		#purpose.died_func()
	queue_free()
