extends Node3D

@onready var animations = $charapters/idiot/AnimationPlayer2
@onready var robo_anim = $"charapters/robo_cow_comlate!!!/AnimationPlayer"
@onready var flash_anim = $"objects/break_flash_light/street flashlight2/break_light"

var im_kill_you = false

func _process(_delta):
	animations.play("idle_cotscene")
	flash_anim.play("light_morg")
	if !im_kill_you:
		robo_anim.play("idle2")
	else:
		robo_anim.play("IM_KILL_YOU")

func _on_robo_cow_timer_timeout():
	im_kill_you = true
	await get_tree().create_timer(1.7, false).timeout
	im_kill_you = false
