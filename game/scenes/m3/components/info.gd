# Компонент информации отвечает за индивидуальные параметры предмета, например название и тип.
# Компонент может выступать контейнером для других компонент с параметрами для типов.

extends Node

class_name InfoComponent

@export var item_name:String = "NONE"

signal send_item_name(_item_name:String)

func get_first_child()->Node:
	return get_child(0) if get_child_count() else null
	
func _ready() -> void:
	send_item_name.emit(item_name)
