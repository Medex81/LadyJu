extends BaseSwapLogicComponent

@export var copy_count:int = 1

func start(item:InfoComponent, second_swap:InfoComponent):
		
	if second_swap is MatchInfoComponent:
		match second_swap.get_item_name():
			"amulet":
				if item.damager_component:
					item.damager_component.set_swap_item_name("")
			"helicopter":
				if item.damager_component:
					item.damager_component.set_swap_item_name("")
				if second_swap != null and second_swap.damager_component:
					second_swap.damager_component.set_swap_item_name("")
				for count in range(copy_count):
					var new_item = item.get_matcher_for_name()
					item.get_parent().add_child(new_item)
					new_item.finalize()
			_:
				if item.damager_component:
					item.damager_component.set_swap_item_name("")
				if second_swap != null and second_swap.damager_component:
					second_swap.damager_component.set_swap_item_name("")
				second_swap.get_parent().remove_child(second_swap)
				item.add_child(second_swap)
				second_swap.position = Vector2.ZERO
				second_swap.is_interactive = false
