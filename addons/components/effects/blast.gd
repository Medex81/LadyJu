extends Effects

func restart():
	$GPUParticles2D.restart()
	$AudioStreamPlayer2D.play()
	$GPUParticles2D.finished.connect(_on_finish)
	
func _on_finish():
	send_end.emit(name)
