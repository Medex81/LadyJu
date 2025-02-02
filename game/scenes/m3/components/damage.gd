# базовый узел нанесения урона по хитбоксам.
# Урон наносится хитбоксам сопротивляемость которых выше или равна указанным.
# Хитбоксы должны быть с теми же уровнями коллайдера что и у текущего компонента.
# Компонент дамагер передаётся от предмета к корневой сцене и активируется установкой флага activate.
# Через флаг is_one_shot мы
# устанавливаем однократный контакт с компонентами hit или продолжительный до удаления
# компонента или встречи со статическим объектом на layer 5.
# Перед использованием убедиться, что уровни hit и damage равны и маска установлена.
# Убедиться, что установлена маска для статических преград или периметра на котором самоликвидируемся.

extends Area2D

class_name DamageComponent
# сопротивляемость урону(твёрдость)
@export var resistance:int = 1
# наносимый урон
@export var damage:int = 1
# нанести урон однократно всем с кем пересекается и удалиться
@export var is_one_shot:bool = false
# кодитель\контейнер - устанавливает поле в состояние активируя нанесение урона
var activate:bool = false:
	set(value):
		activate = value
		if activate:
			# включить детектирование зон столкновения
			collisions_disable(false)
			# сигнал если нужно запустить процесс внутренних узлов о которых мы не знаем сейчас
			send_start.emit()

# сигнал для запуска процессов внутри узла дамага, если нужно
signal send_start()


# отключаeм\включаeм детектирование зон пересечения
func collisions_disable(is_disable:bool):
	for collis in get_children():
		if collis is CollisionShape2D:
			collis.disabled = is_disable

# на старте отключам детектирование зон пересечения так как урон наносится только по событию, а не постоянно.
func _ready() -> void:
	collisions_disable(true)
	
# наносим удар всем кто пересекает нашу зону детектирования после события нанесения дамага.
# удаляемся по какому-то другому событию
func _on_area_entered(_area: Area2D) -> void:
	if activate and _area is HitboxComponent:
		if is_one_shot:
			for area in get_overlapping_areas():
				area.hit(damage, resistance)
			queue_free()
			return
		_area.hit(damage, resistance)

# при пересечении границ поля нанесения урона - удаляемся.
func _on_body_entered(body: Node2D) -> void:
	if activate and body is StaticBody2D:
		queue_free()
