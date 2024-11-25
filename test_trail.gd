extends Node2D

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		$smoke.add_point(get_local_mouse_position())
