@tool
extends HBoxContainer

@export var save_value_type:PlayerState.EPS = PlayerState.EPS.NONE
var state_value:PlayerStateValueInt = null

func _ready() -> void:
	if save_value_type != PlayerState.EPS.NONE:
		state_value = Globals.player_state.get_int_value(save_value_type)
		$value.text = str(state_value.value)
		$name_value.text = PlayerState.EPS.keys()[save_value_type]

func _on_value_text_submitted(new_text: String) -> void:
	if new_text.is_valid_int():
		if state_value:
			var val = absi(new_text.to_int())
			state_value.value = val if val < 999999 else 999999
	else:
		$value.text = str(state_value.value)
