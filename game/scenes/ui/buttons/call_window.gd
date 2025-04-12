extends Button

@export var local_window:WindowComponent = null

func _on_pressed() -> void:
	if local_window:
		local_window.visible = true
