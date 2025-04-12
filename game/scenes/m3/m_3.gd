extends Control

class_name M3

@export var _base_m3_level:BaseM3Level = null
@export var _move_timeout:float = 0.2 
var timeout_counter:float = 0
@onready var tree = get_tree()
				
func _physics_process(delta: float) -> void:
	timeout_counter += delta
	if timeout_counter >= _move_timeout:
		timeout_counter = 0
		tree.call_group(InfoComponent.group_name, "check_move")
