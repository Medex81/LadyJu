@tool
extends Control

class_name Cell

var _color_on:Color = Color(0.35,0.62,0.83,0.41)
var _color_off:Color = Color(0,0,0,0)
var _tween_move:Tween = null
var _tween_hint:Tween = null
var _tween_delete:Tween = null
var _animated_item_lambda = null
var x = -1
var y = -1
var _last_update:int = Time.get_ticks_msec()
var _item_deleting_list:Array[Item]

@export var _is_spawn:bool = false:
	set(value):
		_is_spawn = value
@export var _is_hole:bool = false:
	set(value):
		var style = get_theme_stylebox("panel").duplicate()
		style.bg_color = _color_off if value else _color_on
		add_theme_stylebox_override("panel", style)
		if value:
			_is_spawn = !value
		_is_hole = value

func get_last_update()->int:
	return _last_update

func is_spawn()->bool:
	return _is_spawn
	
func is_hole()->bool:
	return _is_hole
	
func is_common()->bool:
	var children = get_children()
	return children.back().is_common() if not children.is_empty() else false
	
func is_matched()->bool:
	var children = get_children()
	return children.back().is_matched() if not children.is_empty() else false
	
func is_blocked()->bool:
	var children = get_children()
	return children.back().is_blocked() if not children.is_empty() else false
	
func is_empty()->bool:
	var children = get_children()
	children.reverse()
	for child in children:
		if child is Item and child not in _item_deleting_list:
			return false
	return true
	
func get_removed_item()->Item:
	var children = get_children()
	var item = children.pop_back() if not children.is_empty() else null
	if item:
		remove_child(item)
	return item
	
func get_item()->Item:
	var item:Item = null
	var children = get_children()
	children.reverse()
	for child in children:
		if child is Item and child not in _item_deleting_list:
			item = child
	return item

func _ready():
	var items = get_children()
	if items.all(func(item): return true if item is Item else false):
		pass
	else:
		print("Error cell [{0}] _ready() -> item [{1}, {2}] is not Item type.".format([name, x, y]))
		queue_free()
		
func get_item_type()->Item.EItem:
	var children = get_children()
	return children.back().get_item() if not children.is_empty() else Item.EItem.NONE
		
func _get_drag_data(_at_position):
	return self
	
func _can_drop_data(_at_position, data)->bool:
	return true if data is Cell else false
	
func _drop_data(_at_position, data):
	M3Core.on_cell_tap(data, self)

func move_animation(item:Item, new_position:Vector2):
	if _tween_move and _tween_move.is_valid():
		if _tween_move.is_running():
			M3Core.done_event()
		_tween_move.kill()

	_tween_move = create_tween()
	_tween_move.tween_property(item, "position", new_position,  M3Core.move_time)
	_tween_move.tween_callback(M3Core.done_event)
	
func stop_animations():
	if _tween_hint and _tween_hint.is_valid():
		_tween_hint.kill()
		if _animated_item_lambda:
			_animated_item_lambda.call()
			_animated_item_lambda = null

func hint_animation(item:Item):
	stop_animations()
	if _tween_move and _tween_move.is_running():
		await _tween_move.finished

	if _animated_item_lambda:
		print("Error. Lambda from a last hint is not null. ", name)
	_tween_hint = create_tween()
	_tween_hint.set_loops(100)
	var old_scale = item.scale
	var old_position = item.position
	_tween_hint.tween_property(item, "scale", old_scale * M3Core.animation_scale, M3Core.hint_time)
	_tween_hint.parallel().tween_property(item, "position", size * -((M3Core.animation_scale - 1) / 2.0), M3Core.hint_time)
	_tween_hint.tween_property(item, "scale", old_scale, M3Core.hint_time)
	_tween_hint.parallel().tween_property(item, "position", old_position, M3Core.hint_time)
	_animated_item_lambda = func(): if item: item.scale = old_scale; item.position = old_position

# меняем предметы между клетками
func swap(cell_other:Cell):
	# клетки не должны быть дырками или заблокированными
	if not is_hole() and not cell_other.is_hole():# and not is_blocked() and not cell_other.is_blocked():
		# убрать предмет из клетки если есть
		var item_this = get_removed_item()
		var item_other = cell_other.get_removed_item()
		if item_this:
			cell_other.move_item(item_this, position)
		if item_other:
			move_item(item_other, cell_other.position)
	else:
		print("Error. Try swap item from hole or blocked cell [{0},{1}]".format([name, cell_other.name]))

func spawn(item:Item):
	M3Core.add_event()
	if item:
		add_child(item)
		_last_update = Time.get_ticks_msec()
	M3Core.done_event()

func delete_animation(item:Item):
	_tween_delete = create_tween()
	_tween_delete.tween_property(item, "scale", Vector2(0.2, 0.2),  2.0)
	_tween_delete.tween_callback(_delete_done)
	
func _delete_done():
	for item in _item_deleting_list:
		if item != null:
			_last_update = Time.get_ticks_msec()
			item.remove()
			M3Core.done_event()
	_item_deleting_list.clear()

func hit():
	if is_empty():
		return
		
	var item = get_item()
	if item != null:
		_item_deleting_list.append(item)
		if _tween_delete and _tween_delete.is_valid():
			if _tween_delete.is_running():
				_delete_done()
			_tween_delete.kill()
		M3Core.add_event()
		delete_animation(item)

func hint():
	if is_empty():
		return
	var item = get_item()
	if item != null:
		hint_animation(item)
	
func can_move()->bool:
	return not is_empty() and not is_blocked()

func can_spawn()->bool:
	return true if not _is_hole and _is_spawn and is_empty() else false
	
func move_item(item:Item, old_position:Vector2):
	M3Core.add_event()
	add_child(item)
	# метка времени изменения для клетки, чтобы вставлять сматченный предмет на место свапа
	_last_update = Time.get_ticks_msec()
	# сдвигаем предмет в то место откуда предмет пришёл
	item.position = old_position - position
	# проигрываем анимацию перемещения на текущую клетку и по её завершению декрементим пакетный счётчик операций
	move_animation(item, Vector2.ZERO)
