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
enum EMatcher{NONE, LINE4_H, LINE4_V, COUNT5, COUNT6, COUNT7}
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
		if area is MatcherComponent and area.info_component and not area.info_component.is_died:
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

func match_detector(with_remove:bool = true)->bool:
	var _compose_hints:Dictionary
	var matched_cells1:Array[MatcherComponent]
	var matched_cells2:Array[MatcherComponent]
	# собираем соседей этой клетки
	get_neighbors(_compose_hints)
	# добавляем линки между клетками
	if _compose_hints.has(EDistance.CELL_2) and _compose_hints.has(EDistance.CELL):
		for cell1 in _compose_hints[EDistance.CELL]:
			for cell2 in _compose_hints[EDistance.CELL_2]:
				if cell1.distance_to_enum(cell2) == EDistance.CELL:
					matched_cells1.append(cell1)
					matched_cells2.append(cell2)
					continue
	# добавляем одиночные клетки линкующиеся через один (через основную)
	if _compose_hints.has(EDistance.CELL):
		for cell1 in _compose_hints[EDistance.CELL]:
			if not matched_cells1.has(cell1):
				for cell11 in _compose_hints[EDistance.CELL]:
					if cell1 != cell11 and cell1.distance_to_enum(cell11) == EDistance.CELL_2:
						matched_cells1.append(cell1)

	matched_cells1.append_array(matched_cells2)
	var total_size = matched_cells1.size() + 1
	
	if info_component != null and total_size >= 3:
		if with_remove == true:
			if total_size == 3:
				if save_coins:
					save_coins.value += 1
				matched_cells1.append(self)
			else:
				var matcher_item:EMatcher = EMatcher.NONE
				match total_size:
					4:
						if absi(matched_cells1.front().global_position.x - matched_cells1.back().global_position.x) < cell_offset:
							matcher_item = EMatcher.LINE4_V
						else:
							matcher_item = EMatcher.LINE4_H
					5:
						matcher_item = EMatcher.COUNT5
					6:
						matcher_item = EMatcher.COUNT6
					7:
						matcher_item = EMatcher.COUNT7
				# награда за сматчивание
				if save_coins:
					save_coins.value += total_size
				# заменяем простой предмет на матчер в этой клетке
				info_component.change_to_matcher_enum(matcher_item)
			for item in matched_cells1:
				if item.info_component:
					item.info_component.call_deferred("finalize")
		return true
	return false

func has_match()->bool:
	return match_detector(false)
	
func matching()->bool:
	return match_detector()

func get_item_name()->String:
	return item_name if fake_item_name.is_empty() or fake_item_name == item_name else fake_item_name
	
func set_fake_item_name(_item_name:String):
	fake_item_name = _item_name
