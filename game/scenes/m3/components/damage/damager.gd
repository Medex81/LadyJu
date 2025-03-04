# Носитель набора компонент дамага в предмете. При старте активизирует все дочерние компоненты дамага.

extends Node2D

class_name DamageContainerComponent

var _swap_item_name:String = ""
@export var add_boost_resist:int = 2
@export var info_component:InfoComponent = null

signal send_finish_damage()

func set_swap_item_name(_item_name:String):
	if _item_name.is_empty():
		return
	_swap_item_name = _item_name

func run_damage() -> void:
	for child in get_children():
		if child is ExchangeDamageComponent:
			if info_component:
				if not _swap_item_name.is_empty() and not info_component.is_item_name_valid(_swap_item_name):
					print("Error. run_damage in ExchangeDamageComponent with invalid item name ", _swap_item_name)
					return
				if _swap_item_name.is_empty():
					_swap_item_name = info_component.get_random_item_name()
				child.start(_swap_item_name)
		
		if child is OneShotDamageComponent:
			if not _swap_item_name.is_empty() and info_component and info_component.is_item_name_matcher(_swap_item_name):
				child.resistance += add_boost_resist
			child.start()
	send_finish_damage.emit()
