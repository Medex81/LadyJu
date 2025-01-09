# Носитель набора компонент дамага в предмете. При старте активизирует все дочерние компоненты дамага.

extends Node2D

func start():
	for child in get_children():
		remove_child(child)
		get_tree().current_scene.add_child(child)
		child.global_position = global_position
		child.visible = true
