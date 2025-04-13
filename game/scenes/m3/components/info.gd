# Компонент информации отвечает за индивидуальные параметры предмета, например название и тип.
# Компонент может выступать контейнером для других компонент с параметрами для типов.
# Главный компонент info остальные - дочерние по отношению к нему.

extends Node2D

class_name InfoComponent

@export var _item_name:String
@export var _item_size:int = 128
@export var damager_component:DamageContainerComponent = null
@export var _view_component:ViewComponent = null
@export var _pmover_component:PMoverComponent = null
@export var _swap_logic:BaseSwapLogicComponent = null
@export var _top_item:InfoComponent = null
@export var is_interactive:bool = true
@export var reward_count:int = 1
@export var save_value_type:PlayerState.EPS = PlayerState.EPS.NONE
var save_coins:PlayerStateValueInt = null

const group_name = "info"

@onready var _item_generator:ItemGenerator = get_tree().get_first_node_in_group(ItemGenerator.group_name)

var is_died:bool = false
var is_active:bool = false

func _ready() -> void:
	if save_value_type != PlayerState.EPS.NONE:
		save_coins = Globals.player_state.get_int_value(save_value_type)
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
	
func get_matcher_for_name(_name:String = ""):
	if _name.is_empty():
		_name = _item_name
	var new_item:MatchInfoComponent = null
	if _item_generator:
		new_item = _item_generator.get_matcher(_name)
		if new_item == null:
			print("Error. get_matcher_for_name {0} no matcher".format([_item_name]))
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
	
func change_to(_name:String)->InfoComponent:
	if is_item_name_valid(_name):
		return change_to_item(_name) if is_item_name_item(_name) else change_to_matcher(_name)
	return null
	
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
	get_tree().call_group(BaseM3Level.group_name, BaseM3Level.events_fn, BaseM3Level.EEvents.NO_HINTS)

func is_blocked()->bool:
	return _top_item != null
	
func is_movable()->bool:
	return not is_blocked() and is_interactive and not is_died and is_active 

func finalize(is_quiet:bool = false):
	if not is_interactive or is_died:
		return
		
	for item_child in get_children():
		if item_child is InfoComponent:
			item_child.is_active = true
			item_child.is_interactive = true
			item_child.call_deferred("finalize")
		
	if _pmover_component != null and _pmover_component.has_swap_move():
		_pmover_component.call_deferred("final_swap_move_logic")
		return
		
	if _top_item != null:
		_top_item.finalize()
		return

	is_died = true
	if is_quiet == false:
		if damager_component:
			damager_component.run_damage()
		if _view_component and _view_component.has_end_effect():
			_view_component.run_end_effect()
			await _view_component.send_effect_done
		get_tree().call_group(Quest.group_name, Quest.on_final_item_fn, _item_name)
		if save_coins:
			save_coins.value += int(reward_count)

	queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if is_interactive:
		is_active = true
		check_move()
		
func check_move():
	if _pmover_component:
		_pmover_component.call_deferred("try_move")

func proc_swap_logic(second_swap:InfoComponent = null)->bool:
	if _swap_logic:
		_swap_logic.start(self, second_swap)
		return true
	return false
