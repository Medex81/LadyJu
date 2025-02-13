# Носитель набора компонент дамага в предмете. При старте активизирует все дочерние компоненты дамага.

extends Node2D

class_name DamageContainerComponent

# компонент уже был использован
var is_damaged:bool = false

var _is_second_matcher:bool = false
var _second_name:String

@export var add_boost_resist:int = 2

func activate_damage():
	for child in get_children():
		# отвязываем компоненты дамага от себя и передаём основной сцене.
		# смысл в том, чтобы воздействие компонента продолжалось и после уничтожения контейнера(self)
		if child is BaseDamageComponent or child is ProjectileComponent:
			remove_child(child)
			get_tree().current_scene.call_deferred("add_child", child)
			child.global_position = global_position
		
		if child is ProjectileComponent:
			if _is_second_matcher:
				child.add_boost = add_boost_resist
			child.call_deferred("start")
			
		if child is DetonatorComponent:
			if _is_second_matcher:
				child.resistance += add_boost_resist
			child.call_deferred("start", 0.2)

func start():
	# урон уже был активирован, значит хитпоинтов нет
	if is_damaged:
		return
	is_damaged = true
	
	activate_damage()
	
# Урон нанесен снаружи и хитпоинтов больше нет, запускается рука мертвеца
func _exit_tree() -> void:
	if is_damaged == false:
		activate_damage()
			
func on_damage_from_component(is_second_matcher:bool, second_name:String):
	_is_second_matcher = is_second_matcher
	_second_name = second_name
	start()
	
