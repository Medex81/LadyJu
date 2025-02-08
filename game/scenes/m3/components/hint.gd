# Компонент подсказки потенциальной комбинации матча. Если подсказка есть - подсвечивает её установленным эффектом.
# При установке эффекта все старые эффекты подсветки снимаются. Поиск подходящих комбинаций происходит
# в радиусе двух размеров клетки. Если комбинация найдена, все остальные проверки останавливаются.
# Сброс подсказки происходит при поступлении события через сигнал.

extends Node2D

class_name HintComponent

# Коэффициент гипотенузы прямоугольного треугольника, нужен для расчёта длины диагонали клетки.
const _sqrt_2 = 1.414213562
const _group_name = "hints"
# имя, по которому сравниваем компоненты и находим потенциальные комбинации
var item_name:String
# размер клетки по умолчанию, устанавливается на старте от родителя
var _cell_size:int = 128
# от размера клетки расчитываем длину диагонали
var _cell_diagonal:int = 181
# радиус поиска - 2 размера клетки
var _cell_2size:int = 256
# компонент активен и участвует в игре
var is_active:bool = false
# расстояние до соседних клеток которые могут быть комбинацией для матча
enum EDistance{NONE, CELL, DIAGONAL, CELL_2}
@export var is_solo_hint:bool = false
# максимальная разность позиций, может возникать так как бывают небольшие смещения, а координаты с плавающей точкой
@export var cell_offset:int = 5
# время которое ожидаем если нет действий, после запускаем проверку подсказки
@export var wait_hint_time_ms = 3000
# время последнего события
static var last_event_time_ms:int = 0
# флаг состояния отображения подсказки
static var is_hint_draw:bool = false
# нет доступных компонент для подсказки
static var has_hint:bool = false
# сообщаем, что подсказок больше нет - вероятно завершение игры
signal send_hasnt_hint()

func _ready() -> void:
	# забираем у родителя имя и размер компонента, необходимые для проверки подсказки
	var parent = get_parent()
	if parent is InfoComponent:
		item_name = parent.item_name
		_cell_size = parent.item_size
		_cell_diagonal = int(_cell_size * _sqrt_2)
		_cell_2size = _cell_size * 2

# проверяем дистанцию по компонента, ответ перечисляемым типом
func distance_to_enum(area:HintComponent)->EDistance:
	var distance = global_position.distance_to(area.global_position)
	if absi(distance - _cell_size) < cell_offset:
		return EDistance.CELL
	if absi(distance - _cell_diagonal) < cell_offset:
		return EDistance.DIAGONAL
	if absi(distance - _cell_2size) < cell_offset:
		return EDistance.CELL_2
	return EDistance.NONE
	
# есть потенциальный матч
func proc_hint(hints:Array[HintComponent]):
	# снимаем подсказку с текущих компонент и устанавливаем в новые
	get_tree().call_group(_group_name, "effect_state", false)
	is_hint_draw = true
	for hint in hints:
		hint.effect_state(true)

# для установленных эффектов вызвать их отображение как подсказку к матчу
func effect_state(state:bool):
	for child in get_children():
		if child is GPUParticles2D:
			child.visible = state
			child.emitting = state

func get_neighbors(_diff_hints:Array[HintComponent], 
					_compose_hints:Dictionary, 
					is_all_neighb:bool = false):
	_diff_hints.clear()
	_compose_hints.clear()
	# получаем два списка с компонентами нашего типа и другие в области обнаружения
	for area in $detector.get_overlapping_areas():
		if area is HintComponent:
			# дистанция в размерах клетки
			var distance = distance_to_enum(area)
			# свой предмет исключаем из поисковой выдачи
			if distance != EDistance.NONE:
				# предметы вокруг, которые совпадают с нашим предметом по имени
				if not item_name.is_empty() and area.item_name == item_name:
					# сортируем поисковую выдачу по расстояниям от нашего предмета
					var arr = _compose_hints.get(distance, []) as Array[HintComponent]
					arr.append(area)
					_compose_hints[distance] = arr
				# предметы с другим именем, берём только ближайшие на которых возможен swap
				else:
					if is_all_neighb:
						_diff_hints.append(area)
					elif distance == EDistance.CELL:
						_diff_hints.append(area)

# проверить наличие комбинаций
func check_detector_collisions(check_only:bool = false)->bool:
	var _diff_hints:Array[HintComponent]
	var _compose_hints:Dictionary
	get_neighbors(_diff_hints, _compose_hints, false)
	# мы что-то нашли с чем можно работать дальше
	if not _diff_hints.is_empty() and not _compose_hints.is_empty():
		# v - комбинация подходящая после свапа для матча
		if _compose_hints.has(EDistance.DIAGONAL) and _compose_hints[EDistance.DIAGONAL].size() > 1:
			var hints:Array[HintComponent]
			# проверяем, что предмет ненашего типа находится между нами(расстояние от каждого - один размер клетки)
			for diff in _diff_hints:
				hints.clear()
				for compos in _compose_hints[EDistance.DIAGONAL]:
					if compos.distance_to_enum(diff) == EDistance.CELL:
						hints.append(compos)
				# есть два предмета нашего типа в подходящей позиции - выдаём подсказку.
				if hints.size() == 2:
					hints.append(self)
					if not check_only:
						proc_hint(hints)
					return true
		# r - комбинация, должны быть два предмета нашего типа по диагонали на размер клетки
		# форма исходного положения г образная
		if _compose_hints.has(EDistance.DIAGONAL) \
		and _compose_hints.has(EDistance.CELL) \
		and not _compose_hints[EDistance.DIAGONAL].is_empty() \
		and not _compose_hints[EDistance.CELL].is_empty():
			# проверяем, чтобы предмет ненашего типа лежал в месте матча между нами
			for diff in _diff_hints:
				for compos in _compose_hints[EDistance.CELL]:
					# от ближайшего соседа - два размера клетки
					if compos.distance_to_enum(diff) == EDistance.CELL_2:
						for compos2 in _compose_hints[EDistance.DIAGONAL]:
							# от диагонального соседа - ближайшая
							if compos2.distance_to_enum(diff) == EDistance.CELL:
								if not check_only:
									proc_hint([compos, compos2, self])
								return true
		# i - комбинация, сосед рядом, второй - через одну
		if _compose_hints.has(EDistance.CELL_2) \
		and _compose_hints.has(EDistance.CELL) \
		and not _compose_hints[EDistance.CELL_2].is_empty() \
		and not _compose_hints[EDistance.CELL].is_empty():
			for diff in _diff_hints:
				for compos in _compose_hints[EDistance.CELL]:
					if compos.distance_to_enum(diff) == EDistance.CELL_2:
						for compos2 in _compose_hints[EDistance.CELL_2]:
							if compos2.distance_to_enum(diff) == EDistance.CELL:
								if not check_only:
									proc_hint([compos, compos2, self])
								return true
	return false

func _physics_process(_delta: float) -> void:
	# подсказки вероятно ещё есть и таймаут вышел
	if has_hint and Time.get_ticks_msec() - last_event_time_ms >= wait_hint_time_ms:
		# отсекаем другие входы в метод на время
		last_event_time_ms = Time.get_ticks_msec()
		# проверяем есть ли подсказки
		if not has_combination_at_all():
			# добавить нельзя - конец игры
			# добавили - выходим, после замены предмет стартует и пробует двигаться чем активирует on_all_stopped
			has_hint = add_combination()
			if has_hint == false:
				send_hasnt_hint.emit()
		call_deferred("check_all_and_hint")

func has_combination_in_current()->bool:
	# матчер - ?
	if is_solo_hint:
		return true
	return check_detector_collisions(true)
	
# проверить комбинации 
func has_combination_at_all()->bool:
	for hint in get_tree().get_nodes_in_group(_group_name):
		if hint is HintComponent and hint.is_active and hint.has_combination_in_current():
			return true
	return false

# проверить комбинации и подсветить
func check_all_and_hint()->bool:
	for hint in get_tree().get_nodes_in_group(_group_name):
		if hint is HintComponent and hint.is_active and hint.check_detector_collisions():
			return true
	return false
	
# добавить предмет для появления комбинации
func add_combination()->bool:
	var _diff_hints:Array[HintComponent]
	var _compose_hints:Dictionary
	# для пар подсказок - добавляем одну подменную в подсказку с другим типом рядом
	for hint in get_tree().get_nodes_in_group(_group_name):
		# отбрасываем те, что в генераторе
		if hint.is_active:
			# запрос на всех соседей без потенциальной комбинации (true)
			hint.get_neighbors(_diff_hints, _compose_hints, true)
			# идём по соседям с другим именем
			for diff_hint in _diff_hints:
				# для проверки комбинации устанавливаем им временно имя проверяемого компонента
				var pot_real_name = diff_hint.item_name
				diff_hint.item_name = hint.item_name
				# есть комбинация!
				if hint.check_detector_collisions(true):
					# заменить соседа на предмет с нашим именем
					diff_hint.get_parent().change_to_item(hint.item_name)
					return true
				# комбинаций нет - возврящаем имя
				diff_hint.item_name = pot_real_name
	# пар нет, есть одиночки - будем наращивать их до пары или сворачивать игру
	# заменяем один и подменный предмет ещё раз нас активирует
	for hint in get_tree().get_nodes_in_group(_group_name):
		if hint.is_active:
			hint.get_neighbors(_diff_hints, _compose_hints, true)
			# работаем если предметов сматчиваемое количество
			if _diff_hints.size() > 2:
				var diff_hint = _diff_hints.front()
				diff_hint.get_parent().change_to_item(hint.item_name)
				return true
	
	return false

# произошло внешнее событие, подсказка пока ненужна
func on_all_stopped():
	if is_hint_draw:
		get_tree().call_group(_group_name, "effect_state", false)
		is_hint_draw = false
	last_event_time_ms = Time.get_ticks_msec()
	has_hint = true
	
# таймер слежения за состояние подсказки запускаем для компонент находящихся в пределах экрана
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_active = true
	pass
