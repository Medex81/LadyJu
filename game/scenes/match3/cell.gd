@tool
extends CellBase

class_name Cell

func hint_stop():
	var item = get_item()
	if item and item.has_method("hint_stop"):
		item.hint_stop()

func hint():
	var item = get_item()
	if item and item.has_method("hints"):
		item.hints()
		
func move(item:Item, move_to:Vector2):
	if item and item.has_method("move"):
		item.move(move_to)
		
func delete(item:Item):
	if item and item.has_method("delete"):
		item.delete()
