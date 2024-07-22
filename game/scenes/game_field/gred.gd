extends GridContainer

class_name GredMatch3

var _cells:Array[Cell]
var _logic: Match3Logic = null

func _ready():
	for cell in get_children():
		if cell is Cell:
			_cells.append(cell)
	_logic = Match3Logic.new(columns, _cells.size() / columns)
	
	if _logic:
		var flat_cell_index = 0
		for cell in _cells:
			_logic.set_cell_opt(flat_cell_index, cell.hole, cell.create)
			for item in cell.items:
				_logic.set_cell_item(flat_cell_index, item.is_blocked, item.item_type)
			flat_cell_index += 1
	
	if _cells.size() % columns:
		print("Warning > Every row must have the size equal {1}.".format([columns]))
		
func _on_timer_timeout():
	if _logic:
		var result = _logic.update()
		if result.moves.is_empty():
			$Timer.stop()
		else:
			move(result.moves)

func move(moves:Array):
	for swap in moves:
		var node_from = _cells[swap[0]]
		var node_to = _cells[swap[1]]
		print("swap {0} {1}".format([swap[0], swap[1]]))
		var item_from = null if node_from.items.is_empty() else node_from.items.back()
		var item_to = null if node_to.items.is_empty() else node_to.items.back()
		print("item from size ", node_from.items.size())
		print("item to size ", node_to.items.size())
		if item_from:
			node_from.remove_child(item_from)
			node_to.add_child(item_from)
			node_to.items.append(item_from)
		if item_to:
			node_to.remove_child(item_to)
			node_from.add_child(item_to)
			node_from.items.append(item_to)

