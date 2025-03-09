@tool

extends Control

class_name Quest

const group_name:String = "quest"
const on_final_item_fn:String = "on_final_item"

@export var item_count:int = 1
@export var quest_container:QuestContainer = null
@export var is_monitoring:bool = true

var _item_name:String = "None"
var _quest_name:String = "None"

func _ready() -> void:
	$count.text = str(item_count)
	for child in get_children():
		if child is InfoComponent:
			_item_name = child.get_item_name()
			break
	_quest_name = _item_name if not is_monitoring else _item_name + "_" + $count.text
	$done.visible = false
			
func on_final_item(final_item_name:String):
	if final_item_name == _item_name and item_count > 0:
		item_count -= 1
		$count.text = str(item_count)
		if item_count == 0:
			$done.visible = true
			if quest_container:
				quest_container.quest_done(_quest_name)
				
func get_quest_name()->String:
	return _quest_name
		
	
