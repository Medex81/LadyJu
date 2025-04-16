extends Area2D

class_name MatcherComponent

const _sqrt_2 = 1.414213562
var item_name:String
var fake_item_name:String
var _cell_size:int = 128
# от размера клетки расчитываем длину диагонали
var _cell_diagonal:int = 181
# радиус поиска - 2 размера клетки
var _cell_2size:int = 256
# расстояния между клетками
enum EDistance{NONE, CELL, DIAGONAL, CELL_2}
# тип сматчивания
enum EMatcher{NONE, LINE3, LINE4_H, LINE4_V, LINE5, ANGLE5, SQUARE4, T4, T5, T6, T7}
@export var cell_offset:int = 5
@export var info_component:InfoComponent = null
# подписка на сохраняемое в ПС значение
@export var save_value_type:PlayerState.EPS = PlayerState.EPS.NONE
var save_coins:PlayerStateValueInt = null

func _ready() -> void:
	# подписываемся на изменение указанного значения в ПС
	if save_value_type != PlayerState.EPS.NONE:
		save_coins = Globals.player_state.get_int_value(save_value_type)
	if info_component:
		item_name = info_component.get_item_name()
		_cell_size = info_component.get_item_size()
		_cell_diagonal = int(_cell_size * _sqrt_2)
		_cell_2size = _cell_size * 2
		
# проверяем дистанцию до компонента, ответ перечисляемым типом
func distance_to_enum(area:MatcherComponent)->EDistance:
	var distance = global_position.distance_to(area.global_position)
	if absi(distance - _cell_size) < cell_offset:
		return EDistance.CELL
	if absi(distance - _cell_diagonal) < cell_offset:
		return EDistance.DIAGONAL
	if absi(distance - _cell_2size) < cell_offset:
		return EDistance.CELL_2
	return EDistance.NONE
	
# найти соседей с тем же именем
func get_neighbors(_compose_hints:Dictionary):
	_compose_hints.clear()
	# получаем два списка с компонентами нашего типа и другие в области обнаружения
	for area in $detector.get_overlapping_areas():
		if area is MatcherComponent:
			# дистанция в размерах клетки
			var distance = distance_to_enum(area)
			# свой предмет исключаем из поисковой выдачи
			if distance != EDistance.NONE:
				# предметы вокруг, которые совпадают с нашим предметом по имени
				if not get_item_name().is_empty() and area.get_item_name() == get_item_name():
					# сортируем поисковую выдачу по расстояниям от нашего предмета
					var arr = _compose_hints.get(distance, []) as Array[MatcherComponent]
					arr.append(area)
					_compose_hints[distance] = arr

func check_detector_collisions(with_remove:bool = true)->EMatcher:
	var _compose_hints:Dictionary
	# собираем соседей этой клетки
	get_neighbors(_compose_hints)

	# есть соседи с тем же именем по горизонтали или вертикали 
	if _compose_hints.has(EDistance.CELL):
		var cell_link_count = 0
		var matched_cells:Array[MatcherComponent] 
		var neighbors_cell_count = _compose_hints[EDistance.CELL].size()
		# есть соседи с тем же именем через одну клетку
		# находим - линки (соединения) ближнего и дальнего(через одну клетку) соседа
		# по линкам можно идентифицировать тип матча без привязки к пространственной позиции
		if _compose_hints.has(EDistance.CELL_2):
			for cell in _compose_hints[EDistance.CELL]:
				for _cell in _compose_hints[EDistance.CELL_2]:
					if cell.distance_to_enum(_cell) == EDistance.CELL:
						cell_link_count += 1
						matched_cells.append(_cell)
		matched_cells.append_array(_compose_hints[EDistance.CELL])
		var match_result:EMatcher = EMatcher.NONE
		# матч в форме - Т
		if neighbors_cell_count == 3:
			match  cell_link_count:
				0:
					match_result = EMatcher.T4
				1:
					match_result = EMatcher.T5
				2:
					match_result = EMatcher.T6
				3:
					match_result = EMatcher.T7
		# линейный, квадратный и угловой типы матчей
		if neighbors_cell_count == 2:
			match  cell_link_count:
				0, 1:
					if _compose_hints[EDistance.CELL].front().distance_to_enum(_compose_hints[EDistance.CELL].back()) == EDistance.DIAGONAL:
						if _compose_hints.has(EDistance.DIAGONAL):
							for cell in _compose_hints[EDistance.DIAGONAL]:
								if cell.distance_to_enum(_compose_hints[EDistance.CELL].front()) == EDistance.CELL and \
								cell.distance_to_enum(_compose_hints[EDistance.CELL].back()) == EDistance.CELL:
									matched_cells.append(cell)
									match_result = EMatcher.SQUARE4
					elif _compose_hints[EDistance.CELL].front().distance_to_enum(_compose_hints[EDistance.CELL].back()) == EDistance.CELL_2 \
					and cell_link_count == 1:
						if absi(_compose_hints[EDistance.CELL].front().global_position.x - _compose_hints[EDistance.CELL].back().global_position.x) < cell_offset:
							match_result = EMatcher.LINE4_V
						else:
							match_result = EMatcher.LINE4_H
					elif _compose_hints[EDistance.CELL].front().distance_to_enum(_compose_hints[EDistance.CELL].back()) == EDistance.CELL_2:
						match_result = EMatcher.LINE3
				2:
					if _compose_hints[EDistance.CELL].front().distance_to_enum(_compose_hints[EDistance.CELL].back()) == EDistance.CELL_2:
						match_result = EMatcher.LINE5
					else:
						match_result = EMatcher.ANGLE5
		# матч линейный 3 и Т(4)
		if neighbors_cell_count == 1:
			match cell_link_count:
				1: match_result = EMatcher.LINE3
				2: match_result = EMatcher.T4
		# есть результат для сматчивания
		if match_result != EMatcher.NONE:
			if with_remove:
				# удалить сматченные простые предметы и заменить на матчер
				remove_and_change(matched_cells, match_result)
			return match_result
			
	return EMatcher.NONE
	
func remove_and_change(neighbors:Array[MatcherComponent], change_enum:EMatcher):
	if info_component != null:
		if change_enum > EMatcher.LINE3:
			# награда за сматчивание
			if save_coins:
				save_coins.value += int(change_enum) * 10
			# заменяем простой предмет на матчер в этой клетке
			info_component.change_to_matcher_enum(change_enum)
		else:
			if save_coins:
				save_coins.value += 10
			info_component.finalize()
			
	for item in neighbors:
		if item.info_component:
			item.info_component.finalize()
			
func has_match()->bool:
	return check_detector_collisions(false)
	
func matching()->bool:
	return check_detector_collisions()

func get_item_name()->String:
	return item_name if fake_item_name.is_empty() or fake_item_name == item_name else fake_item_name
	
func set_fake_item_name(_item_name:String):
	fake_item_name = _item_name
