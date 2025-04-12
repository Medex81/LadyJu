extends Control

@export var start_location:String
@onready var player_state:PlayerState = Globals.player_state

func _ready() -> void:
	if player_state.current_location.is_empty() and not start_location.is_empty():
		player_state.current_location = start_location
		Globals.save_player_state()
	if player_state.current_location.is_empty() and start_location.is_empty():
		print("Error. Start location path is empty.")
		return
	get_tree().call_deferred("change_scene_to_file", player_state.current_location)
