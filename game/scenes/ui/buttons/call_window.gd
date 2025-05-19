extends Button

@export var local_window:WindowComponent = null
@export var only_for_debug:bool = false

func _ready() -> void:
	if only_for_debug and not OS.is_debug_build():
		visible = false
	if local_window != null:
		local_window.hidden.connect(set_unpressed)
		
func set_unpressed():
	set_pressed_no_signal(false)

func _on_toggled(toggled_on: bool) -> void:
	if local_window:
		local_window.visible = toggled_on
