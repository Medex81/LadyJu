# Компонент должен существовать и наносить урон по хитбоксам которые с ним контактируют.
# Время существования до уничтожения родителя или встречи с статическим препятствием. 

extends BaseDamageComponent

class_name LongDamageComponent

var is_activate:bool = false
signal send_end()


func start(_wait_time_ms:float = 0.0):
	is_activate = true

# наносим удар всем кто пересекает нашу зону детектирования после события нанесения дамага.
# удаляемся по какому-то другому событию
func on_area_entered(_area: Area2D) -> void:
	if is_activate and _area is HitboxComponent:
		_area.hit(damage, resistance)
