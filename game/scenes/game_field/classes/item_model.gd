extends Node

class_name ItemModel

var is_blocked:bool = false
var type: Match3Logic.EItemTypes = Match3Logic.EItemTypes.RED

func _init(_is_blocked:bool, _type: Match3Logic.EItemTypes):
	is_blocked = is_blocked
	type = _type
