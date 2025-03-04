# Компонент должен нанести урон по хитбоксам один раз.

extends BaseDamageComponent

class_name OneShotDamageComponent

func start(_variant = null):
	for component in get_overlapping_areas():
		if component is HitboxComponent:
			component.hit(damage, resistance)
