extends Node2D

@onready var parent = get_parent()
@export var speed:int = 300
@export var direction:Vector2 = Vector2.ZERO
var can_move:bool = false

func _physics_process(delta: float) -> void:
	if can_move:
		parent.position += direction * (speed * delta)
		
func move_by(_direction:Vector2):
	direction = _direction
	can_move = true
	
func move():
	can_move = true
	
