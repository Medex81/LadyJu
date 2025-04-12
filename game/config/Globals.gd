extends Node

const player_state_path:String = "user://player_state.tres"
const end_scene_path:String = "res://game/scenes/game_end.tscn"

var player_state:PlayerState = null

func _ready() -> void:
	if FileAccess.file_exists(player_state_path):
		player_state = ResourceLoader.load(player_state_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		player_state = PlayerState.new()
		ResourceSaver.save(player_state, player_state_path)
		
func save_player_state():
	ResourceSaver.save(player_state, player_state_path)
