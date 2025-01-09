extends GPUParticles2D

func _on_visibility_changed() -> void:
	if visible:
		$AudioStreamPlayer2D.play()
