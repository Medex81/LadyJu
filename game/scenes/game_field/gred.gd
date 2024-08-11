extends GridContainer

class_name GredMatch3

var _cells:Array[Cell]
var _logic:Match3Logic = null
var _event_counter = 0
@export var hint_delay:float = 3.0
@export var sound_volume:float = 0.5
@export var background_music: AudioStream

#TODO завести бинд типов в свойства сетки
var _items = {
	Match3Logic.EItemTypes.RED: preload("res://game/scenes/game_field/items/item_red.tscn"),
	Match3Logic.EItemTypes.BLUE: preload("res://game/scenes/game_field/items/item_blue.tscn"),
	Match3Logic.EItemTypes.GREEN: preload("res://game/scenes/game_field/items/item_green.tscn"),
	Match3Logic.EItemTypes.PURPLE: preload("res://game/scenes/game_field/items/item_purple.tscn"),
	Match3Logic.EItemTypes.WHITE: preload("res://game/scenes/game_field/items/item_white.tscn"),
	Match3Logic.EItemTypes.YELLOW: preload("res://game/scenes/game_field/items/item_yellow.tscn")
}

func _ready():
	$Timer_hint_delay.wait_time = hint_delay
	SoundManager.set_sound_volume(sound_volume)
	SoundManager.play_ambient_sound(background_music)
	for cell in get_children():
		if cell is Cell:
			_cells.append(cell)
			cell.send_tap.connect(_on_cell_tap)
	_logic = Match3Logic.new(columns, _cells.size() / columns)
	
	if _logic:
		var flat_cell_index = 0
		for cell in _cells:
			_logic.set_cell_opt(flat_cell_index, cell.is_hole, cell.is_spawn)
			for item in cell.items:
				_logic.set_cell_item(flat_cell_index, item.is_blocked, item.item_type)
			flat_cell_index += 1
		_logic.end_init()
	if _cells.size() % columns:
		print("Warning > Every row must have the size equal {1}.".format([columns]))
		
	call_deferred("_update")
			
func _on_timer_hint_delay_timeout():
	var hint_indexs = _logic.hint()
	for index in hint_indexs:
		_cells[index].hint()
		
func move(moves:Array):
	for _swap in moves:
		_cells[_swap[0]].swap(_cells[_swap[1]])
	if not moves.is_empty():
		_cells[moves.back().back()].emit_sound()
	
func create_item(item_type:Match3Logic.EItemTypes)->Item:
	var item:Item = null
	var _scn = _items.get(item_type, null)
	if _scn:
		item = _scn.instantiate()
	return item

func spawn(spawns:Array):
	for _spawn in spawns:
		_cells[_spawn[0]].spawn(create_item(_spawn[1]))
	
func delete(deletes:Array):
	for index in deletes:
		_cells[index].delete()
	
func _on_cell_tap(cell_first:Cell, cell_second:Cell):
	var first = _cells.find(cell_first)
	var second = _cells.find(cell_second)
	if _logic and _logic.swap(first, second):
		$Timer_hint_delay.stop()
		get_tree().call_group("stop_cell_animations", "stop_hint_animations")
		# tap flag - true, dont calculate counter
		cell_first.swap(cell_second, true)
		call_deferred("_update")
		
func _update():
	if _logic:
		var result = _logic.update()
		if not result.is_empty():
			if _event_counter > 0:
				print("Error update-> Event count ", _event_counter)
				return
			_event_counter = result.event_count()
			delete(result.deletes)
			spawn(result.spawns)
			move(result.moves)
			if _event_counter:
				$Timer_hint_delay.start()
			#_check_model()
				
#func _check_model():
	#var index = 0;
	#for cell in _cells:
		#if _logic.get_cell_type(index) != cell.get_item_type():
			#print("Error! type cell not equal. model ", _logic.get_cell_type(index), ", UI ", cell.get_item_type(), ", index ", index)
		#index += 1
		
#func _unhandled_input(event):
	#if event is InputEventKey and event.is_pressed():
		#_update()

func done_event():
	_event_counter -= 1
	if _event_counter <= 0:
		_event_counter = 0
		call_deferred("_update")
