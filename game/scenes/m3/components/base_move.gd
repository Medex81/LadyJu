extends Node2D

class_name BaseMoveComponent

signal send_done()

func start(_self_item:InfoComponent, item_name:String = ""):
	send_done.emit()
