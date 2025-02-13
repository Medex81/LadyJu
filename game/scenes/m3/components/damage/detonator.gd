# Компонент должен подорвать хитбокс над которым расположен с указанной задержкой

extends BaseDamageComponent

class_name DetonatorComponent

func start(_wait_time_ms:float = 0.0):
	await get_tree().create_timer(_wait_time_ms).timeout
	for component in get_overlapping_areas():
		if component is HitboxComponent:
			component.hit(damage, resistance)
	queue_free()
