class_name Animations
extends Components

var _tween:Tween = null
var _props:Dictionary
# если запустили анимацию во время выполнения предыдущей - то есть два варианта,
# вернуться к начальным значениям или остаться в промежуточном состоянии
@export var undo_on_start:bool = true
# длительность анимации(сек).
@export var  anim_time:float = 0.4

# добавим поля, значения которых сохраним для отката при прерывании
func _add_props(arr:Array[String])->bool:
	_props.clear()
	var parent = get_parent()
	var parent_props = parent.get_property_list()
	if parent:
		for prop in arr:
			var value = parent.get(prop)
			if value != null:
				_props[prop] = value
			else:
				print("Error. Component {0}, host {1}, has no property {2}!".format([name, parent.name, prop]))
				return false
	return true

# сохраняем начальные значения изменяемых полей в узле для возможности отката к началу
func undo():
	var parent = get_parent()
	for prop in _props.keys():
		parent.set(prop, _props[prop])
	
# когда анимацию прервали, узел останется в промежуточном значении полей, при необходимости откатываем поля до начальных значений
# калбек не будет вызван, самостоятельно отправляем сигнал о завершении
func abort(is_reset:bool = false):
	# останавливаем только выполняющуюся анимацию
	if _tween and _tween.is_running():
		_tween.kill()
		if is_reset:
			undo()
		send_end.emit(name)

# запускаем подготовительный этап анимации, в аргументы передаём поля которые будем менять
func _start(arr:Array[String])->bool:
	# остановим прошлую анимацию если она запущена и откатим если нужно
	abort(undo_on_start)
	# сохранили поля и их значения (для отката) и проверили что в узле есть поля с такими именами
	if _add_props(arr):
		# говорим, что начали анимацию
		send_start.emit(name)
		return true
	return false

func is_running()->bool:
	return _tween and _tween.is_running()
	
# в цикле анимация после завершения откатывается на начальные значение и в конце повторно вызывает калбек
# мы расчитываем, что анимация в цикле это одна анимация - но это N последовательно запущенных полноценных анимаций
# поможет узлу и отправим сообщение о завершении один раз после последнего цикла
func _send_end_signal():
	if _tween and _tween.get_loops_left() == 1:
		send_end.emit(name)
