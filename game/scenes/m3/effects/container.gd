extends Node2D

class_name EffectContainer

signal send_effects_done()

func start():
	var last_effect:GPUParticles2D = null
	for effect in get_children():
		if effect is GPUParticles2D:
			last_effect = effect
			effect.emitting  = true
	if last_effect:
		await last_effect.finished
		
	send_effects_done.emit()
	
func has_effects()->bool:
	for effect in get_children():
		if effect is GPUParticles2D:
			return true
	return false
