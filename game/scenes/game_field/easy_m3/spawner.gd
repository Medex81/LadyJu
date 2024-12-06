extends Area2D

class_name EasySpawner

@export var items:Array[String]
var packed_items:Dictionary

func _ready():
	for item in items:
		var tmp = load(item)
		if tmp:
			var item_name = item.get_file().get_basename()
			if packed_items.has(item_name):
				print("Error. Spawned item {0} was added earlier.".format([item_name]))
			packed_items[item_name] = tmp as PackedScene
			
	if not has_overlapping_bodies():
		call_deferred("spawn_item")
			
func spawn_item(item_name:String = "")->bool:
	if not packed_items.is_empty():
		if item_name.is_empty():
			item_name = packed_items.keys().pick_random()
		if not packed_items.has(item_name):
			item_name = packed_items.keys().pick_random()
			print("Error. An item with name {0} is not on the list of spawners.".format([item_name]))
		if packed_items[item_name].can_instantiate():
			var item = packed_items[item_name].instantiate()
			#item.item_name = item_name
			call_deferred("add_child", item)
			#print("Info. Cteate item {0}, from spawner {1}.".format([item_name, name]))
			return true
		else:
			print("Error. The scene {0} does not contain nodes.".format([item_name]))
	return false
			
#func _on_body_exited(body):
	#await get_tree().create_timer(0.4).timeout
	#if not has_overlapping_bodies():
		#call_deferred("spawn_item")

#func _on_area_exited(area):
	#await get_tree().create_timer(0.4).timeout
	#if not has_overlapping_areas():
		#call_deferred("spawn_item")


func _on_timer_timeout():
	if not has_overlapping_areas():
		call_deferred("spawn_item")
