# Контейнерный компонент содержащий компоненты с уроном по хитбоксам. Осуществляет движение и управление 
# и следит за существованием объектов в контейнере и выходом за границу зоны отрисовки сцены.

extends Node2D

class_name ProjectileComponent

@export var direction:Vector2 = Vector2.ZERO
@export var speed:int = 500
var is_activate:bool = false
var add_boost:int = 0

func start():
	for damage in get_children():
		if damage is LongDamageComponent:
			damage.resistance += add_boost
			damage.start()
	is_activate = true

func _physics_process(delta: float) -> void:
	if is_activate:
		position += direction * (speed * delta)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if is_activate:
		queue_free()


func _on_damage_cell_send_end() -> void:
	queue_free()
