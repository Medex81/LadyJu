# Компонент информации отвечает за индивидуальные параметры предмета, например название и тип.
# Компонент может выступать контейнером для других компонент с параметрами для типов.
# Главный компонент info остальные - дочерние по отношению к нему.

extends Node2D

class_name InfoComponent

@export var item_name:String
@export var item_size:int = 128
@export var item_generator_group_name:String = "item_generator"
@export var main_scene_group_name:String = "main_scene"
@onready var item_generator:ItemGenerator = get_tree().get_first_node_in_group(item_generator_group_name)

enum EInfoEvent{NO_HINT}

func get_item_name()->String:
	return item_name
	
func get_item_size()->int:
	return item_size

func _ready() -> void:
	for child in get_children():
		child.visible = true
		
func change_to_item(new_item_name:String)->InfoComponent:
	var new_item:InfoComponent = null
	if item_generator:
		new_item = item_generator.get_item(new_item_name)
		if new_item:
			get_parent().add_child(new_item)
			new_item.global_position = global_position
			queue_free()
			return new_item
		else:
			print("Error. Change item {0} to {1}".format([item_name, new_item_name]))
	return new_item

func _on_hint_send_hasnt_hint() -> void:
	get_tree().call_group(main_scene_group_name, "items_event", EInfoEvent.NO_HINT)
