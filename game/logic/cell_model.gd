extends Node

class_name CellModel

var is_hole:bool = false
var is_spawn:bool = false
var items:Array[ItemModel]
var x = -1
var y = -1
var flat_ind = -1

func can_move()->bool:
	return not items.is_empty()
	
func can_receive()->bool:
	return true if not is_hole and items.is_empty() else false
	
func can_spawn()->bool:
	return true if not is_hole and is_spawn and items.is_empty() else false
	
func add_item(item:ItemModel):
	items.append(item)

	
func get_item_type()->Match3Logic.EItemTypes:
	return -1 if items.is_empty() else items.back().type
	
func remove_item():
	items.pop_back()

func swap(from:CellModel):
	if not is_hole or not from.is_hole:
		var tmp_this = items.pop_back()
		var tmp_from = from.items.pop_back()
		if tmp_this and not tmp_this.is_blocked:
			from.items.push_back(tmp_this)
		if tmp_from and not tmp_from.is_blocked:
			items.push_back(tmp_from)
