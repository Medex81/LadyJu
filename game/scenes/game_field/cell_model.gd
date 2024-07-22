extends Node

class_name CellModel

var is_hole:bool = false
var is_creator:bool = false
var x:int = 0
var y:int = 0
var items:Array[ItemModel]

func _init(_x:int, _y:int):
	x = _x
	y = _y
	
func swap(from:CellModel):
	if not is_hole or not from.is_hole:
		var tmp_this = items.pop_back()
		var tmp_from = from.items.pop_back()
		if tmp_this and not tmp_this.is_blocked:
			from.items.push_back(tmp_this)
		if tmp_from and not tmp_from.is_blocked:
			items.push_back(tmp_from)
