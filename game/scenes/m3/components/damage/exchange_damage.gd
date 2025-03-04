extends BaseDamageComponent

class_name ExchangeDamageComponent

@export var change_percent:float = 0.5
@export var group_crystals = "crystals"

func start(item_name = null):
	if item_name is String and not item_name.is_empty():
		var crystals_arr = get_tree().get_nodes_in_group(group_crystals) as Array[InfoComponent]
		var without_arr:Array[InfoComponent]
		for item in crystals_arr:
			if item.get_item_name() != item_name and item.is_active == true:
				without_arr.append(item)
		without_arr.shuffle()
		var count = int(without_arr.size() * change_percent)
		while count > 0:
			count -= 1
			if without_arr[count].is_item_name_item(item_name):
				without_arr[count].change_to_item(item_name)
			else:
				without_arr[count].change_to_matcher(item_name)
