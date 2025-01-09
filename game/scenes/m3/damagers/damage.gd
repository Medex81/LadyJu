# базовый узел нанесения урона по хитбоксам.
# Урон наносится хитбоксам сопротивляемость которых више или равна указанным.
# Хитбоксы должны быть с теми же уровнями коллайдера что и у текущего компонента.
# Изначально компонент в предмете с отключенной визуалкой.
# Компонент дамагер передаётся от предмета к корневой сцене с установкой visible  в  true.

extends Area2D

@export var damage:int = 1
@export var resistance:int = 1

func _on_area_entered(_area: Area2D) -> void:
	if visible:
		for hitbox in get_overlapping_areas():
			if hitbox is HitboxComponent:
				hitbox.hit(damage, resistance)
		queue_free()
