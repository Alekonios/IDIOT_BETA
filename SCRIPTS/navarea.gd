extends Node3D

var eterned = false
var ZMAN = null


func on_nav_point_body_entered(_body):
	if _body.is_in_group("Z"):
		ZMAN = _body
		ZMAN.stop_path()
