@tool
extends Control

class_name Cell

@export var is_spawn:bool = false:
	set(value):
		is_spawn = value
		
@export var is_hole:bool = false:
	set(value):
		$back_tex.visible = !value
		is_spawn = !value
		is_hole = value
		
@onready var items:Array[Item] = get_item_node_list()

signal send_tap(control_first:Control, control_second:Control)

func get_item_node_list()->Array[Item]:
	var _items:Array[Item]
	for child in get_children():
		if child is Item:
			_items.append(child)
	return _items
	
func _on_gui_input(event):
	if event is InputEventMouseButton:
		send_tap.emit(self, event.pressed)
		
func _get_drag_data(at_position):
	return self
	
func _can_drop_data(at_position, data)->bool:
	return true if data is Cell else false
	
func _drop_data(at_position, data):
	send_tap.emit(data, self)

func swap(cell_from:Cell):
	var item_from = cell_from.items.pop_back()
	var item_to = items.pop_back()
	if item_from:
		cell_from.remove_child(item_from)
		add_child(item_from)
		items.append(item_from)
	if item_to:
		remove_child(item_to)
		cell_from.add_child(item_to)
		cell_from.items.append(item_to)

func spawn(item:Item):
	if item:
		add_child(item)
		items.append(item)
