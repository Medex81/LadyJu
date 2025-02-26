# Носитель набора компонент дамага в предмете. При старте активизирует все дочерние компоненты дамага.

extends Node2D

class_name DamageContainerComponent

var _swap_item_name:String = ""
@export var add_boost_resist:int = 2
@export var info_component:InfoComponent = null

signal send_finish_damage()

func set_swap_item_name(_item_name:String):
	if _item_name.is_empty():
		print("Error. set_swap_item_name is empty!")
		return
	_swap_item_name = _item_name
	
func has_damage()->bool:
	for child in get_children():
		if child is OneShotDamageComponent \
		#or child is ProjectileDamageComponent \
		#or child is TransferDamageComponent\
		or child is ExchangeDamageComponent:
			return true
	return false

func run_damage() -> void:
	if not _swap_item_name.is_empty() and info_component and not info_component.is_item_name_valid(_swap_item_name):
		print("Error. run_damage in ExchangeDamageComponent with invalid item name ", _swap_item_name)
		return
	
	for child in get_children():
		if child is ExchangeDamageComponent:
			if info_component:
				if _swap_item_name.is_empty():
					_swap_item_name = info_component.get_random_item_name()
				child.start(_swap_item_name)
				#await child.send_damage_done
		
		if child is OneShotDamageComponent:
			if not _swap_item_name.is_empty() and info_component and info_component.is_item_name_matcher(_swap_item_name):
				child.resistance += add_boost_resist
			child.start()
			#await child.send_damage_done
		#if child is ProjectileComponent:
			## отвязываем компоненты дамага от себя и передаём основной сцене.
			## смысл в том, чтобы воздействие компонента продолжалось и после уничтожения контейнера(self)
			##remove_child(child)
			##get_tree().current_scene.call_deferred("add_child", child)
			##child.global_position = global_position
			#if _swap_item_name.is_empty():
				#child.add_boost = add_boost_resist
			#child.start()
			#
	send_finish_damage.emit()
