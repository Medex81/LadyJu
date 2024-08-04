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

enum EDirect{DOWN = 0, LEFT = -1, RIGHT = 1}

var _cols:int = 0
var _rows:int = 0
var _size:int = 0
var _cells:Array
var _cells_spawnable:Array
var _cells_auto_movable:Array
var _result:UpdateResult = UpdateResult.new()
var _spawn_index:int = 0

func _init(cols:int, rows:int):
	for col in range(cols):
		var array:Array[CellModel]
		for row in range(rows):
			array.append(CellModel.new())
		_cells.append(array)
	_cols = cols
	_rows = rows
	_size = cols * rows
	
func set_cell_opt(flat_index:int, is_hole:bool, is_spawn:bool):
	if flat_index < _size:
		var cell = _cells[flat_index % _cols][flat_index / _cols] as CellModel
		cell.is_hole = is_hole
		cell.is_spawn = is_spawn
		cell.x = flat_index % _cols
		cell.y = flat_index / _cols
		cell.flat_ind = flat_index
		if is_spawn:
			_cells_spawnable.append(cell)
		if not is_hole and cell.y < _rows - 1:
			_cells_auto_movable.append(cell)
			
func end_init():
	_cells_auto_movable.reverse()
	
func set_cell_item(flat_index:int, is_blocked:bool, type:EItemTypes):
	var cell = _cells[flat_index % _cols][flat_index / _cols] as CellModel
	cell.items.append(ItemModel.new(is_blocked, type))

func _move_if_can(cell:CellModel, shift:EDirect, moves:Array)->bool:
	if cell.x + shift >= 0 and  cell.x + shift < _cols:
		var other_cell = _cells[cell.x + shift][cell.y + 1] as CellModel
		if other_cell.can_receive():
			moves.append([cell.flat_ind, other_cell.flat_ind])
			cell.swap(other_cell)
			return true
	return false
	
func _spawn(cell:CellModel, spawns:Array):
	var new_item = _spawn_index
	_spawn_index += 1
	if _spawn_index == EItemTypes.size():
		_spawn_index = 0
	cell.add_item(ItemModel.new(false, new_item))
	spawns.append([cell.flat_ind, new_item])

func swap(index_first:int, index_second:int)->bool:
	var col_first = index_first % _cols
	var row_first = index_first / _cols
	
	var col_second = index_second % _cols
	var row_second = index_second / _cols
	
	var cell_first = _cells[col_first][row_first]
	var cell_second = _cells[col_second][row_second]
	
	
	if absi(col_first - col_second) + absi(row_first - row_second) == 1 \
	and cell_first.can_move() and cell_second.can_move():
		cell_first.swap(cell_second)
		if _is_match(col_first, row_first) or _is_match(col_second, row_second):
			return true
		else:
			cell_first.swap(cell_second)
	return false
	
func _is_match(col:int, row:int)->bool:
	var accum = 1
	var is_match_with_current = false
	for i in range(_cols):
		if i < _cols - 1 and _cells[i][row].get_item_type() > -1 and _cells[i][row].get_item_type() == _cells[i + 1][row].get_item_type():
			accum += 1
			if i == col or i + 1 == col:
				is_match_with_current = true
		else:
			if accum > 2 and is_match_with_current:
				return true
			accum = 1
			
	for i in range(_rows):
		if i < _rows - 1 and _cells[col][i].get_item_type() > -1 and _cells[col][i].get_item_type() == _cells[col][i + 1].get_item_type():
			accum += 1
			if i == row or i + 1 == row:
				is_match_with_current = true
		else:
			if accum > 2 and is_match_with_current:
				return true
			accum = 1
			
	return false
	
func _match()->Array:
	var accum = 1
	var removes:Array
	var remove:Array
	
	for col in range(_cols):
		for row in range(_rows):
			if row < _rows - 1 and _cells[col][row].get_item_type() > -1 and _cells[col][row].get_item_type() == _cells[col][row + 1].get_item_type():
				accum += 1
				remove.append([col, row])
			else:
				if accum > 2:
					remove.append([col, row])
					removes.append_array(remove)
				accum = 1
				remove.clear()
	for row in range(_rows):
		for col in range(_cols):
			if col < _cols - 1 and _cells[col][row].get_item_type() > -1 and _cells[col][row].get_item_type() == _cells[col + 1][row].get_item_type():
				accum += 1
				remove.append([col, row])
			else:
				if accum > 2:
					remove.append([col, row])
					removes.append_array(remove)
				accum = 1
				remove.clear()
			
	if not removes.is_empty():
		for cell in removes:
			_cells[cell[0]][cell[1]].remove_item()
	return removes
	
func array_unique(array: Array):
	array.sort()
	for i in range(array.size() - 2, -1, -1):
		if array[i] == array[i + 1]:
			array.remove_at(i + 1)
	
func arr_to_flat(arr:Array)->Array[int]:
	var result:Array[int]
	if not arr.is_empty():
		for cell in arr:
			result.append(_cells[cell[0]][cell[1]].flat_ind)
	return result
	
func update()->UpdateResult:
	_result.clear()
	
	#delete matches
	_result.deletes = arr_to_flat(_match())
	array_unique(_result.deletes)
	if not _result.deletes.is_empty():
		return _result
	
	#spawn
	for cell in _cells_spawnable:
		if cell.can_spawn():
			_spawn(cell, _result.spawns)
	if not _result.spawns.is_empty():
		return _result
	
	#move down
	for cell in _cells_auto_movable:
		cell.can_move() and _move_if_can(cell, EDirect.DOWN, _result.moves)
	if not _result.moves.is_empty():
		return _result
		
	#move left/right
	for cell in _cells_auto_movable:
		if cell.can_move() and (_move_if_can(cell, EDirect.LEFT, _result.moves) or _move_if_can(cell, EDirect.RIGHT, _result.moves)):
			return _result
					
	return _result
