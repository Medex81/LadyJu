extends GridContainer

class_name GredMatch3

var _cells:Array[Cell]
var _logic: Match3Logic = null
var _items = {
	Match3Logic.EItemTypes.RED: preload("res://game/scenes/game_field/items/item_red.tscn"),
	Match3Logic.EItemTypes.BLUE: preload("res://game/scenes/game_field/items/item_blue.tscn"),
	Match3Logic.EItemTypes.GREEN: preload("res://game/scenes/game_field/items/item_green.tscn"),
	Match3Logic.EItemTypes.PURPLE: preload("res://game/scenes/game_field/items/item_purple.tscn"),
	Match3Logic.EItemTypes.WHITE: preload("res://game/scenes/game_field/items/item_white.tscn"),
	Match3Logic.EItemTypes.YELLOW: preload("res://game/scenes/game_field/items/item_yellow.tscn")
}

func _ready():
	for cell in get_children():
		if cell is Cell:
			_cells.append(cell)
	_logic = Match3Logic.new(columns, _cells.size() / columns)
	
	if _logic:
		var flat_cell_index = 0
		for cell in _cells:
			_logic.set_cell_opt(flat_cell_index, cell.hole, cell.spawn)
			for item in cell.items:
				_logic.set_cell_item(flat_cell_index, item.is_blocked, item.item_type)
			flat_cell_index += 1
	
	if _cells.size() % columns:
		print("Warning > Every row must have the size equal {1}.".format([columns]))
		
func _on_timer_timeout():
	if _logic:
		var result = _logic.update()
		if result.moves.is_empty() and result.spawns.is_empty():
			$Timer.stop()
		else:
			move(result.moves)
			spawn(result.spawns)

func move(moves:Array):
	for swap in moves:
		var node_from = _cells[swap[0]]
		var node_to = _cells[swap[1]]
		var item_from = node_from.items.pop_back()
		var item_to = node_to.items.pop_back()
		if item_from:
			node_from.remove_child(item_from)
			node_to.add_child(item_from)
			node_to.items.append(item_from)
		if item_to:
			node_to.remove_child(item_to)
			node_from.add_child(item_to)
			node_from.items.append(item_to)

func create_item(item_type:Match3Logic.EItemTypes)->Item:
	var item:Item = null
	var _scn = _items.get(item_type, null)
	if _scn:
		item = _scn.instantiate()
	return item

func spawn(spawns:Array):
	for spawn in spawns:
		var item = create_item(spawn[1])
		if item:
			_cells[spawn[0]].add_child(item)
			_cells[spawn[0]].items.append(item)
	
