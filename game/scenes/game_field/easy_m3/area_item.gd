extends Area2D

class_name AreaItem

const width = 128
# подпрыгиваем вверх чтобы не зацепить платформу на которую запрыгиваем
const to_down_left = Vector2(-width, width)
const to_down_right = Vector2(width, width)
const to_down = Vector2(0, width)
const to_top = Vector2(0, -width)
const to_right = Vector2(width, 0)
const to_left = Vector2(-width, 0)
@export var move_time:float = 0.25
var is_moving:bool = false
static var occupied:Dictionary
enum EDirect{LEFT, RIGHT, DOWN, TOP, DOWN_LEFT, DOWN_RIGHT, TOP_LEFT, TOP_RIGHT}
@onready var directs:Dictionary = {EDirect.LEFT:$rc_l, EDirect.RIGHT:$rc_r, EDirect.DOWN:$rc_d, EDirect.TOP:$rc_t,
EDirect.DOWN_LEFT:$rc_dl, EDirect.DOWN_RIGHT:$rc_dr, EDirect.TOP_LEFT:$rc_tl, EDirect.TOP_RIGHT:$rc_tr}
var item_name:String # path!
const _hardness:int = 2
var life = 1

func move(direct:Vector2):
	occupied[self] = Rect2(global_position + direct, Vector2(width, width))
	var move_tween = get_tree().create_tween()
	move_tween.tween_property(self, "position", position + direct , move_time)
	is_moving = true
	move_tween.tween_callback(on_moved)
	
func on_moved():
	if occupied.erase(self) == false:
		print("Error when erase occupied item ", name)
	is_moving = false
	matching()
	check_move()
	
func move_direct():
	if is_moving or $cs_get_hit.disabled:
		return
	$rc_d.force_raycast_update()
	$rc_dl.force_raycast_update()
	$rc_dr.force_raycast_update()

	if not try_move(to_down, $rc_d.get_collider()):
		if not try_move(to_down_left, $rc_dl.get_collider()):
			try_move(to_down_right, $rc_dr.get_collider())
	
func try_move(direct:Vector2, item:Object)->bool:
	if item is StaticBody2D or item is AreaItem or is_occupied(Rect2(global_position + direct, Vector2(width, width))):
		return false
	
	move(direct)
	return true

func is_occupied(rect:Rect2)->bool:
	for ocup_item in occupied:
		if rect.intersects(occupied[ocup_item]):
			return true
	return false
	
func _ready():
	check_move()

func matching()->bool:
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
		remove_items_and_me(matchers_h)
		return true
	if matchers_v.size() > 1:
		remove_items_and_me(matchers_v)
		return true
	return false
	
func remove_items_and_me(items:Array[AreaItem]):
	#TODO выдать награду или подменить на матчера
	#включить нанесение ущерба соседям и вызвать удар у них через компонент
	for item in items:
		item.hit(_hardness, 1)
	self.hit(_hardness, 1)
	
func check_move():
	call_deferred("move_direct")
	
func notify_neibors():
	for key in directs:
		directs[key].force_raycast_update()
		var item = directs[key].get_collider()
		if item and item is AreaItem:
			item.check_move()

func hit(hardness:int = 1, power:int = 1):
	if $cs_get_hit.disabled:
		return
	
	if _hardness <= hardness:
		life -= power
		
	if life <= 0:
		occupied.erase(self)
		$cs_get_hit.disabled = true
		notify_neibors()
		print("remove item ", item_name)
		queue_free()
	else:
		call_deferred("move_direct")

# проверяем по указанному направлению (горизонтально или вертикально) соседство предметов которые могут сматчиться
func check_match(matchers:Array[AreaItem], direct:EDirect):
	# выбираем датчик рейкаста по направлению и смотрим какой предмет он пересекает
	var next = directs[direct].get_collider() as AreaItem
	# предмет должен быть того же типа и не падать
	get_path()
	if next and next != self and next.is_moving == false and next.item_name == item_name:
		if not next in matchers:
			# в массив, переданный в аргументе по ссылке, собираем всех подходящих соседей рекурсивно
			matchers.append(next)
		next.check_match(matchers, direct)


#func _on_timer_timeout():
	#if is_moving or $cs_get_hit.disabled:
		#return
	#call_deferred("move_direct")
