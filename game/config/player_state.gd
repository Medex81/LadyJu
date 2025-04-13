extends Resource

class_name PlayerState

@export var current_location:String
@export var current_quest:String
@export var quest_done:String

enum EPS{NONE, COINS, HUMMER, V_ROCKET, H_ROCKET}

@export var coins:PlayerStateValueInt = null
@export var boost_hummer:PlayerStateValueInt = null
@export var boost_v_rocket:PlayerStateValueInt = null
@export var boost_h_rocket:PlayerStateValueInt = null

var int_values = {}

func get_int_value(key:EPS)->PlayerStateValueInt:
	if int_values.is_empty():
		int_values = {EPS.COINS:coins, EPS.HUMMER:boost_hummer, EPS.V_ROCKET:boost_v_rocket, EPS.H_ROCKET:boost_h_rocket}
	return int_values.get(key, null)
