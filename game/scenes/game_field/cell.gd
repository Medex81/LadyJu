@tool
extends Control

class_name Cell

@export var spawn = false:
	set(value):
		spawn = value
		
@export var hole = false:
	set(value):
		$back_tex.visible = !value
		spawn = !value
		hole = value
		
@onready var items:Array[Item] = get_item_node_list()
	
func get_item_node_list()->Array[Item]:
	var _items:Array[Item]
	for child in get_children():
		if child is Item:
			_items.append(child)
	return _items
	
