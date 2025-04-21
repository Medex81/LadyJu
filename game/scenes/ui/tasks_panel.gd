# Узел обрабатывает события задач уровня, отслеживает состояние прохождения целей.

extends GridContainer
class_name TasksPanel

const group = "tasks_panel"
const final_fn = "on_final_moving"

# верхнеуровневый объект сцены уровня, решает когда включать завершение
@export var _base_m3_layer:BaseM3Level = null

# задачи по предметам
var done_condition_tasks:Dictionary
# условия на которых квест на предмет считается не пройденым 
var fail_condition_tasks:Dictionary
# этот флаг смотрят в модуле движения предметы, если он включен то свап не срабатывает.
static var is_end:bool = false

func _ready() -> void:
	for child in get_children():
		if child is Task:
			if child.is_item:
				done_condition_tasks[child.get_task_name()] = child
			else:
				fail_condition_tasks[child.get_task_name()] = child

# задачи после завершения вызывают этот метод
func task_done(task_name:String)->bool:
	if task_name in fail_condition_tasks:
		# у нас сработало условие неудачи - запускаем таймер в течении которого может быть выбит предмет без применения свапа
		on_final_moving()
		is_end = true
		return true

	if task_name in done_condition_tasks:
		done_condition_tasks.erase(task_name)
	else:
		var quest_name = _base_m3_layer.quest_info.quest_name if _base_m3_layer and _base_m3_layer.quest_info else "none"
		print("Error. Task {0} in quest {1} is not exist.".format([task_name, quest_name]))
		return false
		
	if done_condition_tasks.is_empty() and _base_m3_layer != null:
		_base_m3_layer.events(BaseM3Level.EEvents.TASKS_DONE)
		$Timer.stop()
	
	return true
	
# дергаем через группу этот обработчик из компонента pmover, это нужно для сбора последних предметов на последнем шаге.
func on_final_moving():
	$Timer.start()

func _on_timer_timeout() -> void:
	if not done_condition_tasks.is_empty() and _base_m3_layer != null:
		_base_m3_layer.events(BaseM3Level.EEvents.CONDITION_FAIL)
