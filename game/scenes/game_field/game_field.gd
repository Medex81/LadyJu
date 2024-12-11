extends Control

func _ready():
	$generates.visible = false
	M3Core.set_generate_items($generates)
	
