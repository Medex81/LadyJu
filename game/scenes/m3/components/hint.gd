# Компонент подсказки потенциальной комбинации матча. Если подсказка есть - подсвечивает её установленным эффектом.
# При установке эффекта все старые эффекты подсветки снимаются. Поиск подходящих комбинаций происходит
# в радиусе двух размеров клетки. Если комбинация найдена, все остальные проверки останавливаются.
# Сброс подсказки происходит при поступлении события через сигнал.

extends Node2D

class_name HintComponent

# Коэффициент гипотенузы прямоугольного треугольника, нужен для расчёта длины диагонали клетки.
const _sqrt_2 = 1.414213562
# имя, по которому сравниваем компоненты и находим потенциальные комбинации
var item_name:String
# обнаруженные в радиусе компоненты с другим именем
var _diff_hints:Array[HintComponent]
# обнаруженные в радиусе компоненты с именем совпадающим с нашим
var _compose_hints:Dictionary
# размер клетки по умолчанию, устанавливается на старте от родителя
var _cell_size:int = 128
# от размера клетки расчитываем длину диагонали
var _cell_diagonal:int = 181
# радиус поиска - 2 размера клетки
var _cell_2size:int = 256
# флаг запуска однократной проверки окружения, для избежания повторной проверки
var _one_shot:bool = false
# идентификатор текущей отображаемой подсказки, по нему мы понимаем когда подсказки устарели
var _current_hint_id:int = -1
# расстояние до соседних клеток которые могут быть комбинацией для матча
enum EDistance{NONE, CELL, DIAGONAL, CELL_2}
@export var _is_solo_hint:bool = false
# имена методов родителя возвращающие информацию по имени и размеру компонента
@export var  _get_item_name_fn = "get_item_name"
@export var  _get_item_size_fn = "get_item_size"
# максимальная разность позиций, может возникать так как бывают небольшие смещения, а координаты с плавающей точкой
@export var cell_offset:int = 5
# время которое ожидаем если нет действий, после запускаем проверку подсказки
@export var wait_hint_time_ms = 3000
@onready var _max_wait_time_ms = $Timer.wait_time * 1000 + wait_hint_time_ms
# время последнего события
static var last_event_time_ms:int = Time.get_ticks_msec()
# идентификатор подсказки
static var hint_id:int = 0
# флаг состояния отображения подсказки
static var is_hint_draw:bool = false

func _ready() -> void:
	# забираем у родителя имя и размер компонента, необходимые для проверки подсказки
	var parent = get_parent()
	if parent.has_method(_get_item_name_fn):
		item_name = parent.call(_get_item_name_fn)
	if parent.has_method(_get_item_size_fn):
		_cell_size = parent.call(_get_item_size_fn)
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
	hint_id += 1
	is_hint_draw = true
	for hint in hints:
		hint.effect_state(true, hint_id)

# для установленных эффектов вызвать их отображение как подсказку к матчу
func effect_state(state:bool, _hint_id:int):
	_current_hint_id = _hint_id
	for child in get_children():
		if child is GPUParticles2D:
			child.visible = state
			child.emitting = state

func _check_detector_collisions():
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
				elif distance == EDistance.CELL:
					_diff_hints.append(area)
					
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
					proc_hint(hints)
					return
		# r - комбинация, должны быть два предмета нашего типа по диагонали на на размер клетки
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
								proc_hint([compos, compos2, self])
								return
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
								proc_hint([compos, compos2, self])
								return
	
# произошло внешнее событие, подсказка пока ненужна
func on_all_stopped():
	last_event_time_ms = Time.get_ticks_msec()
	is_hint_draw = false
	_one_shot = false

# проверяем состояние подсказки и нужно ли её искать
func _on_timer_timeout() -> void:
	if is_hint_draw == false and Time.get_ticks_msec() - last_event_time_ms >= _max_wait_time_ms:
		_no_combinations()
	
	# была установлена новая подсказка, старую удалить
	if _current_hint_id > -1 and _current_hint_id != hint_id:
		effect_state(false, -1)
		
	# однократно запустить проверку если подсказка пока не обнаружена и прошло установленное время
	if not _one_shot and not is_hint_draw and Time.get_ticks_msec() - last_event_time_ms > wait_hint_time_ms:
		if _is_solo_hint:
			proc_hint([self])
		else:
			_check_detector_collisions()
		_one_shot = true

# таймер слежения за состояние подсказки запускаем для компонент находящихся в пределах экрана
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	$Timer.autostart = true
	$Timer.start()
	
func _no_combinations():
	is_hint_draw = true
