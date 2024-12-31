# Компонент отвечает за перемещение родительского узла. Перемещение осуществляется через твин и свойство позиции.
# Перемещение происходит на расстояние ширины области коллизии. Место на которое перемещается узел 
# занимается через статический словарь и освобождается при завершении перемещения(для избежания двойного занятия).
# Приоретет в занятии места у узла падающего вниз. Свап предметов работает по горизонтали и ветрикали через
# статическое поле с указателем узла перехода.

extends Area2D

class_name MoverComponent

# время анимации перемещения
@export var _move_time:float = 0.25
@export var _width_frame = 30

@onready var _parent = get_parent()
var is_moved:bool = false
var _total_width:int
var _to_down_left:Vector2i
var _to_down_right:Vector2i
var _to_down:Vector2i
var _to_top:Vector2i
var _to_right:Vector2i
var _to_left:Vector2i
# при переходе, запоминаем квардат куда прибудем. Это нужно для синхронизации перемещений с другими предметами
# для избежания двойного занятия позиции. Словарь доступен из всех предметов.
static var occupied:Dictionary
# для свапа предметов нужно помнить предмет отправитель и получатель для обмена позициями.
static var swap_node:MoverComponent = null

signal send_move_stopped(is_stopped:bool)

func _on_timer_timeout():
	call_deferred("move")
	
# проверяем, пустое место которое мы нашли уже кем-то занято для перемещения?
func _is_occupied(rect:Rect2i)->bool:
	for ocup_item in occupied:
		if rect.intersects(occupied[ocup_item]):
			return true
	return false
	
func is_fall()->bool:
	$collision/rc_d.force_raycast_update()
	return not ($collision/rc_d.get_collider() is MoverComponent)
	
func direct()->Vector2i:
	# проверяем находимся ли мы на чём-то с чего нельзя соскользнуть
	$collision/rc_d.force_raycast_update()
	$collision/rc_dl.force_raycast_update()
	$collision/rc_dr.force_raycast_update()
	$collision/rc_r.force_raycast_update()
	$collision/rc_l.force_raycast_update()
	var cld_d = $collision/rc_d.get_collider()
	var cld_dl = $collision/rc_dl.get_collider()
	var cld_dr = $collision/rc_dr.get_collider()
	var cld_l = $collision/rc_l.get_collider()
	var cld_r = $collision/rc_r.get_collider()
		
	var glob_pos_i = Vector2i(_parent.global_position)
	# внизу кто-то есть
	if cld_d:
		# статический объект - останавливаемся, по нему не скользим
		if cld_d is StaticBody2D:
			$Timer.stop()
			send_move_stopped.emit(true)
			return Vector2i.ZERO
		# предмет который двигается, притормаживаем и ждём когда он отдалится
		if cld_r is MoverComponent and cld_d.is_fall():
			return Vector2i.ZERO
	# внизу никого, проверяем двигается ли уже кто-то в это место
	elif not _is_occupied(Rect2i(glob_pos_i + _to_down, _to_down_right)):
		return _to_down
	# лево вниз никого, проверяем что место не занято и слева паралельно нам по соседству не падает предмет
	if cld_dl == null \
	and not _is_occupied(Rect2i(glob_pos_i + _to_down_left, _to_down_right)) \
	and (cld_l == null or (cld_l is MoverComponent and not cld_l.is_fall())):
		return _to_down_left
		
	if cld_dr == null \
	and not _is_occupied(Rect2i(glob_pos_i + _to_down_right, _to_down_right))\
	and (cld_r == null or (cld_r is MoverComponent and not cld_r.is_fall())):
		return _to_down_right
	
	send_move_stopped.emit(true)
	return Vector2i.ZERO
	
func move(_direct:Vector2i = Vector2i.ZERO):
	if is_moved:
		return
	if _direct == Vector2i.ZERO:
		_direct = direct()
	if _direct == Vector2i.ZERO:
		return

	send_move_stopped.emit(false)
	is_moved = true
	occupied[self] = Rect2i(Vector2i(_parent.global_position) + _direct, _to_down_right)
	var move_tween = get_tree().create_tween()
	move_tween.tween_property(_parent, "position", _parent.global_position + Vector2(_direct) , _move_time)
	await move_tween.finished
	occupied.erase(self)
	is_moved = false
	call_deferred("move")

func _get_direction(item:MoverComponent)->Vector2i:
	var dist = item.global_position - self.global_position
	var ax = abs(dist.x)
	var ay = abs(dist.y)
	if ax < _total_width and ay < _total_width and (ax < _width_frame or ay < _width_frame):
		return dist

	return Vector2i.ZERO

# свап предметов по тапу мыши с зажиманием и отпусканием
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if is_moved:
				swap_node = null
				return
			swap_node = self
		if event.is_released():
			# тап на матчер, подрывам его одного
			if swap_node == self or swap_node == null or swap_node.is_moved or is_moved:
				swap_node = null
				return
				
			var _direct = _get_direction(swap_node)
			# проверяем, что свап с соседом
			if _direct != Vector2i.ZERO:
				move(_direct)
				swap_node.move(-_direct)
				
			swap_node = null

func _on_collision_ready() -> void:
	var width = $collision.shape.size.x
	_total_width = width + _width_frame
	_to_down_left = Vector2i(-width, width)
	_to_down_right = Vector2i(width, width)
	_to_down = Vector2i(0, width)
	_to_top = -_to_down
	_to_right = Vector2i(width, 0)
	_to_left = -_to_right
	
func _enter_tree() -> void:
	start_move()
	
func start_move():
	is_moved = false
	$Timer.start()
	
func stop_move():
	$Timer.stop()
	is_moved = true
	position = Vector2.ZERO
