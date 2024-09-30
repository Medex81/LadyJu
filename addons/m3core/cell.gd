@tool
extends Control

class_name Cell

var _color_on:Color = Color(0.35,0.62,0.83,0.41)
var _color_off:Color = Color(0,0,0,0)
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
	var item = get_item()
	return true if item and item.is_common() else false
	
func is_matched()->bool:
	var item = get_item()
	return true if item and item.is_matched() else false
	
func is_blocked()->bool:
	var item = get_item()
	return true if item and item.is_blocked() else false
	
func is_empty()->bool:
	var item = get_item()
	return true if item == null else false
	
func get_item()->Item:
	var item:Item = null
	var children = get_children()
	children.reverse()
	for child in children:
		if child is Item and child not in _item_deleting_list:
			item = child
	return item

func get_item_type()->Item.EItem:
	var item = get_item()
	return item.get_item() if item else Item.EItem.NONE

func _get_drag_data(_at_position):
	return self
	
func _can_drop_data(_at_position, data)->bool:
	return true if data is Cell else false
	
func _drop_data(_at_position, data):
	M3Core.on_cell_tap(data, self)

func hint_stop():
	var item = get_item()
	if item and item.has_method("hint_stop"):
		item.hint_stop()

# меняем предметы между клетками
func swap(cell_other:Cell):
	# клетки не должны быть дырками или заблокированными
	if not is_hole() and not cell_other.is_hole():# and not is_blocked() and not cell_other.is_blocked():
		# убрать предмет из клетки если есть
		var item_this = get_item()
		var item_other = cell_other.get_item()
		if item_this:
			cell_other.add_item(item_this)
		if item_other:
			add_item(item_other)
	else:
		print("Error. Try swap item from hole or blocked cell [{0},{1}]".format([name, cell_other.name]))

func spawn(item:Item):
	if item:
		M3Core.add_event()
		add_child(item)
		_last_update = Time.get_ticks_msec()
		M3Core.done_event()

func hit():
	if is_empty():
		return
		
	var item = get_item()
	if item != null:
		_item_deleting_list.append(item)
		item.delete()

func hint():
	var item = get_item()
	if item and item.has_method("hints"):
		item.hints()

func can_move()->bool:
	var item = get_item()
	return item and not item.is_component_running() and not item.is_blocked()

func can_spawn()->bool:
	return true if not _is_hole and _is_spawn and is_empty() else false
	
func add_item(item:Item)->bool:
	if item:
		var old_parent = item.get_parent()
		if old_parent != get_parent():
			# сдвигаем предмет в то место откуда предмет пришёл
			item.position = old_parent.position - position
			old_parent.remove_child(item)
			add_child(item)
			# метка времени изменения для клетки, чтобы вставлять сматченный предмет на место свапа
			_last_update = Time.get_ticks_msec()
			item.move(Vector2.ZERO)
	return false
