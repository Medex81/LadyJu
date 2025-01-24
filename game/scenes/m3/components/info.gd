# Компонент информации отвечает за индивидуальные параметры предмета, например название и тип.
# Компонент может выступать контейнером для других компонент с параметрами для типов.
# Главный компонент info остальные - дочерние по отношению к нему.

extends Node

class_name InfoComponent

const none = "NONE"
@export var item_name:String = none

signal send_name_change(_item_name:String)

func _ready() -> void:
	send_name_change.emit(item_name)
	
