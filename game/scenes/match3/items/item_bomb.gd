extends Item


func hints():
	pass

func hint_stop():
	pass
	
func is_component_running()->bool:
	var node = Components.get_component(self, c_move)
	return node and node.is_running()
	
func move(to_position:Vector2):
	var node_move = Components.get_component(self, c_move)
	if node_move:
		node_move.exec(to_position)
		
func delete():
	M3Core.add_event()
	$AnimationPlayer.play("trembling")
	await $explosion.finished
	M3Core.done_event()
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	queue_free()

