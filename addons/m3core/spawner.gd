extends Area2D

func _ready():
	if not has_overlapping_bodies():
		call_deferred("spawn_item")
			
func spawn_item(item_name:String = "")->bool:
	var item = M3Core.generate_item(item_name)
	if item and item is AreaItem:
		item.position = Vector2.ZERO
		add_child(item)
		item.check_move()
		item.active_move_timer = true
		return true
	return false

func _on_timer_timeout():
	if not has_overlapping_areas():
		call_deferred("spawn_item")
