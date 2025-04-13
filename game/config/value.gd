extends Resource
class_name PlayerStateValueInt

@export var value:int = 0:
	set(_value):
		value = _value
		send_value_change.emit(_value)

signal send_value_change(value:int)

func set_value(_value):
	value = _value
