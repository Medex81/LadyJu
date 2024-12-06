extends Area2D

class_name CellDetect

enum{FREE, STATIC, OCCUPIED}

var state = FREE:
	set(value):
		if state != STATIC:
			$Label.text = str(value)
			state = value

func _on_area_exited(area):
	if not has_overlapping_areas():
		state = FREE
	#get_tree().call_group("items", "init_scene")

func _on_area_entered(area):
	state = OCCUPIED
