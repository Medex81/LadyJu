extends Node2D

class_name EffectContainer

var last_effect:GPUParticles2D = null

func _ready() -> void:
	for effect in get_children():
		if effect is GPUParticles2D:
			last_effect = effect

func start():
	for effect in get_children():
		if effect is GPUParticles2D:
			effect.emitting  = true
