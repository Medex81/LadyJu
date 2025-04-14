extends Button
class_name BaseBoostButton

@export var save_value_type:PlayerState.EPS = PlayerState.EPS.NONE
var save_value:PlayerStateValueInt = null

var _value:int = 0
@export var item:InfoComponent = null
@export var boost_interseptor:BoostInterseptor = null

signal send_new_value(value:int)

func set_value(value:int):
	$count_panel/value.text = str(value)
	_value = value

func _ready() -> void:
	if save_value_type != PlayerState.EPS.NONE:
		save_value = Globals.player_state.get_int_value(save_value_type)
		if save_value:
			save_value.send_value_change.connect(set_value)
			send_new_value.connect(save_value.set_value)
			set_value(save_value.value)
	
func _exit_tree() -> void:
	if save_value:
		if save_value.send_value_change.is_connected(set_value):
			save_value.send_value_change.disconnect(set_value)
		if send_new_value.is_connected(save_value.set_value):
			send_new_value.disconnect(save_value.set_value)

func hit_on_position(glob_pos:Vector2):
	if button_pressed and _value > 0 and item != null:
		var item_dup = item.duplicate() as InfoComponent
		add_child(item_dup)
		item_dup.visible = true
		item_dup.global_position = glob_pos
		_value -= 1
		send_new_value.emit(_value)
		await get_tree().create_timer(0.1).timeout
		item_dup.call_deferred("finalize")
	button_pressed = false
	boost_interseptor.visible = false
		
func _on_toggled(toggled_on: bool) -> void:
	if toggled_on and boost_interseptor != null:
		boost_interseptor.visible = true
	else:
		boost_interseptor.visible = false
