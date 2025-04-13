extends Panel

@export var save_value_type:PlayerState.EPS = PlayerState.EPS.NONE
var save_value:PlayerStateValueInt = null

func set_value(value:int):
	$value.text = str(value)

func _ready() -> void:
	if save_value_type != PlayerState.EPS.NONE:
		save_value = Globals.player_state.get_int_value(save_value_type)
		if save_value:
			save_value.send_value_change.connect(set_value)
			set_value(save_value.value)
	
func _exit_tree() -> void:
	if save_value:
		if save_value.send_value_change.is_connected(set_value):
			save_value.send_value_change.disconnect(set_value)
