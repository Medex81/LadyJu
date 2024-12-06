extends RigidBody2D

class_name EasyItem

enum EItemGroup{NONE, COMMON, MATCHER}
enum EDirect{LEFT, RIGHT, DOWN, TOP}

@export var item_group:EItemGroup = EItemGroup.NONE
@export var item_name:String
@export var move_time:float = 0.25

# ширина отскока в сторону - равна ширине предмета!
const width = 128
# подпрыгиваем вверх чтобы не зацепить платформу на которую запрыгиваем
const to_down_left = Vector2(-width, width)
const to_down_right = Vector2(width, width)
const to_down = Vector2(0, width)
const to_top = Vector2(0, -width)
const to_right = Vector2(width, 0)
const to_left = Vector2(-width, 0)
var is_hit = false

static var swap_node:EasyItem = null
static var occupied:Dictionary

var is_sliding:bool = false
@onready var directs:Dictionary = {EDirect.LEFT:$rc_l, EDirect.RIGHT:$rc_r, EDirect.DOWN:$rc_d, EDirect.TOP:$rc_t}
@onready var direct_dist:Dictionary
static var item_number:int = 0

func _ready():
	$Label.text = str(item_number)
	name = $Label.text
	item_number += 1

# метод вызывается сигналом при столкношении с другим предметом
# body_rid - цифровой идентификатор с кем столкнулись
# body - предмет
# body_shape_index - физическое тело предмета с которым столкнулись (может быть несколько)
# local_shape_index - наше физическое тело с которым столкнулся предмет (может быть несколько)
# 0 - top
# 1 - down
func _on_body_shape_entered(_body_rid, body, body_shape_index, local_shape_index):
	raycast_update()
		
	if is_falling() or (body is EasyItem and body.is_falling()):
		print("falling ", name, " - ", body.name)
		return
		
	print("jamping ", name, " - ", body.name)

	# нужно знать, что мы упали низом на верх предмета	
	if local_shape_index == 1 and body_shape_index == 0 and body is EasyItem:
		print("impact ", name, " - ", body.name)
		call_deferred("check_move")
	
func check_move():
	# внизу сбоку нет предмета и слева\справа нет предметов в которые мы уткнёмся при прыжке
	if not $rc_dr.is_colliding() and not ($rc_r.get_collider() as EasyItem):# and not test_move(transform, to_down_right):
		move_anim(to_down_right)
		return
	if not $rc_dl.is_colliding() and not ($rc_l.get_collider() as EasyItem):# and not test_move(transform, to_down_left):
		move_anim(to_down_left)
		return
	#var hor_distance = int(position.x) % width

	# проверяем матч по вертикали и горизонтали
	matching()
	
func raycast_update():
	$rc_d.force_raycast_update()
	$rc_l.force_raycast_update()
	$rc_r.force_raycast_update()
	$rc_t.force_raycast_update()
	$rc_dl.force_raycast_update()
	$rc_dr.force_raycast_update()
	$rc_tl.force_raycast_update()
	$rc_tr.force_raycast_update()
	
#func can_falldown()->bool:
	#var dl = $rc_dl.get_collider() as EasyItem
	#var dr = $rc_dr.get_collider() as EasyItem
	#if dl
	
func move_anim(direct:Vector2):
	if not is_occupied(Rect2(global_position + direct, Vector2(width, width))):
		is_sliding = true
		$cs_detect.disabled = true
		#$cs_top.disabled = true
		$cs_down.disabled = true
		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position + direct , move_time)
		occupied[self] = Rect2(global_position + direct, Vector2(width, width))
		
		await tween.finished
		
		$cs_detect.disabled = false
		$cs_down.disabled = false
		#$cs_top.disabled = false
		is_sliding = false
		
		occupied.erase(self)
		matching()
	
func is_occupied(rect:Rect2)->bool:
	for ocup_item in occupied:
		if rect.intersects(occupied[ocup_item]):
			return true
	return false

func hit():
	if is_hit:
		return
	is_hit = true
	queue_free()
	print("hit_free ", self.name)

# если внизу нет ничего - значит предмет ещё падает
func is_falling()->bool:
	return not $rc_d.is_colliding()
	
func on_static()->bool:
	var item = $rc_d.get_collider()
	if item and item is StaticBody2D:
		return true
	return false
	
func is_neighbour(item:EasyItem)->bool:
	return  item and ($rc_d.get_collider() == item \
	or $rc_r.get_collider() == item \
	or $rc_l.get_collider() == item \
	or $rc_t.get_collider() == item)
	
func matching()->bool:
	var matchers_h:Array[EasyItem]
	check_match(matchers_h, EDirect.LEFT)
	check_match(matchers_h, EDirect.RIGHT)
	var matchers_v:Array[EasyItem]
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
	
func remove_items_and_me(items:Array[EasyItem]):
	#TODO выдать награду или подменить на матчера
	#включить нанесение ущерба соседям и вызвать удар у них через компонент
	for item in items:
		item.hit()
	self.hit()
	
# проверяем по указанному направлению (горизонтально или вертикально) соседство предметов которые могут сматчиться
func check_match(matchers:Array[EasyItem], direct:EDirect):
	# выбираем датчик рейкаста по направлению и смотрим какой предмет он пересекает
	#raycast_update()
	var next = directs[direct].get_collider() as EasyItem
	# предмет должен быть того же типа и не падать
		
	if next and next != self and next.item_name == item_name and not next.is_falling():
		if not next in matchers:
			# в массив, переданный в аргументе по ссылке, собираем всех подходящих соседей рекурсивно
			matchers.append(next)
		next.check_match(matchers, direct)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			swap_node = self
		if event.is_released():
			#is_swaping = true
			if swap_node != self:
				swap_anim(swap_node)
			swap_node = null
			
func swap_anim(item:EasyItem):
	if item:
		item.move_anim(to_right)
		move_anim(to_left)
		pass
			
func _on_timer_timeout():
	pass
	#if not is_freeze_enabled() and not is_falling() and not on_static():
		#if not $rc_dr.is_colliding() and not $rc_r.is_colliding():
			#move_and_collide(to_right)
			#return
		#if not $rc_dl.is_colliding() and not $rc_l.is_colliding():
			#move_and_collide(to_left)
			#return
