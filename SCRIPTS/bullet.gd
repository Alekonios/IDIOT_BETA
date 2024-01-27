extends CharacterBody3D


const speed = 1500  # Скорость пули

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D


func _process(delta):
	# Движение пули
	position += transform.basis * Vector3(0, 0, -speed) * delta



func _on_area_3d_body_entered(_body):
	print(_body)
	queue_free()
