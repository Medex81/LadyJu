extends GridContainer

class_name QuestContainer

var quest_count:int = 0
var quests:PackedStringArray
@export var _base_m3_layer:BaseM3Layer = null
const quest_step = "step"

func _ready() -> void:
	for child in get_children():
		if child is Quest and child.is_monitoring:
			quests.append(child.get_quest_name())
		
func quest_done(quest_name:String):
	if _base_m3_layer != null and quest_name == quest_step and quest_count > 0:
		_base_m3_layer.events(BaseM3Layer.EEvents.NO_STEPS)
		return

	if quest_name in quests and quest_count > 0:
		quest_count -= 1
		if quest_count == 0 and _base_m3_layer != null:
			_base_m3_layer.events(BaseM3Layer.EEvents.QUESTS_DONE)
