# Носитель набора компонент дамага в предмете. При старте активизирует все дочерние компоненты дамага.

extends Node2D

class_name DamageContainerComponent

var _swap_item_name:String = ""
@export var add_boost_resist:int = 2
@export var info_component:InfoComponent = null

func set_swap_item_name(_item_name:String):
	_swap_item_name = _item_name

func run_damage() -> void:
	for child in get_children():
		if child is OneShotDamageComponent:
			if not _swap_item_name.is_empty() and info_component and info_component.is_item_name_matcher(_swap_item_name):
				child.resistance += add_boost_resist
			child.start()
