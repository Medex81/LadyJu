# Компонент информации отвечает за индивидуальные параметры предмета, например название и тип.
# Компонент может выступать контейнером для других компонент с параметрами для типов.

extends Node

class_name InfoComponent

@export var item_name:String = "NONE"
@export var cell_size:int = 128

func get_item_name()->String:
	return item_name
	
func get_item_size()->int:
	return cell_size
	
