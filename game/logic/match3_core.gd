extends Node

class_name Match3Logic

enum EItemTypes{
	NONE,
	RED,
	BLUE
}

var _cols:int = 0
var _rows:int = 0
var _size:int = 0
var _cells:Array
var result = UpdateResult.new()

func _init(cols:int, rows:int):
	for col in range(cols):
		var array:Array[CellModel]
		for row in range(rows):
			array.append(CellModel.new(col, row))
		print("Add row size {0}".format([array.size()]))
		_cells.append(array)
	_cols = cols
	_rows = rows
	_size = cols * rows
	
func set_cell_opt(flat_index:int, is_hole:bool, is_creator:bool):
	if flat_index < _size:
		var cell = _cells[flat_index % _cols][flat_index / _cols] as CellModel
		cell.is_hole = is_hole
		cell.is_creator = is_creator
	
func set_cell_item(flat_index:int, is_blocked:bool, type:EItemTypes):
	var cell = _cells[flat_index % _cols][flat_index / _cols] as CellModel
	cell.items.append(ItemModel.new(is_blocked, type))
	
func update()->UpdateResult:
	result.clear()
	for col in range(_cols - 1, -1, -1):
		for row in range(_rows - 1, -1, -1):
			if row + 1 < _rows \
			and not _cells[col][row].is_hole \
			and not _cells[col][row + 1].is_hole \
			and not _cells[col][row].items.is_empty():
				var from_flat_index = _cells[col][row].x + _cells[col][row].y * _cols
				var to_flat_index = _cells[col][row + 1].x + _cells[col][row + 1].y * _cols
				result.moves.append([from_flat_index, to_flat_index])
				_cells[col][row].swap(_cells[col][row + 1])
	return result
