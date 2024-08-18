extends Node

class_name Match3Logic

enum EItemTypes{
	NONE,
	# матчевые предметы
	ROCKET_LINE_H, # 4, урон по горизонтали на всю длину
	ROCKET_LINE_V,  # 4, урон по вертикали на всю длину
	BOMB, # 5, урон 9 клеток с текущей в центре
	AMULET, # 6, урон по всем клеткам имеющим предмет с которым свапнулись
	BOMB_TOTAL, # 7, урон по всем клеткам
	# нематчевые предметы
	RED,# <- этот тип должен всегда быть первым!
	BLUE,
	GREEN,
	PURPLE,
	WHITE, # <- новые типы не матчевых предметов вставляем тут!
	YELLOW, # <- этот тип должен всегда быть последним, позади него ничего не ставим!
	# блокеры
	GLASS,
	CHAIN,
	NODE_NET
}

enum EDirect{DOWN = 0, LEFT = -1, RIGHT = 1, TOP, TOP_LEFT, TOP_RIGHT, DOWN_LEFT, DOWN_RIGHT}

var _cols:int = 0
var _rows:int = 0
var _size:int = 0
var _cells:Array
var _cells_spawnable:Array
var _cells_auto_movable:Array
var _cells_hintable:Array
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
		if not is_hole:
			_cells_hintable.append(cell)
			
func end_init():
	_cells_auto_movable.reverse()
	
func set_cell_item(flat_index:int, is_blocked:bool, type:EItemTypes):
	var cell = _cells[flat_index % _cols][flat_index / _cols] as CellModel
	cell.items.append(ItemModel.new(is_blocked, type))

func _move_if_can(cell:CellModel, shift:EDirect, moves:Array)->bool:
	if cell.x + shift >= 0 and  cell.x + shift < _cols and cell.y + 1 < _rows:
		var other_cell = _cells[cell.x + shift][cell.y + 1] as CellModel
		if other_cell.is_empty():
			cell.swap(other_cell)
			moves.append([cell.flat_ind, other_cell.flat_ind])
			return true
	return false
	
func _spawn(cell:CellModel, spawns:Array):
	_spawn_index += 1
	if _spawn_index > EItemTypes.YELLOW:
		_spawn_index = EItemTypes.RED
	cell.add_item(ItemModel.new(false, _spawn_index))
	spawns.append([cell.flat_ind, _spawn_index])

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
		if i < _cols - 1 and _cells[i][row].get_item_type() > EItemTypes.NONE and _cells[i][row].get_item_type() == _cells[i + 1][row].get_item_type():
			accum += 1
			if i == col or i + 1 == col:
				is_match_with_current = true
		else:
			if accum > 2 and is_match_with_current:
				return true
			accum = 1
			
	for i in range(_rows):
		if i < _rows - 1 and _cells[col][i].get_item_type() > EItemTypes.NONE and _cells[col][i].get_item_type() == _cells[col][i + 1].get_item_type():
			accum += 1
			if i == row or i + 1 == row:
				is_match_with_current = true
		else:
			if accum > 2 and is_match_with_current:
				return true
			accum = 1
			
	return false

# проходим по строкам и столбцам в поисках предметов с одинаковым типом идущих подряд.
func _match()->Array:
	# количество подряд встретившихся предметов
	var accum = 0
	# общий список последовательностей предметов
	var removes:Array
	# последовательность предметов которую мы нашли
	var match_arr:Array[CellModel]
	# проверяем вертикально по столбцам
	for col in range(_cols):
		for row in range(_rows):
			if row < _rows - 1 and _cells[col][row].get_item_type() > EItemTypes.NONE and _cells[col][row].get_item_type() == _cells[col][row + 1].get_item_type():
				accum += 1
				match_arr.append(_cells[col][row])
			else:
				# добавляем последний найденный предмет в текущую последовательность
				if accum > 1:
					match_arr.append(_cells[col][row])
					removes.append(match_arr.duplicate())
				accum = 0
				match_arr.clear()
	# проверяем горизонтально по строкам
	for row in range(_rows):
		for col in range(_cols):
			if col < _cols - 1 and _cells[col][row].get_item_type() > EItemTypes.NONE and _cells[col][row].get_item_type() == _cells[col + 1][row].get_item_type():
				accum += 1
				match_arr.append(_cells[col][row])
			else:
				if accum > 1:
					match_arr.append(_cells[col][row])
					removes.append(match_arr.duplicate())
				accum = 0
				match_arr.clear()
			
	if not removes.is_empty():
		# найти пересечения(если есть) и слить в один массив по сборкам
		var curr_match = false
		for i in range(0, removes.size()):
			curr_match = false
			if removes[i].is_empty() or i + 1 >= removes.size():
				continue
			for j in range(i + 1, removes.size()):
				if not removes[i].is_empty() and not removes[j].is_empty():
					for cell in removes[i]:
						if removes[j].has(cell):
							removes[j].erase(cell)
							removes[i].append_array(removes[j])
							removes[j].clear()
							curr_match = true
							break
				if curr_match:
					break
	return removes
	
func _neighbour_cell(cell:CellModel, direct:EDirect)->CellModel:
	match direct:
		EDirect.TOP:
			if cell.y - 1 >= 0:
				return _cells[cell.x][cell.y - 1]
		EDirect.TOP_RIGHT:
			if cell.y - 1 >= 0 and cell.x + 1 < _cols:
				return _cells[cell.x + 1][cell.y - 1]
		EDirect.RIGHT:
			if cell.x + 1 < _cols:
				return _cells[cell.x + 1][cell.y]
		EDirect.DOWN_RIGHT:
			if cell.y + 1 < _rows and cell.x + 1 < _cols:
				return _cells[cell.x + 1][cell.y + 1]
		EDirect.DOWN:
			if cell.y + 1 < _rows:
				return _cells[cell.x][cell.y + 1]
		EDirect.DOWN_LEFT:
			if cell.y + 1 < _rows and cell.x - 1 >= 0:
				return _cells[cell.x - 1][cell.y + 1]
		EDirect.LEFT:
			if cell.x - 1 >= 0:
				return _cells[cell.x - 1][cell.y]
		EDirect.TOP_LEFT:
			if cell.y - 1 >= 0 and cell.x - 1 >= 0:
				return _cells[cell.x - 1][cell.y - 1]
	return null
	
func _cell_hintable(cell:CellModel, direct:EDirect, type:EItemTypes = EItemTypes.NONE)->bool:
	if type == EItemTypes.NONE:
		type = cell.get_item_type()
	var other_cell:CellModel = _neighbour_cell(cell, direct)
	if other_cell and other_cell.can_move() and other_cell.get_item_type() == type:
		return true
	return false
	
func _find_pair()->Array:
	var accum = 1
	var _pair:Array[CellModel]
	var _find:Array
	
	for col in range(_cols):
		for row in range(_rows):
			if row < _rows - 1 and _cells[col][row].can_move() and _cells[col][row].get_item_type() == _cells[col][row + 1].get_item_type():
				accum += 1
				_pair.append(_cells[col][row])
			else:
				if accum == 2:
					_pair.append(_cells[col][row])
					_find.append(_pair.duplicate())
				accum = 1
				_pair.clear()
	for row in range(_rows):
		for col in range(_cols):
			if col < _cols - 1 and _cells[col][row].can_move() and _cells[col][row].get_item_type() == _cells[col + 1][row].get_item_type():
				accum += 1
				_pair.append(_cells[col][row])
			else:
				if accum == 2:
					_pair.append(_cells[col][row])
					_find.append(_pair.duplicate())
				accum = 1
				_pair.clear()
			
	return _find
	
func _check_pair(cell:CellModel, cell_second:CellModel, direct:EDirect)->Array[int]:
	var result:Array[int]
	var direct_1 = EDirect.LEFT if direct == EDirect.TOP or direct == EDirect.DOWN else EDirect.TOP
	var direct_2 = EDirect.RIGHT if direct == EDirect.TOP or direct == EDirect.DOWN else EDirect.DOWN
	
	var _m = _neighbour_cell(cell, direct) as CellModel 
	if _m and _m.can_move():
		var _md = _cell_hintable(_m, direct, cell.get_item_type()) as bool
		var _d1 = _cell_hintable(_m, direct_1, cell.get_item_type()) as bool
		var _d2 = _cell_hintable(_m, direct_2, cell.get_item_type()) as bool
		if _md:
			result.append(_neighbour_cell(_m, direct).flat_ind)
		elif _d1:
			result.append(_neighbour_cell(_m, direct_1).flat_ind)
		elif _d2:
			result.append(_neighbour_cell(_m, direct_2).flat_ind)
			
	if not result.is_empty():
		result.append(cell.flat_ind)
		result.append(cell_second.flat_ind)
	return result
	
func hint()->Array[int]:
	var result:Array[int]
	# diagonal find
	for cell in _cells_hintable:
		var _tr = _cell_hintable(cell, EDirect.TOP_RIGHT) as bool
		var _tl = _cell_hintable(cell, EDirect.TOP_LEFT) as bool
		var _dr = _cell_hintable(cell, EDirect.DOWN_RIGHT) as bool
		var _dl = _cell_hintable(cell, EDirect.DOWN_LEFT) as bool
		
		var _t = _neighbour_cell(cell, EDirect.TOP) as CellModel
		var _r = _neighbour_cell(cell, EDirect.RIGHT) as CellModel
		var _d = _neighbour_cell(cell, EDirect.DOWN) as CellModel
		var _l = _neighbour_cell(cell, EDirect.LEFT) as CellModel
		
		if _tl and _tr and _t and _t.can_move():
			result.append(_neighbour_cell(cell, EDirect.TOP_RIGHT).flat_ind)
			result.append(_neighbour_cell(cell, EDirect.TOP_LEFT).flat_ind)
		elif _tr and _dr and _r and _r.can_move():
			result.append(_neighbour_cell(cell, EDirect.TOP_RIGHT).flat_ind)
			result.append(_neighbour_cell(cell, EDirect.DOWN_RIGHT).flat_ind)
		elif _dr and _dl and _d and _d.can_move():
			result.append(_neighbour_cell(cell, EDirect.DOWN_LEFT).flat_ind)
			result.append(_neighbour_cell(cell, EDirect.DOWN_RIGHT).flat_ind)
		elif _dl and _tl and _l and _l.can_move():
			result.append(_neighbour_cell(cell, EDirect.DOWN_LEFT).flat_ind)
			result.append(_neighbour_cell(cell, EDirect.TOP_LEFT).flat_ind)
		
		if not result.is_empty():
			result.append(cell.flat_ind)
			return result
			
	# vert/hor find
	var pairs = _find_pair()
	for pair in pairs:
		if not pair.is_empty():
			# vert
			if pair[0].x == pair[1].x:
				# top
				result = _check_pair(pair[0], pair[1], EDirect.TOP)
				if not result.is_empty():
					return result
				# down
				result = _check_pair(pair[1], pair[0], EDirect.DOWN)
				if not result.is_empty():
					return result
			# hor
			else:
				# left
				result = _check_pair(pair[0], pair[1], EDirect.LEFT)
				if not result.is_empty():
					return result
				# right
				result = _check_pair(pair[1], pair[0], EDirect.RIGHT)
				if not result.is_empty():
					return result

	print("No combinations!")
	return result
	
func has_hint()->bool:
	# diagonal find
	for cell in _cells_hintable:
		var _tr = _cell_hintable(cell, EDirect.TOP_RIGHT) as bool
		var _tl = _cell_hintable(cell, EDirect.TOP_LEFT) as bool
		var _dr = _cell_hintable(cell, EDirect.DOWN_RIGHT) as bool
		var _dl = _cell_hintable(cell, EDirect.DOWN_LEFT) as bool
		
		var _t = _neighbour_cell(cell, EDirect.TOP) as CellModel
		var _r = _neighbour_cell(cell, EDirect.RIGHT) as CellModel
		var _d = _neighbour_cell(cell, EDirect.DOWN) as CellModel
		var _l = _neighbour_cell(cell, EDirect.LEFT) as CellModel
		
		if (_tl and _tr and _t and _t.can_move()) or \
		(_tr and _dr and _r and _r.can_move()) or \
		(_dr and _dl and _d and _d.can_move()) or \
		(_dl and _tl and _l and _l.can_move()):
			return true
			
	# vert/hor find
	var pairs = _find_pair()
	for pair in pairs:
		if not pair.is_empty():
			# vert
			if pair[0].x == pair[1].x:
				# top, down
				if not _check_pair(pair[0], pair[1], EDirect.TOP).is_empty() or not _check_pair(pair[1], pair[0], EDirect.DOWN).is_empty():
					return true
			# hor
			else:
				# left, right
				if not _check_pair(pair[0], pair[1], EDirect.LEFT).is_empty() or not _check_pair(pair[1], pair[0], EDirect.RIGHT).is_empty():
					return true

	print("No combinations!")
	return false
	
func shuffle()->UpdateResult:
	_result.clear()
	var shuffle_cells:Array[CellModel]
	for cell_arr in _cells:
		for cell in cell_arr:
			if cell.can_move():
				shuffle_cells.append(cell)
	for cell in shuffle_cells:
		var i = randi_range(0, shuffle_cells.size() - 1)
		cell.swap(shuffle_cells[i])
		_result.moves.append([cell.flat_ind, shuffle_cells[i].flat_ind])
		
	return _result
	
func delete_top_movable()->UpdateResult:
	_result.clear()
	for cell_arr in _cells:
		for cell in cell_arr:
			#delete
			if cell.remove_item():
				_result.deletes.append(cell.flat_ind)
	return _result

func _spawn_match_item(_item_type:EItemTypes, src_arr:Array[CellModel], spawn_arr:Array):
	# в клетку в которую перемещали предмет записываем дату, сматченный предмет вставляем в клетку с самой поздней датой.
	var cell = _get_last_updated_cell(src_arr)
	if cell:
		match src_arr.size():
			4:# ROCKET_LINE_V or ROCKET_LINE_H
				var type = EItemTypes.ROCKET_LINE_V if src_arr[0].x == src_arr[1].x else EItemTypes.ROCKET_LINE_H
				cell.add_item(ItemModel.new(false, type))
				spawn_arr.append([cell.flat_ind, type])
			5:# BOMB
				cell.add_item(ItemModel.new(false, EItemTypes.BOMB))
				spawn_arr.append([cell.flat_ind, EItemTypes.BOMB])
			6:# AMULET
				cell.add_item(ItemModel.new(false, EItemTypes.AMULET))
				spawn_arr.append([cell.flat_ind, EItemTypes.AMULET])
			7:# BOMB_TOTAL
				cell.add_item(ItemModel.new(false, EItemTypes.BOMB_TOTAL))
				spawn_arr.append([cell.flat_ind, EItemTypes.BOMB_TOTAL])
	else:
		print("Erorr. _spawn_match_item(_get_last_updated_cell) is null.")
				
# на моделях клеток ставим метки времени последнего изменения, это нужно для определения позиции вставки предмета. 
func _get_last_updated_cell(arr:Array[CellModel])->CellModel:
	var update_time:int = 0
	var cell:CellModel = null
	for _cell in arr:
		if _cell.last_update > update_time:
			update_time = _cell.last_update
			cell = _cell
	return cell
	
func update()->UpdateResult:
	_result.clear()
	# не менять последовательность! удаление - создание - перемещение
	 
	# удаление последовательностей.
	# находим последовательности, они будут в виде списков указателей на модели клеток собранных с пересечениями.
	var removes = _match()
	if not removes.is_empty():
		var match_item_type:EItemTypes = EItemTypes.NONE
		for arr in removes:
			if not arr.is_empty():
				# добавим список плоских индексов для удаления топ предметов в представлении
				_result.deletes.append_array(arr.map(func(cell:CellModel):return cell.flat_ind))
				# запомним тип предметов сматченной последовательности(будем использовать для связанных с типом предметов).
				match_item_type = arr.back().get_item_type()
				# удалить все топовые предметы из клеток.
				# при удалении не обновлять метку времени для правильного выбора позиции вставляемого предмета(последний перемещённый).
				for cell in arr:
					cell.remove_item(false)
				# подобрать и вставить предмет по типу матча и количеству.
				_spawn_match_item(match_item_type, arr, _result.spawns)
	# разделяем изменения на поле на отдельные наборы шагов иначе всё смешается в кучу.
	if not _result.deletes.is_empty():
		return _result
	
	# создаем предметы в клетках спавна если они пустые
	for cell in _cells_spawnable:
		if cell.can_spawn():
			_spawn(cell, _result.spawns)
	if not _result.spawns.is_empty():
		return _result
	
	# перемещаем предметы между клетками, сначала вниз для создания эффекта падения.
	for cell in _cells_auto_movable:
		cell.can_move() and _move_if_can(cell, EDirect.DOWN, _result.moves)
	if not _result.moves.is_empty():
		return _result
		
	# перемещаем предметы влево или вправо
	for cell in _cells_auto_movable:
		if cell.can_move() and (_move_if_can(cell, EDirect.LEFT, _result.moves) or _move_if_can(cell, EDirect.RIGHT, _result.moves)):
			return _result
					
	return _result

func get_cell_type(flat_index:int)->EItemTypes:
	var cell = _cells[flat_index % _cols][flat_index / _cols] as CellModel
	return cell.get_item_type()
