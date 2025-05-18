extends Control

class_name M3

@export var _base_m3_level:BaseM3Level = null
@export var _move_timeout:float = 0.2
@export var _hint_timeout:float = 5
@export var shuffle_max_count:int = 10
@onready var tree = get_tree()

const group = "m3"
const move_end_fn = "move_end"
const group_matchers = "matchers"
const group_crystals = "crystals"

var shuffle_count:int = 0
var hint_items:Array[InfoComponent]

func _ready() -> void:
	$move_timer.autostart = true
	$move_timer.wait_time = _move_timeout
	$move_timer.start()
	
	$hint_timer.autostart = true
	$hint_timer.wait_time = _hint_timeout
	#$hint_timer.start()
	hint_items.resize(3)

func _on_move_timer_timeout() -> void:
	tree.call_group(InfoComponent.group_name, "check_move")
	
func shuffle_cells(group:String):
	var all_items:Array = tree.get_nodes_in_group(group)
	var positions:Array
	var active_items:Array
	for item in all_items:
		if item.is_interactive:
			active_items.append(item)
			positions.append(item.global_position)
	positions.shuffle()
	for i in range(active_items.size()):
		active_items[i].global_position = positions[i]
			
func _on_hint_timer_timeout() -> void:
	if $hint.visible == true:
		return
		
	if shuffle_count >= shuffle_max_count:
		if _base_m3_level != null and _base_m3_level.has_method("events"):
			_base_m3_level.events(BaseM3Level.EEvents.NO_HINTS)
		else:
			print("Error. No hint and dont stoped level. _base_m3_level = null or method events.")
		return
		
	# проверить, что нет матчерных предметов, если есть подсветить первый.
	hint_items[0] = null
	hint_items[1] = null
	hint_items[2] = null
	var has:bool = false
	
	# если есть матчерные предметы - выбираем их.
	var matchers:Array = tree.get_nodes_in_group(group_matchers)
	for matcher in matchers:
		if matcher.is_interactive:
			hint_items[0] = matcher
			has = true
			break
	
	# матчеров нет - получить список активных кристаллов которые не падают.
	if has == false:
		var crystals:Array = tree.get_nodes_in_group(group_crystals)
		# вызвать метод хинт у матчерного компонента каждого предмета.
		for item in crystals:
			if item.is_interactive and item.matcher_component != null:
				# после смешивания у нас появился матч - выходим и смешиваем повторно.
				if shuffle_count > 0 and item.matcher_component.has_match():
					has = false
					break
				# ВАЖНО! has_hint - ищет комбинации с предметами(с матчер компонентом) и с пустотами
				# между ними заполненными предметами, но с другим именем!
				# у матчерных предметов нет компонента матчинга и для правильной работы нужно выше исключить их.
				if item.matcher_component.has_hint(hint_items):
					# после первого удачного хинта остановиться и подсветить клетки.
					has = true
			
	# если хинтов нет - смешиваем
	# если после 10 смешиваний хинта нет - сообщение в главную сцену.
	if has == false:
		if shuffle_count == 0:
			$move_timer.stop()
		shuffle_cells(group_crystals)
		shuffle_count += 1
		await get_tree().create_timer(0.5).timeout
		call_deferred("_on_hint_timer_timeout")
	else:
		if shuffle_count > 0:
			$move_timer.start()
		shuffle_count = 0
		var lt:Vector2
		var rd:Vector2
		for item in hint_items:
			if item != null:
				if lt == Vector2.ZERO:
					lt = item.global_position
				if rd == Vector2.ZERO:
					rd = item.global_position
				if item.global_position.x < lt.x:
					lt.x = item.global_position.x
				if item.global_position.y < lt.y:
					lt.y = item.global_position.y
				if item.global_position.x > rd.x:
					rd.x = item.global_position.x
				if item.global_position.y > rd.y:
					rd.y = item.global_position.y
		if lt != Vector2.ZERO and rd != Vector2.ZERO:
			rd.x += 128
			rd.y += 128
			$hint.visible = true
			$hint.global_position = lt
			$hint.size = rd - lt
	
func move_end():
	# потушить подсветку подсказки
	$hint.visible = false
	$hint_timer.start()
