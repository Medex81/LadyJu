extends Sprite2D

class_name ViewComponent

@export var _start_effect:Node = null
@export var _stop_effect:Node = null
@export var _end_effect:Node = null

func run_end_effect():
	texture = null
	for effect in get_children():
		if effect != _end_effect:
			effect.visible = false
	if _end_effect:
		if _end_effect is GPUParticles2D:
			_end_effect.emitting  = true
			await _end_effect.finished
		if _end_effect is EffectContainer and _end_effect.has_effects():
			_end_effect.start()
			await _end_effect.send_effects_done
			
	queue_free()
	
func has_end_effect()->bool:
	return _end_effect != null
