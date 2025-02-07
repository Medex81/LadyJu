# Компонент отвечает за перемещение родительского узла. Перемещение осуществляется через твин и свойство позиции.
# Перемещение происходит на расстояние ширины области коллизии. Место на которое перемещается узел 
# занимается через статический словарь и освобождается при завершении перемещения(для избежания двойного занятия).
# Приоретет в занятии места у узла падающего вниз. Свап предметов работает по горизонтали и ветрикали через
# статическое поле с указателем узла перехода.

extends Area2D

class_name MoverComponent

# данные по состоянию свапа с соседом
class SwapData:
	# свапа нет или после свапа нет матча
	var _is_active:bool = false
	# сосед с которым произошел свап
	var _second_component:MoverComponent = null
	# направление свапа текущего компонента
	var _direction:Vector2i = Vector2i.ZERO
	
	# в начале свапа запоминаем кто и куда перемещается и устанавливаем состояние активен
	func begin(second_component:MoverComponent, direction:Vector2i):
		_is_active = true
		_second_component = second_component
		_direction = direction
		
	# данных по свапу нет - при выходе из сцены или на автоперемещении
	func clean():
		_is_active = false
		_second_component = null
		_direction = Vector2i.ZERO
	# после свапа нет матча - нужно вернуться назад
	func fail():
		_is_active = false
	# компонент в состоянии свапа?
	func is_active()->bool:
		return _is_active
	# может ли компонент вернуться назад?
	# может только при условии, что второй участник и мы не сматчились.
	# при этом мы активны, а второй участник нет(или наоборот, смотря кто первый получил ответ по матчу)
	func can_revert()->bool:
		if _second_component and not _second_component.swap_data.is_active():
			return true
		return false
		
	func get_direct()->Vector2i:
		return _direction
		
	func get_second_component()->MoverComponent:
		return _second_component

var swap_data:SwapData = SwapData.new()
# шаг перемещения или размер клетки поля.
var _cell_size = 128
	
# время анимации перемещения
@export var _move_time:float = 0.25
@export var _width_frame = 30
# немного оптимизации, не дёргаем зря метод, а обращаемся к полю с указателем на родителя
@onready var _parent = get_parent()
@export var  _get_item_size_fn = "get_item_size"

var is_moved:bool = false
var _total_width:int
var _to_down_left:Vector2i
var _to_down_right:Vector2i
var _to_down:Vector2i
var _to_top:Vector2i
var _to_right:Vector2i
var _to_left:Vector2i
var is_falling:bool = true

# при переходе, запоминаем квардат куда прибудем. Это нужно для синхронизации перемещений с другими предметами
# для избежания двойного занятия позиции. Словарь доступен из всех компонент перемещения.
static var occupied:Dictionary
# для свапа предметов нужно помнить предмет отправитель и получатель для обмена позициями.
static var swap_node:MoverComponent = null

# оповещаем о событии остановки или начала движения предмета. Это нужно, например, для проверки матчинга.
signal send_swap_done()
signal send_start_step()
signal send_stop()

# когда предмет остановился, он проверяет соседей на матч или движение один раз. Если внизу предмет
# пропал, нужно включить перемещение.
func _on_timer_timeout():
	call_deferred("move")
	
# проверяем, пустое место которое мы нашли уже кем-то занято для перемещения?
func _is_occupied(rect:Rect2i)->bool:
	for ocup_item in occupied:
		if rect.intersects(occupied[ocup_item]):
			return true
	return false
	
# предмет находится в состоянии движения/не остановился - с таким предметом нельзя матчится и т.д.
func is_fall()->bool:
	return is_falling

# расчитываем направление для перемещения	
func direct()->Vector2i:
	# проверяем находимся ли мы на чём-то с чего нельзя соскользнуть
	# при движении узлы рейкаста не обновляются до конца кадра, обновляем принудительно.
	$rc_d.force_raycast_update()
	$rc_dl.force_raycast_update()
	$rc_dr.force_raycast_update()
	$rc_r.force_raycast_update()
	$rc_l.force_raycast_update()
	var cld_d = $rc_d.get_collider()
	var cld_dl = $rc_dl.get_collider()
	var cld_dr = $rc_dr.get_collider()
	var cld_l = $rc_l.get_collider()
	var cld_r = $rc_r.get_collider()
		
	var glob_pos_i = Vector2i(_parent.global_position)
	# внизу кто-то есть
	if cld_d:
		# статический объект - останавливаемся, по нему не скользим
		if cld_d is StaticBody2D:
			$Timer.stop()
			is_falling = false
			send_stop.emit()
			return Vector2i.ZERO
		# предмет который двигается, притормаживаем и ждём когда он отдалится
		if cld_d is MoverComponent and cld_d.is_fall():
			return Vector2i.ZERO
	# внизу никого, проверяем двигается ли уже кто-то в это место
	elif not _is_occupied(Rect2i(glob_pos_i + _to_down, _to_down_right)):
		is_falling = true
		return _to_down
	# лево вниз никого, проверяем что место не занято и слева паралельно нам по соседству не падает предмет
	if cld_dl == null \
	and not _is_occupied(Rect2i(glob_pos_i + _to_down_left, _to_down_right)) \
	and (cld_l == null or (cld_l is MoverComponent and not cld_l.is_fall())):
		is_falling = true
		return _to_down_left
		
	if cld_dr == null \
	and not _is_occupied(Rect2i(glob_pos_i + _to_down_right, _to_down_right))\
	and (cld_r == null or (cld_r is MoverComponent and not cld_r.is_fall())):
		is_falling = true
		return _to_down_right
	# сигнал об остановке отправляем только если ранее двигались и остановились
	if is_falling:
		send_stop.emit()
	is_falling = false
	return Vector2i.ZERO
	
# Иногда узел удаляется ещё в момент работы твинка и его сигнал о завершении не вызывает корутину,
# которая блокирует код завершения а методе перемещения на клетку. При выходе узла из дерева,
# руками удаляем запись о бронировании клетки для перемещения если она не была удалена корутиной. 
func _exit_tree() -> void:
	occupied.erase(self)
	swap_data.clean()
	
# двигать родительский узел на расстояние размера клетки
# is_automove = true перезапускать перемещение после завершения движения автоматически
func move(_direct:Vector2i = Vector2i.ZERO, is_automove:bool = true):
	# сейчас движемся, как закончим можно начинать следующее движение, а пока отбрасываем запрос
	if is_moved:
		return
	# запросили движение без указания направления - значит выбираем его сами
	if _direct == Vector2i.ZERO:
		_direct = direct()
	# направление не определено, нет свободных клеток или внизу движущийся предмет
	if _direct == Vector2i.ZERO:
		return

	# уведомляем о начале движения и смене состояния
	send_start_step.emit()
	is_moved = true
	# заносим в общий список всех компонент движения квадрат куда будем перемещаться, иначе а тот же
	# квадрат одновременно с нами могут двигаться и другие предметы.
	occupied[self] = Rect2i(Vector2i(_parent.global_position) + _direct, _to_down_right)
	# двигаем родителя через твин по свойству позиции
	var move_tween = get_tree().create_tween()
	move_tween.tween_property(_parent, "global_position", _parent.global_position + Vector2(_direct) , _move_time)
	# тут будет выход из метода и формирование корутины которая активируется при получении сигнала
	# от завершения твина. После получения сигнала, корутина установит на выполнение код лежащий ниже
	await move_tween.finished
	occupied.erase(self)
	is_moved = false
	# отложенный на следующий кадр вызов себя для симуляции беспрерывного падения
	if is_automove:
		call_deferred("move")
		# если у нас автоперемещение и активный свап - сбрасываем свап
		# обработка свапа по какой-то причине не отработала 
		if swap_data.is_active():
			swap_data.clean()
			print("Error. Active swap in automove!")
	else:
		# завершилось перемещение при свапе, уведомление с указанием состояния остановки
		send_stop.emit()

# расчёт смещения из текущего предмета в указанный с учётом расположения по соседству
func _get_direction_to(item:MoverComponent)->Vector2i:
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
			# когда движемся не нужно запускать ещё одно параллельное движение
			if is_moved:
				swap_node = null
				return
			swap_node = self
		if event.is_released():
			# тап на матчер, подрывам его одного
			if swap_node == self:
				send_swap_done.emit()
			else:
				# если предмет не стоит или стремный - отбрасываем свап
				if swap_node == self or swap_node == null or swap_node.is_moved or is_moved:
					swap_node = null
					return
				# переходим в позицию...
				var _direct = _get_direction_to(swap_node)
				# проверяем, что свап с соседом
				if _direct != Vector2i.ZERO:
					swap_data.begin(swap_node, _direct)
					swap_node.swap_data.begin(self, -_direct)
					# делаем одно перемещение на шаг без автоперемещения далее
					move(_direct, false)
					swap_node.move(-_direct, false)
				
			swap_node = null

func _ready() -> void:
	if _parent.has_method(_get_item_size_fn):
		_cell_size = _parent.call(_get_item_size_fn)
		_total_width = _cell_size + _width_frame
		_to_down_left = Vector2i(-_cell_size, _cell_size)
		_to_down_right = Vector2i(_cell_size, _cell_size)
		_to_down = Vector2i(0, _cell_size)
		_to_top = -_to_down
		_to_right = Vector2i(_cell_size, 0)
		_to_left = -_to_right
		
# компоненту нужно вернуться назад
func revert_move():
	# находимся в состоянии активного свапа
	if swap_data.is_active():
		# второй участник уже получил сообщение о своём неудачном свапе
		if swap_data.can_revert():
			# двигаем себя в обратном направлении
			move(-swap_data.get_direct(), false)
			# второй ещё в дереве
			var second = swap_data.get_second_component()
			if second:
				# двигаем второго обратно
				second.move(swap_data.get_direct(), false)
				# очищаем данные свапа у пары
				second.swap_data.clean()
				swap_data.clean()
		else:
			# свап обработан, второй участник ещё не готов
			swap_data.fail()

# узлы у нас делятся на создаваемые в сцене на старте и создаваемые в коде на рантайме. 
# Создаваемые узлы появляются благодаря дуплицированию уже существующих (для этого у нас есть
# узел генератора, который содержит необходимые узлы). Можно было бы их создавать через механизм создания
# узла из распакованной сцены или лоада, но
# это просадка по перформансу и необходимость составлять список узлов, а мне лень и проще визуально
# посмотреть что у нас есть в сцене чем листать свойства узлов или конфиги.
# Таймер заставляет узел двигаться, но узлы в генераторе не должны двигаться. Для этого мы отключаем
# у компонента таймер и включаем его при активации - сигналом извне(обычно от родителя в игровой области сцены).
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	$Timer.autostart = true
	$Timer.start()
