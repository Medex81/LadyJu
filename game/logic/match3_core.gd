extends Node

class_name Match3Logic

enum EItemTypes{
	RED,
	BLUE,
	GREEN,
	PURPLE,
	WHITE,
	YELLOW
}

var _cols:int = 0
var _rows:int = 0
var _size:int = 0
var _cells:Array
var _result:UpdateResult = UpdateResult.new()
var _spawn_index:int = 0

func _init(cols:int, rows:int):
	for col in range(cols):
		var array:Array[CellModel]
		for row in range(rows):
			array.append(CellModel.new())
		print("Add row size {0}".format([array.size()]))
		_cells.append(array)
	_cols = cols
	_rows = rows
	_size = cols * rows
	
func set_cell_opt(flat_index:int, is_hole:bool, is_spawn:bool):
	if flat_index < _size:
		var cell = _cells[flat_index % _cols][flat_index / _cols] as CellModel
		cell.is_hole = is_hole
		cell.is_spawn = is_spawn
	
func set_cell_item(flat_index:int, is_blocked:bool, type:EItemTypes):
	var cell = _cells[flat_index % _cols][flat_index / _cols] as CellModel
	cell.items.append(ItemModel.new(is_blocked, type))

func move_if_can(col:int, row:int, shift:int, result:UpdateResult)->bool:
	if col + shift >= 0 \
	and col + shift < _cols \
	and _cells[col + shift][row + 1].can_receive():
		var from_flat_index = col + row * _cols
		var to_flat_index = col + shift + (row + 1) * _cols
		result.moves.append([from_flat_index, to_flat_index])
		_cells[col][row].swap(_cells[col + shift][row + 1])
		return true
	return false
	
func spawn(col:int, row:int, result:UpdateResult):
	var new_item = _spawn_index
	_spawn_index += 1
	if _spawn_index == EItemTypes.size():
		_spawn_index = 0
	_cells[col][row].add_item(ItemModel.new(false, new_item))
	var in_flat_index = col + row * _cols
	_result.spawns.append([in_flat_index, new_item])
	
func update()->UpdateResult:
	_result.clear()
	for col in range(_cols - 1, -1, -1):
		for row in range(_rows - 2, -1, -1):
			# move
			if _cells[col][row].can_move():
				if not move_if_can(col, row, 0, _result):
					if not move_if_can(col, row, 1, _result):
						move_if_can(col, row, -1,  _result)
				continue
					
			# spawn
			if _cells[col][row].can_spawn():
				spawn(col, row, _result)
				continue

	return _result
