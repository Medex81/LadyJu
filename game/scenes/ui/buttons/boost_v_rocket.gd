extends Button

@onready var player_state:PlayerState = Globals.player_state

func _ready() -> void:
	player_state.send_boost_v_rocket_change.connect(set_value)
	$count_panel/value.text = str(player_state.boost_v_rocket)

func set_value(value:int):
	$count_panel/value.text = str(value)
	
func _exit_tree() -> void:
	if player_state.send_boost_v_rocket_change.is_connected(set_value):
		player_state.send_boost_v_rocket_change.disconnect(set_value)
