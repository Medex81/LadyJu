# Компонент сматчивает предметы с этим компонентом и одинаковым именем. Сматченый список отправляется
# в генератор для получения матч предмета и отправляем сигнал во все сматченные предметы о завершении предмета.

extends Area2D

class_name MatcherComponent

@export var item_generator_group_name:String = "item_generator"
@export var  _get_item_name_fn = "get_item_name"
@export var check_timeout_msec:int = 3000

@onready var parent = get_parent()
@onready var item_generator:ItemGenerator = get_tree().get_first_node_in_group(item_generator_group_name)

# для вызова у соседей нужного рейкаста упаковываем в словарь рейкасты и направления к ним в виде ключей
@onready var _directs:Dictionary = {EDirect.LEFT:$rc_l, EDirect.RIGHT:$rc_r, EDirect.DOWN:$rc_d, EDirect.TOP:$rc_t}
# матчить можно не в любое время, а только когда стоим мы и стоят соседи по матчингу
var is_matchable:bool = true
# направления в которых матчим
enum EDirect{LEFT, RIGHT, DOWN, TOP}
# имя матчера для матчинга по типу
var item_name:String

# говорим кому-то, что мы сматчены
signal send_match()
signal send_fail_match()

func _ready() -> void:
	if parent.has_method(_get_item_name_fn):
		item_name = parent.call(_get_item_name_fn)

func get_item_name()->String:
	return item_name
		
func on_unmatchable():
	is_matchable = false
	
# матчимся с соседями.
func on_matching()->bool:
	is_matchable = true
	# проходим по вертикали и горизонтали в поисках предметов схожих по типу с нашим
	var matchers_h:Array[MatcherComponent]
	check_match(matchers_h, EDirect.LEFT)
	check_match(matchers_h, EDirect.RIGHT)
	var matchers_v:Array[MatcherComponent]
	check_match(matchers_v, EDirect.TOP)
	check_match(matchers_v, EDirect.DOWN)
	var direct_h:bool = true
	# есть пересечение по вертикали и горизонтали - объединяем в один матч
	if matchers_h.size() > 1 and matchers_v.size() > 1:
		matchers_h.append_array(matchers_v.duplicate())
		matchers_v.clear()
	if matchers_h.size() < 2:
		direct_h = false
		matchers_h = matchers_v
		
	if matchers_h.size() > 1:
		# запрос на генерацию предмета матчера если подходит по количеству
		if item_generator:
			var match_item = item_generator.generate_matcher(matchers_h.size() + 1, direct_h)
			if match_item:
				get_tree().current_scene.call_deferred("add_child", match_item)
				match_item.global_position = global_position
		# можно удалять
		send_match.emit()
		for matcher in matchers_h:
			matcher.send_match.emit()
		return true
	# уведомляем о невозможности матчинга в данной позиции
	send_fail_match.emit()
	return false
	
# проверяем по указанному направлению (горизонтально или вертикально) соседство предметов которые могут сматчиться
func check_match(matchers:Array[MatcherComponent], direct:EDirect):
	# выбираем датчик рейкаста по направлению и смотрим какой предмет он пересекает
	_directs[direct].force_raycast_update()
	var next = _directs[direct].get_collider() as MatcherComponent
	# предмет должен быть того же типа и не падать
	if next and next != self and is_matchable and next.is_matchable and not item_name.is_empty() and next.item_name == item_name:
		if not next in matchers:
			# в массив, переданный в аргументе по ссылке, собираем всех подходящих соседей рекурсивно
			matchers.append(next)
		next.check_match(matchers, direct)
