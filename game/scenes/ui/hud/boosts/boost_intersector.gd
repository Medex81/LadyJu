extends Control
class_name BoostInterseptor

@export var boosts_button:Array[BaseBoostButton]

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and not boosts_button.is_empty():
		var glob_mouse_pos = get_global_mouse_position()
		for boost in boosts_button:
			boost.hit_on_position(glob_mouse_pos)
