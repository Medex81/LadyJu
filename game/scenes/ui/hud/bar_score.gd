extends Panel

@onready var player_state:PlayerState = Globals.player_state

func _ready() -> void:
	player_state.send_coins_change.connect(set_value)
	$value.text = str(player_state.coins)

func set_value(value:int):
	$value.text = str(value)
	
func _exit_tree() -> void:
	if player_state.send_coins_change.is_connected(set_value):
		player_state.send_coins_change.disconnect(set_value)
