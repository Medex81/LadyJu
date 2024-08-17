extends Node

class_name CellModel

var is_hole:bool = false
var is_spawn:bool = false
var items:Array[ItemModel]
var x = -1
var y = -1
var flat_ind = -1
var last_update:int = Time.get_ticks_msec()

func can_move()->bool:
	return not items.is_empty()
	
func is_empty()->bool:
	return true if not is_hole and items.is_empty() else false
	
func can_spawn()->bool:
	return true if not is_hole and is_spawn and items.is_empty() else false
	
func is_blocked()->bool:
	return true if is_hole or (not items.is_empty() and items.back().is_blocked) else false
	
func add_item(item:ItemModel):
	last_update = Time.get_ticks_msec()
	items.append(item)

func get_item_type()->Match3Logic.EItemTypes:
	return Match3Logic.EItemTypes.NONE if items.is_empty() else items.back().type
	
func remove_item(is_updated:bool = true)->bool:
	if is_updated:
		last_update = Time.get_ticks_msec()
	if not is_blocked():
		items.pop_back()
		return true
	return false

func swap(from:CellModel):
	if not is_hole or not from.is_hole:
		var tmp_this = items.pop_back()
		var tmp_from = from.items.pop_back()
		if tmp_this and not tmp_this.is_blocked:
			from.items.push_back(tmp_this)
			from.last_update = Time.get_ticks_msec()
		if tmp_from and not tmp_from.is_blocked:
			items.push_back(tmp_from)
			last_update = Time.get_ticks_msec()
