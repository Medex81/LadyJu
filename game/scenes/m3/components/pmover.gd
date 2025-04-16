extends Node2D

class_name PMoverComponent

const down_right = Vector2.ONE
const top_left = -down_right
const top_right = Vector2(1, -1)
const down_left = -top_right
const mover_group = "movers"
const try_move_fn = "try_move"

# время анимации перемещения
@export var _move_time:float = 0.25
@export var _match_component:MatcherComponent = null
@export var info_component:InfoComponent = null
@export var _damager_component:DamageContainerComponent = null
@export var _hint_component:HintComponent = null
@export var _swap_move_logic:BaseMoveComponent = null

enum EMoveState{STOP, FALL, FINAL}

var move_state:EMoveState = EMoveState.FALL
var _cell_width = 128
var _item_name:String
var is_moving:bool = false
var moving_to_rect:Rect2
var cell_size:Vector2 = Vector2(_cell_width, _cell_width)

static var swap_node:PMoverComponent = null

func get_item_name()->String:
	return _item_name

func _ready() -> void:
	if info_component:
		_cell_width = info_component.get_item_size()
		cell_size = Vector2(_cell_width, _cell_width)
		_item_name = info_component.get_item_name()
	moving_to_rect = Rect2(global_position, cell_size)
	
func try_move():
	if is_moving == true or (info_component != null and not info_component.is_movable()):
		return

	# проверяем находимся ли мы на чём-то с чего нельзя соскользнуть
	# при движении узлы рейкаста не обновляются до конца кадра, обновляем принудительно.
	$rc_r.force_raycast_update()
	$rc_l.force_raycast_update()
	$rc_d.force_raycast_update()
	$rc_dl.force_raycast_update()
	$rc_dr.force_raycast_update()
	var right = $rc_r.get_collider()
	var left = $rc_l.get_collider()
	var down = $rc_d.get_collider()
	var down_l = $rc_dl.get_collider()
	var down_r = $rc_dr.get_collider()

	var direct:Vector2 = Vector2.ZERO
	if down == null:
		direct = Vector2.DOWN
	elif down is PMoverComponent:
		if (not right is PMoverComponent or (right.info_component != null and  right.info_component.is_blocked())) and down_r == null:
			direct = down_right
		elif (not left is PMoverComponent or (left.info_component != null and  left.info_component.is_blocked())) and down_l == null:
			direct = down_left

	if info_component and direct != Vector2.ZERO and not _is_occupied(Rect2(global_position + direct * _cell_width, cell_size)):
		moving_to_rect = Rect2(global_position + direct * _cell_width, cell_size)
		move_state = EMoveState.FALL
		is_moving = true
		var move_tween = get_tree().create_tween()
		move_tween.tween_property(info_component, "global_position", global_position + direct * _cell_width, _move_time)
		await move_tween.finished
		is_moving = false
		call_deferred(try_move_fn)
	else:
		if move_state == EMoveState.FALL:
			move_state = EMoveState.STOP
			get_tree().call_group(QuestsPanel.group_name, QuestsPanel.on_stop_move_fn)
			if _hint_component:
				_hint_component.on_all_stopped()
		matching()
	
func swap_move(direct:Vector2, second_mover:PMoverComponent = null, is_step_counting:bool = true):
	if is_moving == true or (info_component != null and info_component.is_active == false):
		return
		
	is_moving = true
	var second_name = second_mover.info_component.get_item_name() if second_mover != null and second_mover.info_component != null else ""
	if info_component and direct != Vector2.ZERO:
		# в компонент нанесения урона устанавливаем имя второго предмета для определения нужно ли усиление
		if _damager_component and not second_name.is_empty() and info_component is MatchInfoComponent:
			_damager_component.set_swap_item_name(second_name)
		# бронируем позицию для перехода
		moving_to_rect = Rect2(global_position + direct * _cell_width, cell_size)
		
		var move_tween = get_tree().create_tween()
		move_tween.tween_property(info_component, "global_position", global_position + direct * _cell_width, _move_time)
		await move_tween.finished
		
		if info_component is MatchInfoComponent:
			# всё - компонент больше нельзя использовать
			move_state = EMoveState.FINAL
			# логика свапа была установлена для этого предмета
			var is_swap_logic = info_component.proc_swap_logic(second_mover.info_component)
			# логика перемещения при свапе была установлена для этого предмета
			if _swap_move_logic != null:
				is_moving = true
				_swap_move_logic.start(info_component)
				await _swap_move_logic.send_done
				is_moving = false
			# если была установлена логика предмета для свапа - завершаем его иначе его должны завершить в другом месте.
			if is_swap_logic:
				info_component.finalize()
		else:
			matching()
		if is_step_counting:
			get_tree().call_group(Quest.group_name, Quest.on_final_item_fn, QuestsPanel.quest_step)

	is_moving = false

# проверяем, пустое место которое мы нашли уже кем-то занято для перемещения?
func _is_occupied(rect:Rect2)->bool:
	for mover in get_tree().get_nodes_in_group(mover_group):
		if mover != self and rect.intersects(mover.moving_to_rect):
			return true
	return false
	
func has_swap_move()->bool:
	return info_component != null and not info_component.is_blocked() and _swap_move_logic != null and move_state != EMoveState.FINAL
	
func final_swap_move_logic():
	if info_component is MatchInfoComponent and not info_component.is_blocked() and _swap_move_logic != null and move_state != EMoveState.FINAL:
		move_state = EMoveState.FINAL
		is_moving = true
		_swap_move_logic.start(info_component)
		await _swap_move_logic.send_done
		is_moving = false
		info_component.finalize()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			# когда движемся не нужно запускать ещё одно параллельное движение
			if is_moving:
				swap_node = null
				return
			swap_node = self
		if event.is_released() and QuestsPanel.is_no_step == false:
			# тап на матчер, подрывам его одного
			if swap_node == self and info_component is MatchInfoComponent:
				info_component.proc_swap_logic()
				if not info_component.is_blocked() and _swap_move_logic != null:
					move_state = EMoveState.FINAL
					is_moving = true
					_swap_move_logic.start(info_component)
					await _swap_move_logic.send_done
					is_moving = false
				get_tree().call_group(Quest.group_name, Quest.on_final_item_fn, QuestsPanel.quest_step)
				info_component.finalize()
			else:
				# если предмет не стоит или стремный - отбрасываем свап
				if not swap_node is PMoverComponent or swap_node.is_moving or is_moving:
					swap_node = null
					return
					
				# сматчивание с матчером
				if info_component is MatchInfoComponent or swap_node.info_component is MatchInfoComponent:
					var direct = global_position.direction_to(swap_node.global_position).sign()
					swap_move(direct, swap_node, false)
					swap_node.swap_move(-direct, self)
				elif set_fake_item_name(swap_node.get_item_name()) and swap_node.set_fake_item_name(get_item_name()) \
				and (swap_node.check_match() or check_match()):
					set_fake_item_name()
					swap_node.set_fake_item_name()
					var direct = global_position.direction_to(swap_node.global_position).sign()
					swap_move(direct, null, false)
					swap_node.swap_move(-direct)
				
				set_fake_item_name()
				if swap_node:
					swap_node.set_fake_item_name()
			swap_node = null

func check_match()->bool:
	return _match_component and _match_component.has_match()
	
func matching()->bool:
	return _match_component and _match_component.matching()
	
func timer_matching(timeout:float = 2.0)->bool:
	await get_tree().create_timer(timeout).timeout
	print("pmover->match check")
	return _match_component and _match_component.matching()

func set_fake_item_name(new_item_name:String = "")->bool:
	if _match_component:
		_match_component.set_fake_item_name(new_item_name)
		return true
	return false
