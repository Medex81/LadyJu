extends BaseSwapLogicComponent

@export var copy_count:int = 1

func start(item:InfoComponent, second_swap_name:String):
	# при особых условиях движения снимаем усиление удара с предметов
	if item.get_item_name() == second_swap_name and item.damager_component:
		item.damager_component.set_swap_item_name("")
		
	for count in range(copy_count):
		var new_item = item.get_matcher_for_name()
		item.get_parent().add_child(new_item)
		new_item.finalize()
