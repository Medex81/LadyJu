@tool
extends Panel

class_name EasyCell

const _color_on:Color = Color(0.35,0.62,0.83,0.41)
const _color_off:Color = Color(0,0,0,0)

@export var transparent:bool = false:
	set(value):
		var style = get_theme_stylebox("panel").duplicate()
		style.bg_color = _color_off if value else _color_on
		add_theme_stylebox_override("panel", style)
		transparent = value
