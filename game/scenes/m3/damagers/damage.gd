# базовый узел нанесения урона по хитбоксам.
# Урон наносится хитбоксам сопротивляемость которых више или равна указанным.
# Хитбоксы должны быть с теми же уровнями коллайдера что и у текущего компонента.
# Изначально компонент в предмете с отключенной визуалкой!
# Компонент дамагер передаётся от предмета к корневой сцене с установкой visible  в  true.

extends Area2D

class_name DamageComponent

@export var damage:int = 1
@export var resistance:int = 1
var activate:bool = false

func _on_area_entered(_area: Area2D) -> void:
	if activate and _area is HitboxComponent:
		if _area.hit(damage, resistance):
			resistance -= _area.resistance
			if resistance <= 0:
				queue_free()

func _on_body_entered(body: Node2D) -> void:
	if activate and body is StaticBody2D:
		queue_free()
