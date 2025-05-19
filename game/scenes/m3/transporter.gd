# Компонент транспортирует входящий в него компонент (info) в координаты компонента приёмника.

extends Area2D

class_name TransporterComponent
# компонент куда транспортируем предмет
@export var recipient:TransporterComponent = null
@export var _move_time:float = 0.5

# данный транспортер занят предметом
var is_busy:bool = false
# состояние транспотрера (от получателя к отправителю)
signal send_busy(busy_state:bool)

func _ready() -> void:
	# подписываемся на оповещения приёмника если мы отправитель
	if recipient != null:
		recipient.send_busy.connect(recipient_state_changed)

func _on_area_entered(area: Area2D) -> void:
	# получатель
	if recipient == null:
		is_busy = true
		send_busy.emit(is_busy)
	# отправитель
	if recipient != null and recipient.is_busy == false and is_busy == false:
		transpoting(area.get_parent())

func _on_area_exited(_area: Area2D) -> void:
	# получатель свободен и может принимать предмет
	if recipient == null:
		is_busy = false
		send_busy.emit(is_busy)
		
# состояние получателя
func recipient_state_changed(busy_state:bool):
	if busy_state == false:
		# если есть неотправленный предмет - отправить его
		var mover_comps = get_overlapping_areas()
		if not mover_comps.is_empty():
			transpoting(mover_comps.front().get_parent())

func transpoting(item:InfoComponent):
	if item is InfoComponent:
		# остановить движение в том числе через твин у предмета
		item.stop_moving()
		# следующий предмет, расположенный выше, пусть пока подождет
		is_busy = true
		var move_tween = get_tree().create_tween()
		move_tween.tween_property(item, "global_position", recipient.global_position, _move_time)
		await move_tween.finished
		# придмету можно двигаться через стандартный компонент мувера
		item.start_moving()
		is_busy = false
		
