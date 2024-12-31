extends Area2D

class_name HitboxComponent

@export var resistance:int = 1
@export var damage:int = 1
@export var hitpoints:int = 1

const total_damage = -1
const no_resist = -1

@onready var parent = get_parent()
var is_die:bool = false

func hit(_damage:int = total_damage, _resistance:int = no_resist):
	if is_die == false:
		pass
		
func total_hit():
	if is_die == false:
		parent.queue_free()
		is_die = true
