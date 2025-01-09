# Компонент завершения жизненного цикла предмета. Запускаем эффекты завершения и т.д.

extends Node2D

class_name EndComponent

@onready var parent = get_parent()
var is_dead:bool = false

func end():
	if is_dead == false:
		is_dead = true
		for child in get_children():
			if child is GPUParticles2D:
				child.visible = true
				child.emitting = true
				await child.finished
				break
		parent.queue_free()
