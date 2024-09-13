@tool
extends Control

class_name Cell

var _color_on:Color = Color(0.35,0.62,0.83,0.41)
var _color_off:Color = Color(0,0,0,0)
var _tween_move:Tween = null
var _tween_hint:Tween = null
var _animated_item_lambda = null
var x = -1
var y = -1
var _last_update:int = Time.get_ticks_msec()

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

signal send_tap(control_first:Control, control_second:Control)

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
	return get_children().is_empty()
	
func get_removed_item()->Item:
	var children = get_children()
	var item = children.pop_back() if not children.is_empty() else null
	if item:
		remove_child(item)
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
	send_tap.emit(data, self)

func move_animation(item:Item, new_position:Vector2):
	if _tween_move and _tween_move.is_valid():
		if _tween_move.is_running():
			_done()
		_tween_move.kill()

	_tween_move = create_tween()
	_tween_move.tween_property(item, "position", new_position,  get_parent().move_time)
	_tween_move.tween_callback(_done)
	
func _done(count:int = 1):
	get_parent().done_event(count)
	
func _add_event_counts(count:int = 1):
	get_parent().add_event(count)
	
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
	_tween_hint.tween_property(item, "scale", old_scale * get_parent().animation_scale, get_parent().hint_time)
	_tween_hint.parallel().tween_property(item, "position", size * -((get_parent().animation_scale - 1) / 2.0), get_parent().hint_time)
	_tween_hint.tween_property(item, "scale", old_scale, get_parent().hint_time)
	_tween_hint.parallel().tween_property(item, "position", old_position, get_parent().hint_time)
	_animated_item_lambda = func(): if item: item.scale = old_scale; item.position = old_position

# меняем предметы между клетками
func swap(cell_other:Cell):
	_add_event_counts(2)
	# клетки не должны быть дырками или заблокированными
	if not is_hole() and not cell_other.is_hole():# and not is_blocked() and not cell_other.is_blocked():
		# убрать предмет из клетки если есть
		var item_this = get_removed_item()
		var item_other = cell_other.get_removed_item()
		if item_this:
			cell_other.add_item(item_this, position)
		else:
			# декремент счётчика операций без проигрывания анимации
			_done()
		if item_other:
			add_item(item_other, cell_other.position)
		else:
			_done()
	else:
		print("Error. Try swap item from hole or blocked cell [{0},{1}]".format([name, cell_other.name]))
		_done(2)
		
func spawn(item:Item):
	_add_event_counts()
	if item:
		add_child(item)
		_last_update = Time.get_ticks_msec()
	_done()
			
func delete_item():
	if is_empty():
		print("Error. Try removing item from empty cell ", name)
		return
	var item = get_removed_item()
	if item:
		if _tween_move and _tween_move.is_valid():
			if _tween_move.is_running():
				_done()
			_tween_move.kill()
		_last_update = Time.get_ticks_msec()
		item.queue_free()
		item = null
	
func hint():
	if is_empty():
		print("Error. Try hint item from empty cell ", name)
		return
	hint_animation(get_children().back())
	
func can_move()->bool:
	return not is_empty() and not is_blocked()

func can_spawn()->bool:
	return true if not _is_hole and _is_spawn and is_empty() else false
	
func add_item(item:Item, old_position:Vector2):
	add_child(item)
	# метка времени изменения для клетки, чтобы вставлять сматченный предмет на место свапа
	_last_update = Time.get_ticks_msec()
	# сдвигаем предмет в то место откуда предмет пришёл
	item.position = old_position - position
	# проигрываем анимацию перемещения на текущую клетку и по её завершению декрементим пакетный счётчик операций
	move_animation(item, Vector2.ZERO)

