extends SpringArm3D

#var cycle_shake = false
#@onready var stringarm = $"."
#@onready var had = $"../Node3D"
#
#
#func _process(delta):
	#if G.running:
		#if!cycle_shake:w
			#stringarm.position.y += 0.06
			#await get_tree().create_timer(0.2, false).timeout
			#cycle_shake = true
		#else:
			#stringarm.position.y -= 0.03
			#await get_tree().create_timer(0.2, false).timeout
			#cycle_shake = false
#
		## Линейная интерполяция для плавного приравнивания позиции
		#stringarm.global_position.y = lerp(stringarm.global_position.y, had.global_position.y, 0.1)  # Здесь 0.1 - коэффициент интерполяции
		#stringarm.global_position.x = lerp(stringarm.global_position.x, had.global_position.x, 0.1)  # Здесь 0.1 - коэффициент интерполяции
		#stringarm.global_position.z = lerp(stringarm.global_position.z, had.global_position.z, 0.1)  # Здесь 0.1 - коэффициент интерполяции
