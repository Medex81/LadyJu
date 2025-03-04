# Компонент информации отвечает за индивидуальные параметры предмета, например название и тип.
# Компонент может выступать контейнером для других компонент с параметрами для типов.
# Главный компонент info остальные - дочерние по отношению к нему.

extends Node2D

class_name InfoComponent

@export var _item_name:String
@export var _item_size:int = 128
@export var _item_generator_group_name:String = "item_generator"
@export var _main_scene_group_name:String = "main_scene"

@export var _damager_component:DamageContainerComponent = null
@export var _view_component:ViewComponent = null
@export var _pmover_component:PMoverComponent = null

@onready var _item_generator:ItemGenerator = get_tree().get_first_node_in_group(_item_generator_group_name)

enum EInfoEvent{NO_HINT}

var is_died:bool = false
var is_active:bool = false

func _ready() -> void:
	for child in get_children():
		child.visible = true
		
func get_item_name()->String:
	return _item_name
	
func is_item_name_matcher(item_name:String)->bool:
	if _item_generator:
		return _item_generator.is_item_name_matcher(item_name)
	return false
	
func is_item_name_item(item_name:String)->bool:
	if _item_generator:
		return _item_generator.is_item_name_item(item_name)
	return false

func is_item_name_valid(item_name:String)->bool:
	return is_item_name_item(item_name) or is_item_name_matcher(item_name)
	
func get_random_item_name(exclude:String = _item_name)->String:
	if _item_generator:
		return _item_generator.get_random_item(exclude)
	return ""
	
func get_item_size()->int:
	return _item_size

func change_to_item(_name:String = "")->InfoComponent:
	var new_item:InfoComponent = null
	if _item_generator:
		new_item = _item_generator.get_item(_name)
		if new_item:
			new_item.position = position
			get_parent().add_child(new_item)
			if new_item._pmover_component:
				new_item._pmover_component.call_deferred("timer_matching", 2.0)
			finalize(true)
		else:
			print("Error. Change item {0} to {1}".format([_item_name, _name]))
	return new_item
	
func change_to_matcher(_name:String)->MatchInfoComponent:
	var new_item:MatchInfoComponent = null
	if _item_generator:
		new_item = _item_generator.get_matcher(_name)
		if new_item:
			new_item.position = position
			get_parent().add_child(new_item)
			finalize()
		else:
			print("Error. Change item {0} to matcher".format([_item_name]))
	return new_item
	
func change_to_matcher_enum(_match_type:MatcherComponent.EMatcher)->MatchInfoComponent:
	var new_item:MatchInfoComponent = null
	if _item_generator:
		new_item = _item_generator.get_matcher_from_enum(_match_type) as MatchInfoComponent
		if new_item:
			new_item.position = position
			get_parent().add_child(new_item)
			finalize()
		else:
			print("Error. Change item {0} to matcher enum {1}".format([_item_name, _match_type]))
	return new_item

func on_no_hint() -> void:
	get_tree().call_group(_main_scene_group_name, "items_event", EInfoEvent.NO_HINT)

func finalize(is_quiet:bool = false):
	if is_died:
		return
	if _pmover_component:
		_pmover_component.notify_top()
	is_died = true
	if is_quiet == false:
		if _view_component:
			remove_child(_view_component)
			get_parent().add_child(_view_component)
			_view_component.position = position
			_view_component.run_end_effect()
		if _damager_component:
			_damager_component.run_damage()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_active = true
