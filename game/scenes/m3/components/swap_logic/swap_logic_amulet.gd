extends BaseSwapLogicComponent

class_name ExchangeSwapLogicComponent

@export var change_percent:float = 0.5
@export var group_crystals = "crystals"

func start(item:InfoComponent, second_swap:InfoComponent)->bool:
	var second_swap_item_name:String
	if second_swap != null:
		second_swap_item_name = second_swap.get_item_name()
	else:
		second_swap_item_name = item.get_random_item_name()
	
	var crystals_arr = get_tree().get_nodes_in_group(group_crystals) as Array[InfoComponent]
	var without_arr:Array[InfoComponent]
	if crystals_arr.size() < 2:
		print("Error. In ExchangeSwapLogicComponent InfoComponent crystals count is ", crystals_arr.size())
		return false
	for _item in crystals_arr:
		if _item.get_item_name() != second_swap_item_name and _item.is_active == true:
			without_arr.append(_item)
	without_arr.shuffle()
	var count = int(without_arr.size() * change_percent)
	if count == 0:
		print("Error. In ExchangeSwapLogicComponent no InfoComponent crystals to change.")
		return false
	while count > 0:
		count -= 1
		var new_item = without_arr[count].change_to(second_swap_item_name)
		if new_item is MatchInfoComponent:
			new_item.call_deferred("finalize")
			
	item.call_deferred("finalize")
			
	return true
	
