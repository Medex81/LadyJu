extends Control

class_name M3

enum EEvent{NO_HINT}

const group_name:String = "m3_scene"
const events_fn:String = "events"

@export var _base_m3_layer:BaseM3Layer = null
@export var _move_timeout:float = 0.2 
var timeout_counter:float = 0
@onready var tree = get_tree()

func events(event:EEvent):
	match event:
		EEvent.NO_HINT:
			if _base_m3_layer != null:
				_base_m3_layer.layer_completed(false)
				
func _physics_process(delta: float) -> void:
	timeout_counter += delta
	if timeout_counter >= _move_timeout:
		timeout_counter = 0
		tree.call_group(InfoComponent.group_name, "check_move")
