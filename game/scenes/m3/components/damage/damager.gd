# Носитель набора компонент дамага в предмете. При старте активизирует все дочерние компоненты дамага.

extends Node2D

class_name DamageContainerComponent

# компонент уже был использован
var is_damaged:bool = false

var _is_second_matcher:bool = false
var _second_name:String

@export var add_boost_resist:int = 2

const start_damage_fn = "start"

func activate_damage():
	for child in get_children():
		if child is ExchangeDamageComponent:
			if _second_name.is_empty():
				var names = get_parent().get_items_name() as Array[String]
				if not names.is_empty():
					_second_name = names.pick_random()
			child.call_deferred(start_damage_fn, _second_name)
		
		if child is ProjectileComponent:
			# отвязываем компоненты дамага от себя и передаём основной сцене.
			# смысл в том, чтобы воздействие компонента продолжалось и после уничтожения контейнера(self)
			remove_child(child)
			get_tree().current_scene.call_deferred("add_child", child)
			child.global_position = global_position
			if _is_second_matcher:
				child.add_boost = add_boost_resist
			child.call_deferred(start_damage_fn)
			
		if child is DetonatorComponent:
			if _is_second_matcher:
				child.resistance += add_boost_resist
			child.call_deferred(start_damage_fn, 0.2)

func start():
	# урон уже был активирован, значит хитпоинтов нет
	if is_damaged:
		return
	is_damaged = true
	
	activate_damage()
	
func on_quiet():
	is_damaged = true
	
# Урон нанесен снаружи и хитпоинтов больше нет, запускается рука мертвеца
func _exit_tree() -> void:
	if is_damaged == false:
		activate_damage()
			
func on_damage_from_component(is_second_matcher:bool, second_name:String):
	_is_second_matcher = is_second_matcher
	_second_name = second_name
	start()
	
