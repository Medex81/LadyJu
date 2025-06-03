extends Sprite2D

class_name ViewComponent

@export var _start_effect:Node = null
@export var _stop_effect:Node = null
@export var _end_effect:Node = null

signal send_effect_done()

func run_end_effect()->bool:
	texture = null

	if _end_effect is GPUParticles2D:
		_end_effect.finished.connect(send_effect_done.emit)
		_end_effect.emitting  = true
		return true
	elif _end_effect is EffectContainer and _end_effect.last_effect != null:
		_end_effect.last_effect.finished.connect(send_effect_done.emit)
		_end_effect.start()
		return true
	elif _end_effect is AnimationPlayer:
		_end_effect.animation_finished.connect(func(_anim_name:String):
			send_effect_done.emit())
		_end_effect.play("start")
		return true
	return false
