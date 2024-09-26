extends Node

@export var _move_time:float = 0.3

func task(item:Object, position_to:Vector2, finish_callback:Callable):
	if item != null and "position" in item and finish_callback.is_valid():
		var tween_move = create_tween()
		tween_move.tween_property(item, "position", position_to,  _move_time)
		tween_move.tween_callback(finish_callback)
	else:
		if finish_callback.is_valid():
			finish_callback.call()
		print("Error. Component{0}, object type to move {1}, object has property -position- {2}, calback is valid {3}"\
		.format([name, item.get_class() if item else "null", "position" in item, finish_callback.is_valid()]))
