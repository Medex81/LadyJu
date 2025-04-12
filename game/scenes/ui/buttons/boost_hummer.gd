extends Button

@onready var player_state:PlayerState = Globals.player_state

func _ready() -> void:
	player_state.send_boost_hummer_change.connect(set_value)
	$count_panel/value.text = str(player_state.boost_hummer)

func set_value(value:int):
	$count_panel/value.text = str(value)
	
func _exit_tree() -> void:
	if player_state.send_boost_hummer_change.is_connected(set_value):
		player_state.send_boost_hummer_change.disconnect(set_value)
