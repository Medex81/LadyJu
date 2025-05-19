extends Resource

class_name PlayerState

@export var current_location:String
@export var current_quest:String
@export var quest_done:String

enum EPS{NONE, COINS, HUMMER, V_FLASH, H_FLASH}

@export var coins:PlayerStateValueInt = PlayerStateValueInt.new()
@export var boost_hummer:PlayerStateValueInt = PlayerStateValueInt.new()
@export var boost_v_flash:PlayerStateValueInt = PlayerStateValueInt.new()
@export var boost_h_flash:PlayerStateValueInt = PlayerStateValueInt.new()

var int_values = {}

func get_int_value(key:EPS)->PlayerStateValueInt:
	if int_values.is_empty():
		int_values = {EPS.COINS:coins, EPS.HUMMER:boost_hummer, EPS.V_FLASH:boost_v_flash, EPS.H_FLASH:boost_h_flash}
	return int_values.get(key, null)
