extends Sprite2D
class_name Projectile

const c_move = "Move2"
@export var to_position:Vector2

func is_component_running()->bool:
	var node = Components.get_component(self, c_move)
	return node and node.is_running()
	
func move(component):
	visible = true
	var new_position:Vector2 = position - to_position
	var node_move = Components.get_component(self, c_move)
	node_move.send_end.connect(_on_final)
	if node_move:
		node_move.exec(new_position)
		
func _on_final(component):
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	queue_free()
