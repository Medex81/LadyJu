extends Sprite2D

class_name ViewComponent

@export var _start_effect:Node = null
@export var _stop_effect:Node = null
@export var _end_effect:Node = null

signal send_effect_done()

func _run_effect(effect:Node)->bool:
	if effect is GPUParticles2D:
		effect.finished.connect(send_effect_done.emit)
		effect.emitting  = true
		return true
	elif effect is AnimationPlayer:
		effect.animation_finished.connect(func(_anim_name:String):
			send_effect_done.emit())
		effect.play("start")
		return true
	return false

func run_end_effect()->bool:
	#texture = null
	return _run_effect(_end_effect)
	
func run_start_effect()->bool:
	return _run_effect(_start_effect)
	
func run_stop_effect()->bool:
	return _run_effect(_stop_effect)
