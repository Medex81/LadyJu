# Задача отображает предмет или одно из условий которое нужно выполнить для прохождения уровня.

@tool
extends Panel
class_name Task

const condition_steps = "steps"
# предметы и компоненты отправляют на имя группы задач события завершения и т.д.
const group:String = "task"
const final_fn:String = "on_final_item"

@export var _count:int = 1
# указатель на панель задач, которая управляет состоянием прохождения уровня
@export var tasks_panel:TasksPanel = null
# флаг, по которому мы определеяем - задача с условием или с предметом для собирания. Условия тоже на InfoComponent работают.
@export var is_item:bool = true
# имя предмета или условия
var _item_name:String
# имя задачи формируемое из имени предмета и количества
var _task_name:String

func _ready() -> void:
	$count.text = str(_count)
	for child in get_children():
		if child is InfoComponent:
			_item_name = child.get_item_name()
			break
	if _item_name.is_empty():
		print("Error. No item name in task!")
		return
	_task_name = _item_name if not is_item else _item_name + "_" + $count.text
	$done.visible = false

# обработчик группы для событий предметов и компонент - завершение
func on_final_item(final_item_name:String):
	if final_item_name == _item_name and _count > 0:
		_count -= 1
		$count.text = str(_count)
		if _count == 0:
			$done.visible = true
			if tasks_panel:
				tasks_panel.task_done(_task_name)
				
func get_task_name()->String:
	return _task_name
		
func get_item_name()->String:
	return _item_name
