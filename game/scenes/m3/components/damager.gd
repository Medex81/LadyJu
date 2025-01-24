# Носитель набора компонент дамага в предмете. При старте активизирует все дочерние компоненты дамага.

extends Node2D

class_name DamageContainerComponent

# компонент уже был использован
var is_damaged:bool = false

func start():
	if is_damaged:
		return
	is_damaged = true
	for child in get_children():
		# отвязываем компоненты дамга от себя и передаём основной сцене.
		# смысл в том, чтобы воздействие компонента продолжалось и после уничтожения контейнера(self)
		if child is DamageComponent:
			remove_child(child)
			get_tree().current_scene.call_deferred("add_child", child)
			child.global_position = global_position
			# активировать компонент, запускается нанесение урона.
			child.activate = true
		
