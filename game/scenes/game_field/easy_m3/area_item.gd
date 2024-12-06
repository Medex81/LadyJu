extends Area2D

class_name AreaItem

# время анимации перемещения
@export var move_time:float = 0.25
# эмуляция дырки через которую можно проходить, но нельзя занимать
@export var is_hole:bool = false
# имя типа предмета
@export var item_name:String
# хр предмета
@export var xp = 1
# твёрдость предмета, повредить может только такой же или больше по твёрдости предмет на указанное количество хр
@export var _hardness:int = 2
# размер клетки
const width = 128
# смещения для перехода на размер клетки
const to_down_left = Vector2(-width, width)
const to_down_right = Vector2(width, width)
const to_down = Vector2(0, width)
const to_top = Vector2(0, -width)
const to_right = Vector2(width, 0)
const to_left = Vector2(-width, 0)

# при переходе, запоминаем квардат куда прибудем. Это нужно для синхронизации перемещений с другими предметами
# для избежания двойного занятия позиции. Словарь доступен из всех предметов.
static var occupied:Dictionary
# для свапа предметов нужно помнить предмет отправитель и получатель для обмена позициями.
static var swap_node:AreaItem = null
# флаг, находимся ли мы сейчас в движении при анимации
var is_moving:bool = false
enum EDirect{LEFT, RIGHT, DOWN, TOP, DOWN_LEFT, DOWN_RIGHT, TOP_LEFT, TOP_RIGHT, NONE}
@onready var directs:Dictionary = {EDirect.LEFT:$rc_l, EDirect.RIGHT:$rc_r, EDirect.DOWN:$rc_d, EDirect.TOP:$rc_t,
EDirect.DOWN_LEFT:$rc_dl, EDirect.DOWN_RIGHT:$rc_dr, EDirect.TOP_LEFT:$rc_tl, EDirect.TOP_RIGHT:$rc_tr}
#static var item_number:int = 0

# анимация перемещения предмета
func move(direct:Vector2):
	occupied[self] = Rect2(global_position + direct, Vector2(width, width))
	var move_tween = get_tree().create_tween()
	move_tween.tween_property(self, "position", position + direct , move_time)
	is_moving = true
	# твин начнёт анимацию при выходе из функции, по завершении анимации будет вызвал колбек
	move_tween.tween_callback(on_moved)
	
func on_moved():
	if occupied.erase(self) == false:
		print("Error when erase occupied item ", name)
	is_moving = false
	# взываем повторно функцию движения предмета, если есть куда двигаться
	check_move()
	
# ищем направление для движения предмета
func move_direct():
	if is_moving or $cs_get_hit.disabled or is_hole:
		return
	# нужно вручную обновлять состояние рейкастов если двигали предмет в течении одного кадра,
	# рейкасты обновятся со следующего кадра
	$rc_d.force_raycast_update()
	$rc_dl.force_raycast_update()
	$rc_dr.force_raycast_update()

	# проверяем находимся ли мы на чём-то с чего нельзя соскользнуть
	var down = $rc_d.get_collider()
	if down is AreaItem and (down.is_hole or down.is_moving):
		return
	# проверяем есть ли свободное место для соскальзывания
	if not try_move(to_down, $rc_d.get_collider()):
		if not try_move(to_down_left, $rc_dl.get_collider()):
			if not try_move(to_down_right, $rc_dr.get_collider()):
				# стоим наместе, проверим есть ли матч с соседями
				matching()
	
# пробуем найти пустое место куда будем двигаться
func try_move(direct:Vector2, item:Object)->bool:
	if item is StaticBody2D or item is AreaItem or is_occupied(Rect2(global_position + direct, Vector2(width, width))):
		return false
	
	move(direct)
	return true

# проверяем, пустое место которое мы нашли уже кем-то занято для перемещения?
func is_occupied(rect:Rect2)->bool:
	for ocup_item in occupied:
		if rect.intersects(occupied[ocup_item]):
			return true
	return false
	
#func _ready():
	#$Label.text = str(item_number)
	#name = $Label.text
	#item_number += 1
	#check_move()

# матчимся с соседями.
# если стоит флаг is_check - значит не удаляем сматченые предметы, а только сообщаем что матч есть
func matching(is_check:bool = false)->bool:
	# проходим по вертикали и горизонтали в поисках предметов схожих по типу с нашим
	var matchers_h:Array[AreaItem]
	check_match(matchers_h, EDirect.LEFT)
	check_match(matchers_h, EDirect.RIGHT)
	var matchers_v:Array[AreaItem]
	check_match(matchers_v, EDirect.TOP)
	check_match(matchers_v, EDirect.DOWN)
	
	# есть пересечение по вертикали и горизонтали - объединяем в один матч
	if matchers_h.size() > 1 and matchers_v.size() > 1:
		matchers_h.append_array(matchers_v.duplicate())
		matchers_v.clear()
		
	if matchers_h.size() > 1:
		if !is_check:
			remove_items_and_me(matchers_h)
		return true
	if matchers_v.size() > 1:
		if !is_check:
			remove_items_and_me(matchers_v)
		return true
	return false
	
func remove_items_and_me(items:Array[AreaItem]):
	#TODO выдать награду или подменить на матчера
	#включить нанесение ущерба соседям и вызвать удар у них через компонент
	for item in items:
		item.hit(_hardness, 1)
	self.hit(_hardness, 1)
	
# дергаем когда нужно проверить доступность следующего шага.
# отдельным методом сделано для вызова через группу от сцены игрового поля.
# узлы предметов инитятся неравномерно, пока один проверяет соседей другой может ещё быть не создан.
# дожидаемся инита сцены игрового поля и уже тогда разрешаем, предметам подписанным на группу, делать шаг.
func check_move():
	call_deferred("move_direct")
	
# после матча предметов мы их удаляем, а вот соседи не знают что под ними пустота, нужно им об этом сказать
func notify_neibors():
	for key in directs:
		directs[key].force_raycast_update()
		var item = directs[key].get_collider()
		if item and item is AreaItem:
			item.check_move()

# урон по предмету с твердостью и отнятием хр
func hit(hardness:int = 1, hit_xp:int = 1):
	# уже удалены
	if $cs_get_hit.disabled:
		return
	
	if _hardness <= hardness:
		xp -= hit_xp
		
	if xp <= 0:
		# если по какой-то причине в списке броней осталась наша запись удаляем её.
		occupied.erase(self)
		# наша зона больше не видна никому и не колайдит, тихо помираем не мешая живым
		$cs_get_hit.disabled = true
		# говорим соседям, что можно занимать наше место
		notify_neibors()
		queue_free()
	else:
		call_deferred("move_direct")

# проверяем по указанному направлению (горизонтально или вертикально) соседство предметов которые могут сматчиться
func check_match(matchers:Array[AreaItem], direct:EDirect):
	# выбираем датчик рейкаста по направлению и смотрим какой предмет он пересекает
	var next = directs[direct].get_collider() as AreaItem
	# предмет должен быть того же типа и не падать
	if next and next != self and next.is_moving == false and next.item_name == item_name:
		if not next in matchers:
			# в массив, переданный в аргументе по ссылке, собираем всех подходящих соседей рекурсивно
			matchers.append(next)
		next.check_match(matchers, direct)

# иногда, после удаления предмета мы не успеваем предупредить соседей, по таймеру проверяем есть ли вокруг свободное место
func _on_timer_timeout():
	call_deferred("move_direct")

# свап предметов по тапу мыши с зажиманием и отпусканием
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if $cs_get_hit.disabled or is_hole or is_moving:
				swap_node = null
				return
			swap_node = self
		if event.is_released():
			if swap_node != self and $cs_get_hit.disabled == false and is_hole == false and is_moving == false:
				var direct = get_direction(swap_node)
				# проверяем, что свап с соседом и есть матч
				if direct != EDirect.NONE and can_swap(direct):
					swap(direct)
			swap_node = null

# проверяем есть ли матч при свапе
func can_swap(direct:EDirect)->bool:
	if swap_node:
		var old_position_self = global_position
		var old_position_other = swap_node.global_position
		global_position += get_shift(direct)
		var oposit_direct = get_oposit_direct(direct)
		if oposit_direct != EDirect.NONE:
			swap_node.global_position += get_shift(oposit_direct)
			# помним про перемещение в течении одного кадра, обновляем рейкасты для новой позиции
			notify_neibors()
			swap_node.notify_neibors()
			
			if matching(true) or swap_node.matching(true):
				global_position = old_position_self
				swap_node.global_position = old_position_other
				return true
			else:
				global_position = old_position_self
				swap_node.global_position = old_position_other
	
	return false
			
func swap(direct:EDirect):
	if direct != EDirect.NONE:
		try_move(get_shift(direct), directs[direct])
		var oposit_direct = get_oposit_direct(direct)
		if oposit_direct != EDirect.NONE:
			swap_node.try_move(get_shift(oposit_direct), directs[oposit_direct])

func get_direction(item:AreaItem)->EDirect:
	var dist = item.global_position - self.global_position
	if abs(dist.x) > 50 and abs(dist.x) < 140:
		return EDirect.RIGHT if dist.x > 0 else EDirect.LEFT
	if abs(dist.y) > 50 and abs(dist.y) < 140:
		return EDirect.DOWN if dist.y > 0 else EDirect.TOP
	return EDirect.NONE
	
func get_shift(direct:EDirect)->Vector2:
	match direct:
		EDirect.LEFT:
			return to_left
		EDirect.RIGHT:
			return to_right
		EDirect.DOWN:
			return to_down
		EDirect.TOP:
			return to_top
		
	return Vector2.ZERO
	
func get_oposit_direct(direct:EDirect)->EDirect:
	match direct:
		EDirect.LEFT:
			return EDirect.RIGHT
		EDirect.RIGHT:
			return EDirect.LEFT
		EDirect.DOWN:
			return EDirect.TOP
		EDirect.TOP:
			return EDirect.DOWN
		
	return EDirect.NONE
