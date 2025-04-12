extends Resource

class_name PlayerState

@export var current_location:String
@export var current_quest:String
@export var quest_done:String

@export var coins:int = 0:
	set(value):
		coins = value
		send_coins_change.emit(coins)
@export var boost_hummer:int = 0:
	set(value):
		boost_hummer = value
		send_boost_hummer_change.emit(boost_hummer)
@export var boost_v_rocket:int = 0:
	set(value):
		boost_v_rocket = value
		send_boost_v_rocket_change.emit(boost_v_rocket)
@export var boost_h_rocket:int = 0:
	set(value):
		boost_h_rocket = value
		send_boost_h_rocket_change.emit(boost_h_rocket)

signal send_coins_change(value:int)
signal send_boost_hummer_change(value:int)
signal send_boost_v_rocket_change(value:int)
signal send_boost_h_rocket_change(value:int)
