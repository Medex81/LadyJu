@tool
extends Panel

class_name LevelItem

@export var level_number:int = 1
@export var is_locked:bool = true
@export var stars_count:int = 0
@export var path_to_level:String = "a_none"

func _ready() -> void:
	$MarginContainer/VBoxContainer/level_number.text = str(level_number)
	$MarginContainer/VBoxContainer/level_number/chains.visible = is_locked
	$MarginContainer/VBoxContainer/stars.count = stars_count

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if not path_to_level.is_empty():
					get_tree().change_scene_to_file(path_to_level) 
