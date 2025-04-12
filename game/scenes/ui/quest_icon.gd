# По указанному в настройках пути запускаем новую сцену
extends TextureRect

class_name QuestItem

enum EState{PASSED,CURRENT,LOCKED}

var state:EState = EState.LOCKED
@export var quest_info:QuestInfo = null

func _ready() -> void:
	set_state(state)
			
func run():
	if state == EState.CURRENT and quest_info:
		var error = get_tree().change_scene_to_file(quest_info.level_path)
		if error != OK:
			print(error)
			
func get_quest_name()->String:
	return quest_info.quest_name if quest_info != null else "a_none"
	
func set_state(_state:EState):
	state = _state
	match state:
		EState.PASSED:
			self_modulate.a = 255
			$passed.visible = true
		EState.CURRENT:
			self_modulate.a = 255
		EState.LOCKED:
			self_modulate.a = 50
