extends GridContainer

class_name Match3Grid

# максимальное количество смешиваний до появления комбинации для матча.
@export var max_shuffle:int = 10
@export var hint_delay:float = 3.0
var _event_counter = 0
# счётчик смешиваний
var _shuffle_counter = 0

func _ready():
	var cells = get_children().filter(func(child):return true if child is Cell else false)
	$M3Core.init_cells(cells, columns)
	for cell in cells:
		cell.send_tap.connect(_on_cell_tap)
	_update()

func _on_timer_hint_delay_timeout():
	var hints = $M3Core.hint()
	for hint in hints:
		hint.hint()
		
func _on_cell_tap(cell_first:Cell, cell_second:Cell):
	if $M3Core.swap(cell_first, cell_second):
		call_deferred("_update")
		
# обновить состояние игрового поля
func _update():
	# сматчить, удалить, добавить
	if not $M3Core.worker():
		# действий нет - ищем подсказку
		if $M3Core.hint().is_empty():
			# комбинаций для подсказок нет - смешиваем предметы
			_shuffle_counter += 1
			if _shuffle_counter < max_shuffle:
				print("_update _shuffle.")
				#TODO нужно проверять сколько оталось предметов и не смешивать менее 5-6!
				$M3Core.shuffle()
		else:
			$Timer.start()
	else:
		_shuffle_counter = 0
		
func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		call_deferred("_update")

func done_event(count:int = 1):
	_event_counter -= count
	if _event_counter <= 0:
		_event_counter = 0
		call_deferred("_update")
		
func add_event(count:int = 0):
	_event_counter += count
