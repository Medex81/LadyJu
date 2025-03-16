@tool

extends Control

class_name Quest

const group_name:String = "quest"
const on_final_item_fn:String = "on_final_item"

@export var item_count:int = 1
@export var quests_panel:QuestsPanel = null
@export var is_monitoring:bool = true

var _item_name:String
var _quest_name:String

func _ready() -> void:
	$quest_panel/count.text = str(item_count)
	for child in get_children():
		if child is InfoComponent and child.has_method("get_item_name"):
			_item_name = child.get_item_name()
			break
	if _item_name.is_empty():
		print("Error. No item name in quest!")
		return
	_quest_name = _item_name if not is_monitoring else _item_name + "_" + $quest_panel/count.text
	$quest_panel/done.visible = false
			
func on_final_item(final_item_name:String):
	if final_item_name == _item_name and item_count > 0:
		item_count -= 1
		$quest_panel/count.text = str(item_count)
		if item_count == 0:
			$quest_panel/done.visible = true
			if quests_panel:
				quests_panel.quest_done(_quest_name)
				
func get_quest_name()->String:
	return _quest_name
		
func get_item_name()->String:
	return _item_name
