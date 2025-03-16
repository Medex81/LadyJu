extends Panel

class_name QuestsPanel

var quest_count:int = 0
var quests:PackedStringArray
const group_name = "quests_panel"
const on_stop_move_fn = "on_stop_move"
@export var _base_m3_layer:BaseM3Layer = null
const quest_step = "step"
static var is_no_step:bool = false

func _ready() -> void:
	for child in $MarginContainer/quest_container.get_children():
		if child is Quest and child.is_monitoring:
			quests.append(child.get_quest_name())
	quest_count = quests.size()
		
func quest_done(quest_name:String):
	if _base_m3_layer != null and quest_name == quest_step and quest_count > 0:
		is_no_step = true
		on_stop_move()
		return

	if quest_name in quests and quest_count > 0:
		quest_count -= 1
		if quest_count == 0 and _base_m3_layer != null:
			_base_m3_layer.events(BaseM3Layer.EEvents.QUESTS_DONE)
			
func on_stop_move():
	if is_no_step:
		$Timer.start()

func _on_timer_timeout() -> void:
	if quest_count > 0 and _base_m3_layer != null:
		_base_m3_layer.events(BaseM3Layer.EEvents.NO_STEPS)
