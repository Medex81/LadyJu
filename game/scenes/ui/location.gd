extends Control

class_name Location

@onready var player_state:PlayerState = Globals.player_state

@export var location_name:String = "a_none"
@export var next_location_path:String
@onready var queue_quests:HBoxContainer = $HUD/main_v/top/scroll_quests/queue_quests
var run_quest:QuestItem = null


func _ready() -> void:
	player_state.current_quest = queue_quests.get_children().front().get_quest_name()
	player_state.quest_done = ""
	if player_state.current_quest.is_empty() and queue_quests.get_child_count():
		player_state.current_quest = queue_quests.get_children().front().get_quest_name()
		Globals.save_player_state()
	var is_current_quest_done = false
	for queue_item in queue_quests.get_children():
		if queue_item is QuestItem:
			if queue_item.get_quest_name() == player_state.current_quest or is_current_quest_done:
				if not player_state.quest_done.is_empty() and queue_item.get_quest_name() == player_state.quest_done:
					is_current_quest_done = true
					player_state.quest_done = ""
					continue
				queue_item.set_state(QuestItem.EState.CURRENT)
				$hint_puppy/hint/margin/item.texture = queue_item.texture
				run_quest = queue_item
				player_state.current_quest = queue_item.get_quest_name()
				Globals.save_player_state()
				break
			else:
				queue_item.set_state(QuestItem.EState.PASSED)
		else:
			print("Error. In quest queue not questable object ", location_name)
			
	if run_quest == null and next_location_path.is_empty():
		get_tree().call_deferred("change_scene_to_file", Globals.end_scene_path)
