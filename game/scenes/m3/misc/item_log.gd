extends Node2D

class_name LogComponent

static var item_number:int = 0

var id:int = -1

func _ready() -> void:
	item_number += 1
	id = item_number
	$Label.text = str(id)
	
func log_print(message:String):
	print("id {1}, {2}".format([$Label.text, message]))
