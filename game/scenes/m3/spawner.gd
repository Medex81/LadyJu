extends Area2D

class_name Spawner

@export var item_generator_group_name:String = "item_generator"
@onready var item_generator:ItemGenerator = get_tree().get_first_node_in_group(item_generator_group_name)

func _ready():
	if not has_overlapping_bodies():
		call_deferred("spawn_item")
			
func spawn_item()->bool:
	# запрос на генерацию предмета матчера если подходит по количеству
	if item_generator:
		var item = item_generator.generate_item()
		if item:
			add_child(item)
			item.visible = true
			return true
	return false

func _on_timer_timeout():
	if not has_overlapping_areas():
		call_deferred("spawn_item")
