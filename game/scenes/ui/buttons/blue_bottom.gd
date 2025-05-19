extends Button

@export var local_window:WindowComponent = null

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if local_window:
			local_window.visible = true
	else:
		if local_window:# and button_group != null:
			local_window.visible = false
