extends Control

class_name BaseM3Level

enum EEvents{TASKS_DONE, NO_HINTS, CONDITION_FAIL}
const group_name:String = "game_field"
const events_fn:String = "events"
@export var back_to_location:String
@onready var player_state:PlayerState = Globals.player_state
@export var quest_info:QuestInfo = null

func back():
	if not back_to_location.is_empty():
		get_tree().change_scene_to_file(back_to_location)

func events(event:EEvents):
	match event:
		EEvents.TASKS_DONE:
			print("TASKS_DONE")
			if quest_info != null:
				player_state.quest_done = quest_info.quest_name
				
			back()
		EEvents.NO_HINTS:
			print("NO_HINTS")
			back()
		EEvents.CONDITION_FAIL:
			print("CONDITION_FAIL")
			back()
			
func _exit_tree() -> void:
	Globals.save_player_state()
	
			
