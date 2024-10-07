extends ItemBase

class_name Item

const c_move = "Move"
const c_scale = "Scale"
const c_delete = "ScaleToZero"

func hints():
	var node_scale = Components.get_component(self, c_scale)
	if node_scale:
		node_scale.exec()

func hint_stop():
	var node_scale = Components.get_component(self, c_scale)
	if node_scale:
		node_scale.abort(true)
	
func is_component_running()->bool:
	var node = Components.get_component(self, c_move)
	return node and node.is_running()
	
func move(to_position:Vector2):
	var node_move = Components.get_component(self, c_move)
	if node_move:
		node_move.exec(to_position)
		
func delete():
	var node_scale = Components.get_component(self, c_delete)
	if node_scale:
		node_scale.exec()

func _on_anim_send_start(component):
	M3Core.add_event()
	
func _on_anim_send_end(component):
	M3Core.done_event()

func _on_scale_to_zero_send_end(component):
	self_modulate = Color(0,0,0,0)
	var node_blast = Components.get_component(self, "Blast")
	if node_blast:
		node_blast.restart()
		await node_blast.send_end
		
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	_on_anim_send_end(component)
	queue_free()
