@tool
extends Control

class_name Cell

var _color_on:Color = Color(0.35,0.62,0.83,0.41)
var _color_off:Color = Color(0,0,0,0)
var _tween_move:Tween = null
var _tween_hint:Tween = null
@onready var items:Array[Item] = get_item_node_list()
var _animated_item_lambda = null

@export var animation_scale:float = 1.15
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
@export var hint_time:float = 0.4
@export var move_time:float = 0.2

signal send_tap(control_first:Control, control_second:Control)

func get_item_type()->Match3Logic.EItemTypes:
	return items.back().item_type if not items.is_empty() else Match3Logic.EItemTypes.NONE

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

func move_animation(item:Item, new_position:Vector2):
	if _tween_move:
		if _tween_move.is_running():
			_done()
		_tween_move.kill()

	_tween_move = create_tween()
	_tween_move.tween_property(item, "position", new_position, move_time)
	_tween_move.tween_callback(_done)
	
func _done():
	get_parent().done_event()
	
func stop_hint_animations():
	if _tween_hint:
		_tween_hint.kill()
		if _animated_item_lambda:
			_animated_item_lambda.call()
			_animated_item_lambda = null

func hint_animation(item:Item):
	stop_hint_animations()
	if _animated_item_lambda:
		print("Error. Lambda from a last hint is not null. ", name)
	_tween_hint = create_tween()
	_tween_hint.set_loops(100)
	var old_scale = item.scale
	var old_position = item.position
	_tween_hint.tween_property(item, "scale", old_scale * animation_scale, hint_time)
	_tween_hint.parallel().tween_property(item, "position", size * -((animation_scale - 1) / 2.0), hint_time)
	_tween_hint.tween_property(item, "scale", old_scale, hint_time)
	_tween_hint.parallel().tween_property(item, "position", old_position, hint_time)
	_animated_item_lambda = func(): item.scale = old_scale; item.position = old_position

func swap(cell_other:Cell):
	var item_other = cell_other.items.pop_back() as Item
	var item_my = items.pop_back() as Item
	if item_other:
		cell_other.remove_child(item_other)
		add_child(item_other)
		items.append(item_other)
		item_other.position = cell_other.position - position
		move_animation(item_other, Vector2.ZERO)
	else:
		_done()
		
	if item_my:
		remove_child(item_my)
		cell_other.add_child(item_my)
		cell_other.items.append(item_my)
		item_my.position = position - cell_other.position
		cell_other.move_animation(item_my, Vector2.ZERO)
	else:
		_done()
		
func emit_sound():
	if not items.is_empty():
		SoundManager.play_sound(items.back().sound_bouns)

func spawn(item:Item):
	if item:
		add_child(item)
		items.append(item)
		_done()
			
func delete():
	if items.is_empty():
		print("Error. Try removing item from empty cell ", name)
		_done()
		return
	var item = items.pop_back() as Item
	remove_child(item)
	item.queue_free()
	_done()
	
func hint():
	if items.is_empty():
		print("Error. Try hint item from empty cell ", name)
		return
	hint_animation(items.back())
