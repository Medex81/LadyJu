@tool
extends Control

class_name Cell

var _color_on:Color = Color(0.35,0.62,0.83,0.41)
var _color_off:Color = Color(0,0,0,0)

@export var is_spawn:bool = false:
	set(value):
		is_spawn = value
		
@export var is_hole:bool = false:
	set(value):
		var style = get_theme_stylebox("panel").duplicate()
		style.bg_color = _color_off if value else _color_on
		add_theme_stylebox_override("panel", style)
		if value:
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
		
func _get_drag_data(_at_position):
	return self
	
func _can_drop_data(_at_position, data)->bool:
	return true if data is Cell else false
	
func _drop_data(_at_position, data):
	send_tap.emit(data, self)
var _tween:Tween = null
func move_animation(item:Item, new_position:Vector2):
	_tween = create_tween()
	_tween.tween_property(item, "position", new_position, 0.2)

func swap(cell_other:Cell):
	var item_other = cell_other.items.pop_back() as Item
	var item_my = items.pop_back() as Item
	if _tween:
			_tween.kill()
	if item_other:
		cell_other.remove_child(item_other)
		add_child(item_other)
		items.append(item_other)
		item_other.position = cell_other.position - position
		move_animation(item_other, Vector2.ZERO)
		
	if item_my:
		remove_child(item_my)
		cell_other.add_child(item_my)
		cell_other.items.append(item_my)
		item_my.position = position - cell_other.position
		cell_other.move_animation(item_my, Vector2.ZERO)


func spawn(item:Item):
	if item:
		add_child(item)
		items.append(item)
			
func delete():
	if items.is_empty():
		print("Error. Try removing item from empty cell ", name)
		return
	var item = items.pop_back() as Item
	remove_child(item)
	item.queue_free()
