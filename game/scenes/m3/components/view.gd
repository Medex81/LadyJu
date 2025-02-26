extends Sprite2D

class_name ViewComponent

@export var _start_effect:Node2D = null
@export var _stop_effect:Node2D = null
@export var _end_effect:Node2D = null

signal send_finish_effect()

func run_end_effect():
	if _end_effect:
		if _end_effect is GPUParticles2D:
			_end_effect.emitting  = true
			await _end_effect.finished
	send_finish_effect.emit()
	
func has_end_effect()->bool:
	return _end_effect != null
