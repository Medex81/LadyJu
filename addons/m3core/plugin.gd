@tool
extends EditorPlugin

const AUTOLOAD_NAME = "M3Core"

func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/m3core/m3core.tscn")

func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
